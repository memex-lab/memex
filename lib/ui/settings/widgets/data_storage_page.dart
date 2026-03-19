import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/utils/toast_helper.dart';

/// Page to choose data storage.
/// Android: app storage or custom folder.
/// iOS: app storage or iCloud.
class DataStoragePage extends StatefulWidget {
  final bool onboardingMode;

  const DataStoragePage({
    super.key,
    this.onboardingMode = false,
  });

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
      if (mounted) {
        setState(() {
          _loading = false;
          _userId = null;
        });
      }
      return;
    }
    var location = await UserStorage.getWorkspaceStorageLocation(userId);
    if (Platform.isIOS && location == StorageLocation.custom) {
      location = StorageLocation.app;
    }
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
        ToastHelper.showInfo(
            context, UserStorage.l10n.storagePermissionRequired);
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
    if (Platform.isIOS) {
      if (mounted) {
        ToastHelper.showInfo(
            context, UserStorage.l10n.customFolderAccessDenied);
      }
      return;
    }
    if (Platform.isAndroid) {
      final ok = await _requestStoragePermissionIfNeeded();
      if (!ok || !mounted) return;
    }
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null || path.isEmpty || !mounted) return;
    final canWrite = await _verifyPathWritable(path);
    if (!canWrite && mounted) {
      ToastHelper.showInfo(context, UserStorage.l10n.customFolderAccessDenied);
      return;
    }
    if (!mounted) return;
    await UserStorage.setWorkspaceStorageToCustom(uid, path);
    await MemexRouter().applyWorkspaceStorageChange();
    if (!mounted) return;
    setState(() {
      _location = StorageLocation.custom;
      _customPath = path;
    });
    if (!mounted) return;
    ToastHelper.showSuccess(context, UserStorage.l10n.updateSuccess);
  }

  Future<void> _selectApp() async {
    final uid = _userId;
    if (uid == null) return;
    await UserStorage.setWorkspaceStorageToApp(uid);
    await MemexRouter().applyWorkspaceStorageChange();
    if (!mounted) return;
    setState(() {
      _location = StorageLocation.app;
      _customPath = null;
    });
    ToastHelper.showSuccess(context, UserStorage.l10n.updateSuccess);
  }

  Future<void> _selectICloud() async {
    final uid = _userId;
    if (uid == null) return;
    if (!_icloudAvailable) {
      ToastHelper.showInfo(context, UserStorage.l10n.icloudRequiresCapability);
      return;
    }
    await UserStorage.setWorkspaceStorageToICloud(uid);
    await MemexRouter().applyWorkspaceStorageChange();
    if (!mounted) return;
    setState(() => _location = StorageLocation.icloud);
    ToastHelper.showSuccess(context, UserStorage.l10n.updateSuccess);
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

  List<Widget> _buildStorageOptions(dynamic l10n) {
    final items = <Widget>[];

    void add(Widget item) {
      if (items.isNotEmpty) {
        items.add(const SizedBox(height: 12));
      }
      items.add(item);
    }

    final customCard = _buildOptionCard(
      title: l10n.storageLocationCustom,
      subtitle: l10n.storageLocationCustomDesc,
      icon: Icons.folder_outlined,
      selected: _location == StorageLocation.custom,
      onTap: () async {
        await _pickFolder();
      },
      trailing: _location == StorageLocation.custom && _customPath != null
          ? Text(
              _customPath!,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
    );

    final appCard = _buildOptionCard(
      title: l10n.storageLocationApp,
      subtitle: l10n.storageLocationAppDesc,
      icon: Icons.phone_android,
      selected: _location == StorageLocation.app,
      onTap: _selectApp,
    );

    final iCloudCard = _buildOptionCard(
      title: l10n.storageLocationICloud,
      subtitle: _icloudAvailable
          ? l10n.storageLocationICloudDesc
          : l10n.icloudRequiresCapability,
      icon: Icons.cloud_outlined,
      selected: _location == StorageLocation.icloud,
      onTap: _selectICloud,
      enabled: _icloudAvailable,
    );

    if (Platform.isIOS) {
      // iOS priority: iCloud -> app storage
      add(iCloudCard);
      add(appCard);
    } else {
      // Android priority: custom folder -> app storage
      add(customCard);
      add(appCard);
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dataStorage),
      ),
      bottomNavigationBar: widget.onboardingMode
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    UserStorage.l10n.startUsing,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: _loading
          ? Center(child: AgentLogoLoading())
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
                    if (!Platform.isIOS &&
                        _customPath != null &&
                        _customPath!.isNotEmpty)
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
                    ..._buildStorageOptions(l10n),
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
