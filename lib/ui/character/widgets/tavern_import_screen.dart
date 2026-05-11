import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:memex/data/services/tavern_character_import_service.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/core/widgets/back_button.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';

/// Screen for importing SillyTavern character cards (PNG or JSON).
class TavernImportScreen extends StatefulWidget {
  const TavernImportScreen({super.key});

  @override
  State<TavernImportScreen> createState() => _TavernImportScreenState();
}

class _TavernImportScreenState extends State<TavernImportScreen> {
  String? _selectedFilePath;
  Map<String, dynamic>? _preview;
  Map<String, dynamic>? _conflicts;
  bool _isLoading = false;
  bool _isImporting = false;
  bool _setPrimaryCompanion = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'png'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    await _loadPreview(path);
  }

  Future<void> _pickFromGallery() async {
    if (!mounted) return;
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.image,
      ),
    );
    if (result == null || result.isEmpty) return;
    final file = await result.first.file;
    if (file == null) return;
    await _loadPreview(file.path);
  }

  Future<void> _loadPreview(String path) async {
    setState(() {
      _selectedFilePath = path;
      _preview = null;
      _conflicts = null;
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final service = TavernCharacterImportService.instance;
      final preview = await service.previewFromFile(filePath: path);
      final userId = await UserStorage.getUserId();
      Map<String, dynamic>? conflicts;
      if (userId != null) {
        conflicts =
            await service.detectConflicts(userId: userId, filePath: path);
      }
      if (mounted) {
        setState(() {
          _preview = preview;
          _conflicts = conflicts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _doImport() async {
    if (_selectedFilePath == null) return;
    final userId = await UserStorage.getUserId();
    if (userId == null) return;

    setState(() => _isImporting = true);

    try {
      final character =
          await TavernCharacterImportService.instance.importFromFile(
        userId: userId,
        filePath: _selectedFilePath!,
        setPrimaryCompanion: _setPrimaryCompanion,
      );
      if (mounted) {
        setState(() => _isImporting = false);
        ToastHelper.showSuccess(
          context,
          UserStorage.l10n.importSuccess(character.name),
        );
        Navigator.of(context).pop(character);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _errorMessage = e.toString();
        });
        ToastHelper.showError(
            context, UserStorage.l10n.importFailed(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          UserStorage.l10n.importCharacterCard,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: const AppBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildDescription(),
          const SizedBox(height: 24),
          _buildPickFileButton(),
          if (_isLoading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorCard(),
          ],
          if (_preview != null && !_isLoading) ...[
            const SizedBox(height: 24),
            _buildPreviewCard(),
            if (_conflicts != null &&
                (_conflicts!['has_conflict'] as bool? ?? false)) ...[
              const SizedBox(height: 16),
              _buildConflictWarning(),
            ],
            const SizedBox(height: 16),
            _buildOptions(),
            const SizedBox(height: 24),
            _buildImportButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 18, color: AppColors.primary.withValues(alpha: 0.8)),
              const SizedBox(width: 8),
              Text(
                UserStorage.l10n.supportedFormats,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            UserStorage.l10n.tavernImportDescription,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickFileButton() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _isImporting ? null : _pickFromGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(UserStorage.l10n.selectFromAlbum),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _isImporting ? null : _pickFile,
              icon: const Icon(Icons.file_upload_outlined),
              label: Text(
                _selectedFilePath == null
                    ? UserStorage.l10n.pickCharacterFile
                    : UserStorage.l10n.repickFile,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: Colors.red[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(fontSize: 13, color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final name = _preview!['name'] as String? ?? 'Unknown';
    final tags = (_preview!['tags'] as List?)?.cast<String>() ?? [];
    final personaPreview = _preview!['persona_preview'] as String? ?? '';
    final firstMessage = _preview!['first_message'] as String? ?? '';
    final systemPrompt = _preview!['system_prompt_override'] as String? ?? '';
    final postHistory = _preview!['post_history_instructions'] as String? ?? '';
    final mesExample = _preview!['mes_example'] as String? ?? '';
    final worldEntriesCount = (_preview!['world_entries_count'] as int?) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          tags.join(' · '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (personaPreview.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildPreviewSection(
                UserStorage.l10n.personaSettingSection, personaPreview),
          ],
          if (firstMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPreviewSection(
                UserStorage.l10n.firstMessageLabel, firstMessage),
          ],
          if (systemPrompt.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPreviewSection(
                UserStorage.l10n.systemPromptSection, systemPrompt),
          ],
          if (postHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPreviewSection(
                UserStorage.l10n.postHistoryInstructionsLabel, postHistory),
          ],
          if (mesExample.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPreviewSection(UserStorage.l10n.mesExampleLabel, mesExample),
          ],
          if (worldEntriesCount > 0) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.book_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  UserStorage.l10n.worldEntriesCount(worldEntriesCount),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          // Show file path
          const SizedBox(height: 12),
          Text(
            _selectedFilePath != null
                ? UserStorage.l10n.fileLabel(_selectedFilePath!.split('/').last)
                : '',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(maxHeight: 120),
          child: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConflictWarning() {
    final sameNameChars = (_conflicts!['same_name_characters'] as List?) ?? [];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 18, color: Colors.orange[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              UserStorage.l10n.conflictWarning(
                  sameNameChars.map((c) => c['name']).join(', ')),
              style: TextStyle(fontSize: 13, color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          UserStorage.l10n.setPrimaryCompanionTitle,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          UserStorage.l10n.setPrimaryCompanionSubtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        value: _setPrimaryCompanion,
        onChanged: (v) => setState(() => _setPrimaryCompanion = v),
        activeTrackColor: AppColors.primary,
      ),
    );
  }

  Widget _buildImportButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isImporting ? null : _doImport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isImporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                UserStorage.l10n.confirmImport,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
