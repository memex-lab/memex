import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/media_service.dart';
import 'package:memex/routing/routes.dart';
import 'package:memex/ui/character/view_models/character_viewmodel.dart';
import 'package:memex/ui/core/widgets/character_avatar.dart';
import 'package:memex/ui/core/widgets/avatar_picker.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/main_screen/widgets/chat_input_bar.dart';
import 'package:memex/ui/core/widgets/back_button.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

/// AI character config screen. Receives [viewModel] from parent (Compass-style).
class CharacterConfigScreen extends StatefulWidget {
  const CharacterConfigScreen({super.key, required this.viewModel});

  final CharacterViewModel viewModel;

  @override
  State<CharacterConfigScreen> createState() => _CharacterConfigScreenState();
}

class _CharacterConfigScreenState extends State<CharacterConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.viewModel.loadCharacters().catchError((e) {
        if (mounted) {
          ToastHelper.showError(
              context, UserStorage.l10n.loadCharacterFailed(e.toString()));
        }
      });
    });
  }

  Future<void> _toggleCharacterEnabled(
      CharacterViewModel vm, CharacterModel character, bool enabled) async {
    try {
      await vm.setCharacterEnabled(character, enabled);
      if (mounted) {
        ToastHelper.showSuccess(context,
            enabled ? UserStorage.l10n.enabled : UserStorage.l10n.disabled);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
            context, UserStorage.l10n.operationFailed(e.toString()));
      }
    }
  }

  Future<void> _deleteCharacter(
      CharacterViewModel vm, CharacterModel character) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(UserStorage.l10n.confirmDelete),
        content: Text(UserStorage.l10n.confirmDeleteCharacter(character.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(UserStorage.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await vm.deleteCharacter(character);
        if (mounted) {
          ToastHelper.showSuccess(context, UserStorage.l10n.deleteSuccess);
        }
      } catch (e) {
        if (mounted) {
          ToastHelper.showError(
              context, UserStorage.l10n.deleteFailed(e.toString()));
        }
      }
    }
  }

  Future<void> _showAddCharacterDialog(CharacterViewModel vm) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CharacterEditPage(),
      ),
    );
    if (result == true && mounted) vm.loadCharacters();
  }

  Future<void> _showEditCharacterDialog(
      CharacterViewModel vm, CharacterModel character) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterEditPage(character: character),
      ),
    );
    if (result == true && mounted) vm.loadCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            title: Text(
              UserStorage.l10n.configureAiCharacter,
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
            actions: [
              IconButton(
                icon: const Icon(Icons.download_rounded, size: 24),
                onPressed: () async {
                  final result = await context.push(AppRoutes.tavernImport);
                  if (result != null && mounted) vm.loadCharacters();
                },
                color: AppColors.primary,
                tooltip: UserStorage.l10n.importCharacterCard,
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 24),
                onPressed: () => _showAddCharacterDialog(vm),
                color: AppColors.primary,
                tooltip: UserStorage.l10n.addCharacter,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Text(
                      UserStorage.l10n.addCharacterSubtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: vm.isLoading
                        ? const Center(child: AgentLogoLoading())
                        : vm.characters.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_off_outlined,
                                        size: 48, color: Colors.grey[300]),
                                    const SizedBox(height: 16),
                                    Text(
                                      UserStorage.l10n.noCharacters,
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: vm.characters.length,
                                itemBuilder: (context, index) {
                                  final character = vm.characters[index];
                                  return _buildCharacterItem(vm, character);
                                },
                              ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: ChatInputBar(
                    hintText: UserStorage.l10n.characterDesignerHint,
                    agentName: 'persona_agent',
                    dialogTitle: UserStorage.l10n.characterDesigner,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCharacterItem(CharacterViewModel vm, CharacterModel character) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF7F8FA)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditCharacterDialog(vm, character),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CharacterAvatar(
                  avatar: character.avatar,
                  name: character.name,
                  size: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        character.tags.isNotEmpty
                            ? character.tags.join('  ·  ')
                            : UserStorage.l10n.noTags,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 32,
                      child: Transform.scale(
                        scale: 0.9,
                        alignment: Alignment.centerRight,
                        child: Switch(
                          value: character.enabled,
                          onChanged: (enabled) =>
                              _toggleCharacterEnabled(vm, character, enabled),
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _deleteCharacter(vm, character),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 14,
                              color: Colors.red[300],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              UserStorage.l10n.delete,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[300],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Character edit page (create / edit)
class CharacterEditPage extends StatefulWidget {
  final CharacterModel? character;

  const CharacterEditPage({super.key, this.character});

  @override
  State<CharacterEditPage> createState() => _CharacterEditPageState();
}

class _CharacterEditPageState extends State<CharacterEditPage> {
  final Logger _logger = getLogger('CharacterEditPage');
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagsController = TextEditingController();
  final _personaController = TextEditingController();
  final _firstMessageController = TextEditingController();
  final _systemPromptController = TextEditingController();
  final _postHistoryController = TextEditingController();
  final _mesExampleController = TextEditingController();
  bool _isSaving = false;
  bool _allowImmediatePop = false;

  String _avatarValueForSave = '';
  String _avatarPreview = '';
  bool _hasPickedAvatar = false;
  String? _chatBackgroundValue;
  String? _chatBackgroundPreview;

  // World book entries and memory entries (loaded from CharacterMemoryService)
  List<Map<String, dynamic>> _worldEntries = [];
  List<Map<String, dynamic>> _memoryEntries = [];

  @override
  void initState() {
    super.initState();
    if (widget.character != null) {
      _nameController.text = widget.character!.name;
      _tagsController.text = widget.character!.tags.join(', ');
      _personaController.text = widget.character!.persona;
      _firstMessageController.text = widget.character!.firstMessage ?? '';
      _systemPromptController.text =
          widget.character!.systemPromptOverride ?? '';
      _postHistoryController.text =
          widget.character!.postHistoryInstructions ?? '';
      _mesExampleController.text = widget.character!.mesExample ?? '';
      _avatarValueForSave = widget.character!.avatar ?? '';
      _avatarPreview = widget.character!.avatar ?? '';
      _hasPickedAvatar = widget.character!.avatar != null &&
          widget.character!.avatar!.isNotEmpty;
      _chatBackgroundValue = widget.character!.chatBackground;
      _chatBackgroundPreview = widget.character!.chatBackground;
      _loadCharacterData();
    }
    if (_avatarValueForSave.isEmpty) {
      _avatarValueForSave = 'companion_${_nameController.text}';
    }
    if (_avatarPreview.isEmpty) {
      _avatarPreview = _avatarValueForSave;
    }
    _nameController.addListener(_onNameChanged);
  }

  Future<void> _loadCharacterData() async {
    final userId = await UserStorage.getUserId();
    if (userId == null || widget.character == null) return;
    final characterId = widget.character!.id;
    final svc = CharacterMemoryService.instance;
    final world = await svc.loadWorldEntries(userId, characterId);
    final memory = await svc.loadMemoryEntries(userId, characterId);
    if (mounted) {
      setState(() {
        _worldEntries = world;
        _memoryEntries = memory;
      });
    }
  }

  void _onNameChanged() {
    // Only auto-derive avatar from name if user hasn't explicitly picked one
    if (!_hasPickedAvatar) {
      final seed = 'companion_${_nameController.text}';
      setState(() {
        _avatarValueForSave = seed;
        _avatarPreview = seed;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _tagsController.dispose();
    _personaController.dispose();
    _firstMessageController.dispose();
    _systemPromptController.dispose();
    _postHistoryController.dispose();
    _mesExampleController.dispose();
    super.dispose();
  }

  void _pickAvatar() async {
    final picked = await showAvatarPicker(
      context,
      _avatarPreview,
      onPickGallery: _pickImageFromGallery,
    );
    if (picked != null && mounted) {
      setState(() {
        _avatarValueForSave = picked;
        if (!CharacterService.isRelativeAvatarPath(picked)) {
          _avatarPreview = picked;
        }
        _hasPickedAvatar = true;
      });
    }
  }

  Future<String?> _pickImageFromGallery() async {
    try {
      final pickedPath = await pickAvatarImageFromGallery();
      if (pickedPath == null) return null;

      final userId = await UserStorage.getUserId();
      if (userId == null) return null;

      final imported = await MediaService.instance.importImage(
        userId: userId,
        sourcePath: pickedPath,
      );
      if (!mounted) return null;
      setState(() {
        _avatarPreview = imported.absolutePath;
      });
      return imported.relativePath;
    } catch (e) {
      _logger.warning('Failed to pick avatar image: $e');
      if (mounted) {
        ToastHelper.showError(
            context, UserStorage.l10n.operationFailed(e.toString()));
      }
      return null;
    }
  }

  Future<void> _pickChatBackground() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (picked == null) return;

      final userId = await UserStorage.getUserId();
      if (userId == null) return;

      final imported = await MediaService.instance.importImage(
        userId: userId,
        sourcePath: picked.path,
      );
      if (!mounted) return;
      setState(() {
        _chatBackgroundValue = imported.relativePath;
        _chatBackgroundPreview = imported.absolutePath;
      });
    } catch (e) {
      _logger.warning('Failed to pick chat background: $e');
      if (mounted) {
        ToastHelper.showError(
            context, UserStorage.l10n.operationFailed(e.toString()));
      }
    }
  }

  void _removeChatBackground() {
    setState(() {
      _chatBackgroundValue = null;
      _chatBackgroundPreview = null;
    });
  }

  Widget _buildChatBackgroundPicker() {
    final preview = _chatBackgroundPreview;
    final hasBackground =
        preview != null && preview.isNotEmpty && File(preview).existsSync();

    return GestureDetector(
      onTap: _pickChatBackground,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          image: hasBackground
              ? DecorationImage(
                  image: LocalImage.provider(preview),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasBackground
            ? Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: _removeChatBackground,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 32, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      UserStorage.l10n.chooseChatBackgroundImage,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final avatarSeed =
          _avatarValueForSave.isEmpty ? null : _avatarValueForSave;

      final userId = await UserStorage.getUserId();
      if (userId == null) return;

      final updates = <String, dynamic>{
        'name': _nameController.text.trim(),
        'tags': tags,
        'persona': _personaController.text.trim(),
        'avatar': avatarSeed,
        'first_message': _firstMessageController.text.trim().isEmpty
            ? null
            : _firstMessageController.text.trim(),
        'system_prompt_override': _systemPromptController.text.trim().isEmpty
            ? null
            : _systemPromptController.text.trim(),
        'post_history_instructions': _postHistoryController.text.trim().isEmpty
            ? null
            : _postHistoryController.text.trim(),
        'mes_example': _mesExampleController.text.trim().isEmpty
            ? null
            : _mesExampleController.text.trim(),
        'chat_background': _chatBackgroundValue,
      };

      if (widget.character == null) {
        final created = await CharacterService.instance.createCharacter(
          userId: userId,
          characterData: updates..['enabled'] = true,
        );
        // Save world entries and memory entries for new character
        if (_worldEntries.isNotEmpty) {
          await CharacterMemoryService.instance
              .replaceWorldEntries(userId, created.id, _worldEntries);
        }
        if (_memoryEntries.isNotEmpty) {
          await CharacterMemoryService.instance
              .replaceMemoryEntries(userId, created.id, _memoryEntries);
        }
      } else {
        await CharacterService.instance.updateCharacter(
          userId: userId,
          characterId: widget.character!.id,
          updates: updates,
        );
        // Save world entries and memory entries
        await CharacterMemoryService.instance
            .replaceWorldEntries(userId, widget.character!.id, _worldEntries);
        await CharacterMemoryService.instance
            .replaceMemoryEntries(userId, widget.character!.id, _memoryEntries);
      }

      if (mounted) {
        _allowImmediatePop = true;
        ToastHelper.showSuccess(
            context,
            widget.character == null
                ? UserStorage.l10n.createSuccess
                : UserStorage.l10n.updateSuccess);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _logger.severe('Error saving character: $e', e);
      if (mounted) {
        setState(() => _isSaving = false);
        ToastHelper.showError(
            context, UserStorage.l10n.saveFailed(e.toString()));
      }
    }
  }

  Future<bool> _showDiscardDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.discardChangesTitle),
        content: Text(UserStorage.l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(UserStorage.l10n.discardButton),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _handleBackNavigation() async {
    if (_allowImmediatePop) {
      Navigator.of(context).pop();
      return;
    }

    final shouldPop = await _showDiscardDialog();
    if (shouldPop && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowImmediatePop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && context.mounted) {
          _allowImmediatePop = true;
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.character == null
                ? UserStorage.l10n.newCharacter
                : UserStorage.l10n.editCharacter,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          elevation: 0,
          leading: AppBackButton(onTap: _handleBackNavigation),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _isSaving ? null : _save,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        UserStorage.l10n.save,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Avatar — tap to change
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2.5,
                          ),
                        ),
                        child: CharacterAvatar(
                          key: ValueKey(_avatarPreview),
                          avatar:
                              _avatarPreview.isEmpty ? null : _avatarPreview,
                          name: _nameController.text,
                          size: 82,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit,
                              size: 13, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            UserStorage.l10n.chooseAvatar,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel(UserStorage.l10n.characterName),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration:
                    _buildInputDecoration(UserStorage.l10n.characterNameHint),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return UserStorage.l10n.pleaseEnterCharacterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildLabel(UserStorage.l10n.tagsLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tagsController,
                style: const TextStyle(fontSize: 16),
                decoration: _buildInputDecoration(UserStorage.l10n.tagsHint),
              ),
              const SizedBox(height: 24),
              // Chat background image picker
              _buildLabel(UserStorage.l10n.chatBackground),
              const SizedBox(height: 8),
              _buildChatBackgroundPicker(),
              const SizedBox(height: 24),
              _buildLabel(UserStorage.l10n.characterPersonaLabel),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextFormField(
                  controller: _personaController,
                  decoration: InputDecoration(
                    hintText: UserStorage.l10n.characterPersonaHint,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF334155),
                  ),
                  maxLines: null,
                  minLines: 15,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return UserStorage.l10n.pleaseEnterCharacterPersona;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel(UserStorage.l10n.firstMessageLabel),
              const SizedBox(height: 8),
              _buildMultilineField(
                controller: _firstMessageController,
                hint: UserStorage.l10n.firstMessageHint,
                minLines: 3,
              ),
              const SizedBox(height: 24),
              _buildLabel(UserStorage.l10n.systemPromptOverrideLabel),
              const SizedBox(height: 8),
              _buildMultilineField(
                controller: _systemPromptController,
                hint: UserStorage.l10n.systemPromptOverrideHint,
                minLines: 4,
              ),
              const SizedBox(height: 24),
              _buildLabel(UserStorage.l10n.postHistoryInstructionsLabel),
              const SizedBox(height: 8),
              _buildMultilineField(
                controller: _postHistoryController,
                hint: UserStorage.l10n.postHistoryInstructionsHint,
                minLines: 3,
              ),
              const SizedBox(height: 24),
              _buildLabel(UserStorage.l10n.mesExampleLabel),
              const SizedBox(height: 8),
              _buildMultilineField(
                controller: _mesExampleController,
                hint: UserStorage.l10n.mesExampleHint,
                minLines: 4,
              ),
              const SizedBox(height: 32),
              // --- World Book Section ---
              _buildSectionHeader(
                title: UserStorage.l10n.worldBookTitle,
                subtitle: UserStorage.l10n.worldBookSubtitle,
                onAdd: _addWorldEntry,
              ),
              const SizedBox(height: 8),
              ..._worldEntries
                  .asMap()
                  .entries
                  .map((e) => _buildWorldEntryTile(e.key, e.value)),
              const SizedBox(height: 24),
              // --- Character Memory Section ---
              _buildSectionHeader(
                title: UserStorage.l10n.characterMemoryTitle,
                subtitle: UserStorage.l10n.characterMemorySubtitle,
                onAdd: _addMemoryEntry,
              ),
              const SizedBox(height: 8),
              ..._memoryEntries
                  .asMap()
                  .entries
                  .map((e) => _buildMemoryEntryTile(e.key, e.value)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // World Book & Memory entry management
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 22),
          color: AppColors.primary,
          onPressed: onAdd,
          tooltip: UserStorage.l10n.addTooltip,
        ),
      ],
    );
  }

  void _addWorldEntry() {
    _showWorldEntryDialog(null, null);
  }

  void _addMemoryEntry() {
    _showMemoryEntryDialog(null, null);
  }

  Widget _buildWorldEntryTile(int index, Map<String, dynamic> entry) {
    final keys = ((entry['keys'] as List?) ?? []).join(', ');
    final comment = (entry['comment'] as String?) ?? '';
    final content = (entry['content'] as String?) ?? '';
    final enabled = entry['enabled'] != false;
    final constant = entry['constant'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF7F8FA) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: constant
              ? AppColors.primary.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (constant)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(UserStorage.l10n.constantBadge,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.primary)),
                ),
              Expanded(
                child: Text(
                  comment.isNotEmpty
                      ? comment
                      : (keys.isNotEmpty
                          ? keys
                          : UserStorage.l10n.worldEntryFallbackName(index + 1)),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _showWorldEntryDialog(index, entry),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: AppColors.textTertiary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => setState(() => _worldEntries.removeAt(index)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: Colors.red[300],
              ),
            ],
          ),
          if (keys.isNotEmpty && comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              UserStorage.l10n.keywordsPrefix(keys),
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoryEntryTile(int index, Map<String, dynamic> entry) {
    final label = (entry['label'] as String?) ?? '';
    final content = (entry['content'] as String?) ?? '';
    final salience = (entry['salience'] as num?)?.toDouble() ?? 0.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.isNotEmpty
                      ? label
                      : UserStorage.l10n.memoryFallbackName(index + 1),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${(salience * 100).round()}%',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textTertiary),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _showMemoryEntryDialog(index, entry),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: AppColors.textTertiary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => setState(() => _memoryEntries.removeAt(index)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: Colors.red[300],
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showWorldEntryDialog(
      int? index, Map<String, dynamic>? existing) async {
    final keysCtrl = TextEditingController(
        text: ((existing?['keys'] as List?) ?? []).join(', '));
    final commentCtrl =
        TextEditingController(text: existing?['comment'] as String? ?? '');
    final contentCtrl =
        TextEditingController(text: existing?['content'] as String? ?? '');
    bool constant = existing?['constant'] == true;
    bool enabled = existing?['enabled'] != false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(index == null
              ? UserStorage.l10n.addWorldEntry
              : UserStorage.l10n.editWorldEntry),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: commentCtrl,
                  decoration: InputDecoration(
                    labelText: UserStorage.l10n.commentTitleLabel,
                    hintText: UserStorage.l10n.entryDescriptionHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keysCtrl,
                  decoration: InputDecoration(
                    labelText: UserStorage.l10n.triggerKeywordsLabel,
                    hintText: UserStorage.l10n.triggerKeywordsHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  decoration: InputDecoration(
                    labelText: UserStorage.l10n.contentLabel,
                    hintText: UserStorage.l10n.worldEntryContentHint,
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: Text(UserStorage.l10n.constantBadge,
                            style: const TextStyle(fontSize: 13)),
                        value: constant,
                        onChanged: (v) =>
                            setDialogState(() => constant = v ?? false),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: Text(UserStorage.l10n.enabledCheckbox,
                            style: const TextStyle(fontSize: 13)),
                        value: enabled,
                        onChanged: (v) =>
                            setDialogState(() => enabled = v ?? true),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(UserStorage.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final keys = keysCtrl.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                Navigator.pop(ctx, {
                  'uid': existing?['uid'] ??
                      existing?['id'] ??
                      'entry_${DateTime.now().microsecondsSinceEpoch}',
                  'keys': keys,
                  'comment': commentCtrl.text.trim(),
                  'content': contentCtrl.text.trim(),
                  'constant': constant,
                  'enabled': enabled,
                });
              },
              child: Text(UserStorage.l10n.save),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (index != null) {
          _worldEntries[index] = result;
        } else {
          _worldEntries.add(result);
        }
      });
    }
  }

  Future<void> _showMemoryEntryDialog(
      int? index, Map<String, dynamic>? existing) async {
    final labelCtrl =
        TextEditingController(text: existing?['label'] as String? ?? '');
    final contentCtrl =
        TextEditingController(text: existing?['content'] as String? ?? '');
    double salience = (existing?['salience'] as num?)?.toDouble() ?? 0.5;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(index == null
              ? UserStorage.l10n.addMemory
              : UserStorage.l10n.editMemory),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelCtrl,
                  decoration: InputDecoration(
                    labelText: UserStorage.l10n.memoryLabelField,
                    hintText: UserStorage.l10n.memoryLabelHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  decoration: InputDecoration(
                    labelText: UserStorage.l10n.contentLabel,
                    hintText: UserStorage.l10n.memoryContentHint,
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(UserStorage.l10n.salienceLabel,
                        style: const TextStyle(fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: salience,
                        min: 0,
                        max: 1,
                        divisions: 10,
                        label: '${(salience * 100).round()}%',
                        onChanged: (v) => setDialogState(() => salience = v),
                      ),
                    ),
                    Text('${(salience * 100).round()}%',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(UserStorage.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (labelCtrl.text.trim().isEmpty) {
                  ToastHelper.showError(
                      ctx, UserStorage.l10n.labelCannotBeEmpty);
                  return;
                }
                Navigator.pop(ctx, {
                  'label': labelCtrl.text.trim(),
                  'content': contentCtrl.text.trim(),
                  'salience': salience,
                  'updated_at': DateTime.now().toIso8601String(),
                });
              },
              child: Text(UserStorage.l10n.save),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (index != null) {
          _memoryEntries[index] = result;
        } else {
          _memoryEntries.add(result);
        }
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Common UI helpers
  // ---------------------------------------------------------------------------

  Widget _buildMultilineField({
    required TextEditingController controller,
    required String hint,
    int minLines = 3,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: Color(0xFF334155),
        ),
        maxLines: null,
        minLines: minLines,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF7F8FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
    );
  }
}
