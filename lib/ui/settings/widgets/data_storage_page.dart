import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/toast_helper.dart';

/// Page to choose data storage: app storage, custom folder, or iCloud (iOS).
/// Like Obsidian: custom/device storage or iCloud keeps data when app is reinstalled.
class DataStoragePage extends StatefulWidget {
  const DataStoragePage({super.key});

  @override
  State<DataStoragePage> createState() => _DataStoragePageState();
}

class _DataStoragePageState extends State<DataStoragePage> {
  StorageLocation _location = StorageLocation.app;
  String? _customPath;
  bool _icloudAvailable = false;
  bool _loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = await UserStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      if (mounted)
        setState(() {
          _loading = false;
          _userId = null;
        });
      return;
    }
    final location = await UserStorage.getWorkspaceStorageLocation(userId);
    final customPath = await UserStorage.getCustomDataRootPath(userId);
    final icloudAvailable = await UserStorage.isICloudAvailable();
    if (mounted) {
      setState(() {
        _userId = userId;
        _location = location;
        _customPath = customPath;
        _icloudAvailable = icloudAvailable;
        _loading = false;
      });
    }
  }

  /// On Android: request storage permission (and all-files on Android 11+) before picking folder.
  /// Returns true if we can proceed (granted or not Android).
  Future<bool> _requestStoragePermissionIfNeeded() async {
    if (!Platform.isAndroid) return true;
    // Android 13+ `Permission.storage` always returns denied.
    // For arbitrary folder paths (Documents, Downloads, etc.) we need all-files access.
    var manageStatus = await Permission.manageExternalStorage.status;
    if (!manageStatus.isGranted) {
      manageStatus = await Permission.manageExternalStorage.request();
    }
    if (!manageStatus.isGranted) {
      if (mounted) {
        ToastHelper.showInfo(context, UserStorage.l10n.storagePermissionRequired);
      }
      // Best-effort jump to system settings when user denied or policy requires manual enable.
      await openAppSettings();
      return false;
    }
    return true;
  }

  /// Verify we can read/write the path (create and delete a test file). Returns true if OK.
  Future<bool> _verifyPathWritable(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) await dir.create(recursive: true);
      final testFile = File('$path/.memex_write_test');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _pickFolder() async {
    final uid = _userId;
    if (uid == null) return;
    if (Platform.isAndroid) {
      final ok = await _requestStoragePermissionIfNeeded();
      if (!ok || !mounted) return;
    }
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null || path.isEmpty || !mounted) return;
    final canWrite = await _verifyPathWritable(path);
    if (!canWrite && mounted) {
      ToastHelper.showInfo(
          context, UserStorage.l10n.customFolderAccessDenied);
      return;
    }
    if (!mounted) return;
    await UserStorage.setWorkspaceStorageToCustom(uid, path);
    setState(() {
      _location = StorageLocation.custom;
      _customPath = path;
    });
    ToastHelper.showInfo(
        context, UserStorage.l10n.restartRequiredAfterStorageChange);
  }

  Future<void> _selectApp() async {
    final uid = _userId;
    if (uid == null) return;
    await UserStorage.setWorkspaceStorageToApp(uid);
    setState(() {
      _location = StorageLocation.app;
      _customPath = null;
    });
    if (mounted) {
      ToastHelper.showInfo(
          context, UserStorage.l10n.restartRequiredAfterStorageChange);
    }
  }

  Future<void> _selectICloud() async {
    final uid = _userId;
    if (uid == null) return;
    if (!_icloudAvailable) {
      ToastHelper.showInfo(context, UserStorage.l10n.icloudRequiresCapability);
      return;
    }
    await UserStorage.setWorkspaceStorageToICloud(uid);
    setState(() => _location = StorageLocation.icloud);
    if (mounted) {
      ToastHelper.showInfo(
          context, UserStorage.l10n.restartRequiredAfterStorageChange);
    }
  }

  String _locationLabel(StorageLocation loc) {
    switch (loc) {
      case StorageLocation.app:
        return UserStorage.l10n.storageLocationApp;
      case StorageLocation.custom:
        return UserStorage.l10n.storageLocationCustom;
      case StorageLocation.icloud:
        return UserStorage.l10n.storageLocationICloud;
    }
  }

  String get _dataStorageDescription => Platform.isIOS
      ? UserStorage.l10n.dataStorageDescriptionIOS
      : UserStorage.l10n.dataStorageDescriptionAndroid;

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dataStorage),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userId == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _dataStorageDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      _dataStorageDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Current
                    Text(
                      l10n.storageLocationCurrent(_locationLabel(_location)),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    if (_customPath != null && _customPath!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _customPath!,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 24),
                    // App storage
                    _buildOptionCard(
                      title: l10n.storageLocationApp,
                      subtitle: l10n.storageLocationAppDesc,
                      icon: Icons.phone_android,
                      selected: _location == StorageLocation.app,
                      onTap: _selectApp,
                    ),
                    const SizedBox(height: 12),
                    // Custom folder
                    _buildOptionCard(
                      title: l10n.storageLocationCustom,
                      subtitle: l10n.storageLocationCustomDesc,
                      icon: Icons.folder_outlined,
                      selected: _location == StorageLocation.custom,
                      onTap: () async {
                        await _pickFolder();
                      },
                      trailing: _location == StorageLocation.custom &&
                              _customPath != null
                          ? Text(
                              _customPath!,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                    ),
                    if (Platform.isIOS) ...[
                      const SizedBox(height: 12),
                      _buildOptionCard(
                        title: l10n.storageLocationICloud,
                        subtitle: _icloudAvailable
                            ? l10n.storageLocationICloudDesc
                            : l10n.icloudRequiresCapability,
                        icon: Icons.cloud_outlined,
                        selected: _location == StorageLocation.icloud,
                        onTap: _selectICloud,
                        enabled: _icloudAvailable,
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    bool enabled = true,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF6366F1) : Colors.grey[300]!,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled
                    ? (selected ? const Color(0xFF6366F1) : Colors.grey[600])
                    : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: enabled ? const Color(0xFF0F172A) : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (trailing != null) ...[
                      const SizedBox(height: 6),
                      trailing,
                    ],
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle,
                    color: Color(0xFF6366F1), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
