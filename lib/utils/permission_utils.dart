import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  /// Check if fitness/motion permission is granted (without requesting).
  static Future<bool> isFitnessPermissionGranted() async {
    final status = Platform.isIOS
        ? await Permission.sensors.status
        : await Permission.activityRecognition.status;
    return status.isGranted || status.isLimited;
  }
}
