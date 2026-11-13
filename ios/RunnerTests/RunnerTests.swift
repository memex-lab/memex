import Flutter
import UIKit
import XCTest
import PhotosUI
@testable import Runner

class RunnerTests: XCTestCase {

  func testExample() {
    // If you add code to the Runner application, consider adding tests here.
    // See https://developer.apple.com/documentation/xctest for more information about using XCTest.
  }

  @MainActor
  func testPickerScrollCannotDismissASheet() {
    let picker = PhotoPickerChannelHandler.makePicker(maxAssets: 9)
    XCTAssertEqual(picker.modalPresentationStyle, .fullScreen)
    XCTAssertTrue(picker.isModalInPresentation)
    XCTAssertEqual(picker.configuration.selectionLimit, 9)
    XCTAssertEqual(picker.configuration.preferredAssetRepresentationMode, .current)
  }

  @MainActor
  func testGestureDismissalCompletesOnceAndNextPickerCanFinish() {
    let handler = PhotoPickerChannelHandler()
    let first = PhotoPickerChannelHandler.makePicker(maxAssets: 9)
    var firstResults = 0
    handler.beginPresentation(first) { value in
      XCTAssertEqual((value as? [[String: Any]])?.count, 0)
      firstResults += 1
    }
    let firstPresentation = UIPresentationController(presentedViewController: first, presenting: UIViewController())
    handler.presentationControllerDidDismiss(firstPresentation)
    handler.presentationControllerDidDismiss(firstPresentation)
    XCTAssertEqual(firstResults, 1)

    let second = PhotoPickerChannelHandler.makePicker(maxAssets: 9)
    var secondResults = 0
    handler.beginPresentation(second) { _ in secondResults += 1 }
    // A late callback from the old presentation must not close the new one.
    handler.presentationControllerDidDismiss(firstPresentation)
    XCTAssertEqual(secondResults, 0)
    let secondPresentation = UIPresentationController(presentedViewController: second, presenting: UIViewController())
    handler.presentationControllerDidDismiss(secondPresentation)
    XCTAssertEqual(secondResults, 1)
  }

}
