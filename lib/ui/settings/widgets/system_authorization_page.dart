import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/health_service.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'dart:io' show Platform;

class SystemAuthorizationPage extends StatefulWidget {
  const SystemAuthorizationPage({super.key});

  @override
  State<SystemAuthorizationPage> createState() =>
      _SystemAuthorizationPageState();
}

class _SystemAuthorizationPageState extends State<SystemAuthorizationPage> {
  // permission status cache
  PermissionStatus? _locationStatus;
  PermissionStatus? _photosStatus;
  PermissionStatus? _cameraStatus;
  PermissionStatus? _microPhoneStatus;
  PermissionStatus? _calendarStatus;
  PermissionStatus? _fitnessStatus;
  PermissionStatus? _notificationStatus;
  PermissionStatus? _remindersStatus;

  // App lifecycle listener; refresh when returning from settings
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
    _listener = AppLifecycleListener(
      onResume: _checkAllPermissions,
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  Future<void> _checkAllPermissions() async {
    final location = await Permission.location.status;
    final photos = await Permission.photos.status;
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    final calendar = Platform.isIOS
        ? await Permission.calendarWriteOnly.status
        : await Permission.calendarFullAccess.status;
    final fitness = Platform.isIOS
        ? await Permission.sensors.status
        : await Permission.activityRecognition.status;
    final notification = await Permission.notification.status;
    final reminders = Platform.isAndroid
        ? await Permission.calendarFullAccess.status
        : await Permission.reminders.status;

    if (mounted) {
      setState(() {
        _locationStatus = location;
        _photosStatus = photos;
        _cameraStatus = camera;
        _microPhoneStatus = mic;
        _calendarStatus = calendar;
        _fitnessStatus = fitness;
        _notificationStatus = notification;
        _remindersStatus = reminders;
      });
    }
  }

  Future<void> _requestPermission(
      Permission permission, VoidCallback onUpdate) async {
    try {
      final status = await permission.request();
      if (status.isPermanentlyDenied) {
        // guide user to settings
        _showSettingsDialog();
      } else {
        onUpdate();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(UserStorage.l10n.permissionRequestError(e.toString()))),
        );
      }
    }
  }

  /// Request fitness permission AND HealthKit data authorization together.
  Future<void> _requestFitnessPermission() async {
    try {
      // 1. Request system-level fitness/motion permission
      final permission =
          Platform.isIOS ? Permission.sensors : Permission.activityRecognition;
      final status = await permission.request();

      // 2. Request HealthKit / Health Connect data-type authorization.
      // This is INDEPENDENT of the Motion & Fitness permission: a user who
      // already granted Motion (so step 1 no longer re-prompts) must still be
      // able to authorize Health data types. Previously this was gated behind
      // `status.isGranted` AND only reachable from the not-yet-granted tap
      // path, so HealthKit authorization could never be triggered once Motion
      // was granted — leaving every type at "Authorization not determined".
      // iOS only surfaces the authorization sheet for not-yet-determined types.
      await HealthService().requestAllPermissions();

      if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      }
      _checkAllPermissions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(UserStorage.l10n.permissionRequestError(e.toString()))),
        );
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(UserStorage.l10n.permissionRequiredTitle),
        content: Text(UserStorage.l10n.permissionPermanentlyDeniedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(UserStorage.l10n.goToSettings),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required PermissionStatus? status,
    required VoidCallback onTap,
    bool showBadge = false,
    bool reauthorizeWhenGranted = false,
  }) {
    Color statusColor;
    String statusText;

    if (status == null) {
      statusColor = Colors.grey;
      statusText = UserStorage.l10n.getting;
    } else if (status.isGranted || status.isLimited) {
      statusColor = Colors.green;
      statusText = UserStorage.l10n.authorized;
    } else {
      statusColor = Colors.orange;
      statusText = UserStorage.l10n.unauthorized;
    }

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          if (showBadge)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(statusText, style: TextStyle(color: statusColor, fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: () {
        final granted =
            status != null && (status.isGranted || status.isLimited);
        if (status != null && !granted) {
          onTap();
        } else if (granted && reauthorizeWhenGranted) {
          // The Fitness item also drives HealthKit data-type authorization,
          // which may still be undetermined even when Motion is granted.
          onTap();
        } else if (granted) {
          // show toast or open settings
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(UserStorage.l10n.authorizedGoToSettings)),
          );
          openAppSettings();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.systemAuthorization),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildPermissionItem(
                  icon: Icons.location_on_outlined,
                  title: UserStorage.l10n.location,
                  subtitle: UserStorage.l10n.locationPermissionReason,
                  status: _locationStatus,
                  onTap: () => _requestPermission(
                      Permission.location, _checkAllPermissions),
                ),
                const Divider(height: 1, indent: 56),
                _buildPermissionItem(
                  icon: Icons.photo_library_outlined,
                  title: UserStorage.l10n.photos,
                  subtitle: UserStorage.l10n.photosPermissionReason,
                  status: _photosStatus,
                  onTap: () => _requestPermission(
                      Permission.photos, _checkAllPermissions),
                ),
                const Divider(height: 1, indent: 56),
                _buildPermissionItem(
                  icon: Icons.camera_alt_outlined,
                  title: UserStorage.l10n.camera,
                  subtitle: UserStorage.l10n.cameraPermissionReason,
                  status: _cameraStatus,
                  onTap: () => _requestPermission(
                      Permission.camera, _checkAllPermissions),
                ),
                const Divider(height: 1, indent: 56),
                _buildPermissionItem(
                  icon: Icons.mic_none_outlined,
                  title: UserStorage.l10n.microphone,
                  subtitle: UserStorage.l10n.microphonePermissionReason,
                  status: _microPhoneStatus,
                  onTap: () => _requestPermission(
                      Permission.microphone, _checkAllPermissions),
                ),
                const Divider(height: 1, indent: 56),
                _buildPermissionItem(
                  icon: Icons.calendar_month_outlined,
                  title: UserStorage.l10n.calendar,
                  subtitle: UserStorage.l10n.calendarPermissionReason,
                  status: _calendarStatus,
                  onTap: () => _requestPermission(
                      Platform.isIOS
                          ? Permission.calendarWriteOnly
                          : Permission.calendarFullAccess,
                      _checkAllPermissions),
                ),
                const Divider(height: 1, indent: 56),
                _buildPermissionItem(
                  icon: Icons.checklist_outlined,
                  title: UserStorage.l10n.reminders,
                  subtitle: UserStorage.l10n.remindersPermissionReason,
                  status: _remindersStatus,
                  onTap: () => _requestPermission(
                      Platform.isAndroid
                          ? Permission.calendarFullAccess
                          : Permission.reminders,
                      _checkAllPermissions),
                ),
                const Divider(height: 1, indent: 56),
                _buildPermissionItem(
                  icon: Icons.directions_run_outlined,
                  title: UserStorage.l10n.fitnessAndMotion,
                  subtitle: UserStorage.l10n.fitnessPermissionReason,
                  status: _fitnessStatus,
                  showBadge: _fitnessStatus != null &&
                      !_fitnessStatus!.isGranted &&
                      !_fitnessStatus!.isLimited,
                  // Tappable even when Motion is already granted, so HealthKit
                  // data-type authorization can still be (re)triggered.
                  reauthorizeWhenGranted: true,
                  onTap: () => _requestFitnessPermission(),
                ),
                const Divider(height: 1, indent: 56),
                _buildPermissionItem(
                  icon: Icons.notifications_none_outlined,
                  title: UserStorage.l10n.notification,
                  subtitle: UserStorage.l10n.notificationPermissionReason,
                  status: _notificationStatus,
                  onTap: () => _requestPermission(
                      Permission.notification, _checkAllPermissions),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
