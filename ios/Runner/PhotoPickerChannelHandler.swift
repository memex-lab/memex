import Flutter
import Photos
import PhotosUI
import UniformTypeIdentifiers
import UIKit

/// Keeps system-picker providers alive until Flutter has prepared each attachment.
/// Selection completion never waits for original-file downloads.
class PhotoPickerChannelHandler: NSObject, PHPickerViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    private var pendingPicker: FlutterResult?
    private weak var activePicker: PHPickerViewController?
    private var selections: [String: PHPickerResult] = [:]

    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "com.memexlab.memex/photo_picker", binaryMessenger: messenger)
        let handler = PhotoPickerChannelHandler()
        channel.setMethodCallHandler(handler.handle)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        if call.method == "pickImages" {
            // Recover if UIKit dismissed a presentation without a picker result.
            if pendingPicker != nil && activePicker?.presentingViewController == nil {
                completeDismissal()
            }
            guard pendingPicker == nil else {
                result(FlutterError(code: "PICKER_BUSY", message: "Photo picker is already open", details: nil))
                return
            }
            guard var presenter = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController else {
                result(FlutterError(code: "NO_PRESENTER", message: "Cannot open photo picker", details: nil))
                return
            }
            while let presented = presenter.presentedViewController { presenter = presented }
            let picker = Self.makePicker(maxAssets: args["maxAssets"] as? Int ?? 9)
            beginPresentation(picker, result: result)
            presenter.present(picker, animated: true)
            picker.presentationController?.delegate = self
            return
        }
        guard let id = args["id"] as? String else {
            result(FlutterMethodNotImplemented)
            return
        }
        if call.method == "release" {
            selections.removeValue(forKey: id)
            result(nil)
            return
        }
        guard let selection = selections[id] else {
            result(FlutterError(code: "MISSING_SELECTION", message: "Photo selection expired", details: nil))
            return
        }
        switch call.method {
        case "thumbnail": thumbnail(selection, result: result)
        case "prepareOriginal": prepareOriginal(selection, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }

    static func makePicker(maxAssets: Int) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = max(1, min(maxAssets, 9))
        config.preferredAssetRepresentationMode = .current
        if #available(iOS 15, *) { config.selection = .ordered }
        let picker = PHPickerViewController(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        picker.isModalInPresentation = true
        return picker
    }

    func beginPresentation(_ picker: PHPickerViewController, result: @escaping FlutterResult) {
        picker.delegate = self
        pendingPicker = result
        activePicker = picker
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard picker === activePicker else { return }
        let callback = pendingPicker
        pendingPicker = nil
        activePicker = nil
        let rows: [[String: Any]] = results.map { selection in
            let id = UUID().uuidString
            selections[id] = selection
            var row: [String: Any] = ["id": id]
            if let assetId = selection.assetIdentifier { row["assetId"] = assetId }
            return row
        }
        picker.dismiss(animated: true) { callback?(rows) }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard presentationController.presentedViewController === activePicker else { return }
        completeDismissal()
    }

    private func completeDismissal() {
        let callback = pendingPicker
        pendingPicker = nil
        activePicker = nil
        callback?([])
    }

    private func thumbnail(_ selection: PHPickerResult, result: @escaping FlutterResult) {
        // PhotoKit can provide a small local preview without exporting an original.
        let access = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if (access == .authorized || access == .limited),
           let id = selection.assetIdentifier,
           let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject {
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = false
            var replied = false
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options) { image, info in
                DispatchQueue.main.async {
                    guard !replied else { return }
                    if let image = image {
                        replied = true
                        self.replyPreview(image, result: result)
                    } else if (info?[PHImageResultIsDegradedKey] as? Bool) != true {
                        replied = true
                        self.providerPreview(selection.itemProvider, result: result)
                    }
                }
            }
        } else {
            // PHPicker also works when the app has no or only limited library
            // permission. Use the selected provider rather than requiring a PHAsset.
            providerPreview(selection.itemProvider, result: result)
        }
    }

    private func providerPreview(_ provider: NSItemProvider, result: @escaping FlutterResult) {
        provider.loadPreviewImage(options: nil) { object, _ in
            guard let image = object as? UIImage else {
                DispatchQueue.main.async { result(nil) }
                return
            }
            self.replyPreview(image, result: result)
        }
    }

    private func replyPreview(_ image: UIImage, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            let ratio = min(1, 200 / max(image.size.width, image.size.height))
            let size = CGSize(width: max(1, image.size.width * ratio), height: max(1, image.size.height * ratio))
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let preview = UIGraphicsImageRenderer(size: size, format: format).image { _ in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
            let data = preview.jpegData(compressionQuality: 0.8)
            DispatchQueue.main.async { result(data.map { FlutterStandardTypedData(bytes: $0) }) }
        }
    }

    private func prepareOriginal(_ selection: PHPickerResult, result: @escaping FlutterResult) {
        let provider = selection.itemProvider
        // A generic image request honors .current without forcing conversion
        // to a particular advertised format such as JPEG.
        let type = UTType.image.identifier
        provider.loadFileRepresentation(forTypeIdentifier: type) { url, error in
            guard let url = url else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "PHOTO_EXPORT_FAILED", message: error?.localizedDescription ?? "Cannot load selected photo", details: nil))
                }
                return
            }
            do {
                // The provider URL expires when this callback returns. Copy bytes
                // before replying; never re-encode the full photo or its metadata.
                let folder = FileManager.default.temporaryDirectory
                    .appendingPathComponent("selected_photos", isDirectory: true)
                    .appendingPathComponent(UUID().uuidString, isDirectory: true)
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                var name = provider.suggestedName.map { ($0 as NSString).lastPathComponent } ?? url.lastPathComponent
                if name.isEmpty || name == "." || name == ".." { name = url.lastPathComponent }
                if (name as NSString).pathExtension.isEmpty && !url.pathExtension.isEmpty {
                    name += "." + url.pathExtension
                }
                let target = folder.appendingPathComponent(name)
                try FileManager.default.copyItem(at: url, to: target)
                DispatchQueue.main.async { result(["path": target.path, "originalName": name]) }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "PHOTO_COPY_FAILED", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
}
