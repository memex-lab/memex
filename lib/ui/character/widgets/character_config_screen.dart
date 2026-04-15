import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/ui/character/view_models/character_viewmodel.dart';
import 'package:memex/ui/core/widgets/dicebear_avatar.dart';
import 'package:memex/ui/core/widgets/avatar_picker.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/main_screen/widgets/chat_input_bar.dart';
import 'package:memex/ui/core/widgets/back_button.dart';
import 'package:memex/ui/core/themes/app_colors.dart';

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
            title: const Text(
              'Configure AI character',
              style: TextStyle(
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
                DiceBearAvatar(
                  seed: character.avatar != null && character.avatar!.isNotEmpty
                      ? character.avatar!
                      : 'companion_${character.name}',
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
                          activeColor: Colors.white,
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
  bool _isSaving = false;

  String _avatarSeed = '';
  bool _hasPickedAvatar = false;

  @override
  void initState() {
    super.initState();
    if (widget.character != null) {
      _nameController.text = widget.character!.name;
      _tagsController.text = widget.character!.tags.join(', ');
      _personaController.text = widget.character!.persona;
      _avatarSeed = widget.character!.avatar ?? '';
      _hasPickedAvatar = widget.character!.avatar != null &&
          widget.character!.avatar!.isNotEmpty;
    }
    if (_avatarSeed.isEmpty) {
      _avatarSeed = 'companion_${_nameController.text}';
    }
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    // Only auto-derive avatar from name if user hasn't explicitly picked one
    if (!_hasPickedAvatar) {
      setState(() => _avatarSeed = 'companion_${_nameController.text}');
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _tagsController.dispose();
    _personaController.dispose();
    super.dispose();
  }

  void _pickAvatar() async {
    final picked = await showAvatarPicker(context, _avatarSeed);
    if (picked != null && mounted) {
      setState(() {
        _avatarSeed = picked;
        _hasPickedAvatar = true;
      });
    }
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

      final avatarSeed = _avatarSeed.isEmpty ? null : _avatarSeed;

      final userId = await UserStorage.getUserId();
      if (userId == null) return;

      if (widget.character == null) {
        await CharacterService.instance.createCharacter(
          userId: userId,
          characterData: {
            'name': _nameController.text.trim(),
            'tags': tags,
            'persona': _personaController.text.trim(),
            'avatar': avatarSeed,
          },
        );
      } else {
        await CharacterService.instance.updateCharacter(
          userId: userId,
          characterId: widget.character!.id,
          updates: {
            'name': _nameController.text.trim(),
            'tags': tags,
            'persona': _personaController.text.trim(),
            'avatar': avatarSeed,
          },
        );
      }

      if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        leading: const AppBackButton(),
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
                      child: DiceBearAvatar(
                        key: ValueKey(_avatarSeed),
                        seed: _avatarSeed,
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
            const SizedBox(height: 32),
          ],
        ),
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
