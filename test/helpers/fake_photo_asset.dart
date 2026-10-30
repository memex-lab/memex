import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

/// Fakes the OS-owned PhotoKit/MediaStore boundary without host-platform checks.
class FakePhotoAsset extends AssetEntity {
  FakePhotoAsset(
      {required super.id, required this.fileLoader, required this.titleLoader})
      : super(typeInt: 1, width: 4000, height: 3000);

  final Future<File?> Function(bool isOrigin) fileLoader;
  final Future<String> Function() titleLoader;

  @override
  Future<File?> get originFile => fileLoader(true);
  @override
  Future<File?> get file => fileLoader(false);
  @override
  Future<String> get titleAsync => titleLoader();
}
