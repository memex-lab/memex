import 'package:flutter/material.dart';
import 'dart:ui' show PlatformDispatcher;
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/ui/user_setup/widgets/setup_model_config_page.dart';

/// User setup screen. Shown when user opens app for the first time or no local userId.
class UserSetupScreen extends StatefulWidget {
  final VoidCallback onUserCreated;

  const UserSetupScreen({
    super.key,
    required this.onUserCreated,
  });

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  bool _isSubmitting = false;
  String _selectedLang = 'en';
  String _selectedAvatar = UserStorage.avatarOptions[0];

  @override
  void initState() {
    super.initState();
    _detectSystemLanguage();
    _loadExistingUserId();
    _loadExistingAvatar();
  }

  void _detectSystemLanguage() {
    final systemLocale = PlatformDispatcher.instance.locale;
    final langCode = systemLocale.languageCode;
    setState(() {
      _selectedLang = (langCode == 'zh') ? 'zh' : 'en';
    });
    _applyLanguage(_selectedLang);
  }

  Future<void> _loadExistingUserId() async {
    final existingId = await UserStorage.getUserId();
    if (existingId != null && existingId.isNotEmpty && mounted) {
      _userIdController.text = existingId;
    }
  }

  Future<void> _loadExistingAvatar() async {
    final avatar = await UserStorage.getUserAvatar();
    if (avatar != null && mounted) {
      setState(() => _selectedAvatar = avatar);
    }
  }

  Future<void> _applyLanguage(String langCode) async {
    final locale = Locale(langCode);
    await UserStorage.setLocale(locale);
    await UserStorage.initL10n();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _userIdController.text.trim();
    setState(() => _isSubmitting = true);

    try {
      await UserStorage.saveUser(userId);
      await UserStorage.saveUserAvatar(_selectedAvatar);

      final configs = await UserStorage.getLLMConfigs();
      final defaultConfig = configs.firstWhere(
        (c) => c.key == LLMConfig.defaultClientKey,
        orElse: () => LLMConfig.createDefaultClient(),
      );

      if (mounted) {
        if (defaultConfig.isValid) {
          ToastHelper.showSuccess(context, UserStorage.l10n.userCreatedSuccess);
          widget.onUserCreated();
        } else {
          setState(() => _isSubmitting = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SetupModelConfigPage(
                config: defaultConfig,
                onComplete: () {
                  if (mounted) {
                    Navigator.pop(context);
                    ToastHelper.showSuccess(
                        context, UserStorage.l10n.userCreatedSuccess);
                    widget.onUserCreated();
                  }
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ToastHelper.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // ── Avatar ──
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1)
                                    .withValues(alpha: 0.1),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _selectedAvatar,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 13, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              UserStorage.l10n.chooseAvatar,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Title ──
                  Text(
                    UserStorage.l10n.welcomeToMemex,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    UserStorage.l10n.createUserIdToStart,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  // ── Settings Card ──
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF64748B).withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Language
                        _buildLanguageSelector(),

                        const SizedBox(height: 24),

                        // User ID
                        TextFormField(
                          controller: _userIdController,
                          decoration: InputDecoration(
                            labelText: UserStorage.l10n.userIdLabel,
                            hintText: UserStorage.l10n.userIdHint,
                            prefixIcon:
                                const Icon(Icons.person_outline, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6366F1),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return UserStorage.l10n.pleaseEnterUserId;
                            }
                            if (value.trim().length > 50) {
                              return UserStorage.l10n.userIdMaxLength;
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSubmit(),
                          enabled: !_isSubmitting,
                        ),

                        const SizedBox(height: 8),
                        Text(
                          UserStorage.l10n.userIdTip,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Submit Button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              UserStorage.l10n.startUsing,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                UserStorage.l10n.chooseAvatar,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: UserStorage.avatarOptions.length,
                itemBuilder: (context, index) {
                  final emoji = UserStorage.avatarOptions[index];
                  final isSelected = emoji == _selectedAvatar;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = emoji);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEEF2FF)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF6366F1), width: 2)
                            : Border.all(color: Colors.grey[200]!),
                      ),
                      child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        Icon(Icons.language, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Text(
          UserStorage.l10n.chooseLanguage,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        _buildLangChip('EN', 'en'),
        const SizedBox(width: 8),
        _buildLangChip('中文', 'zh'),
      ],
    );
  }

  Widget _buildLangChip(String label, String langCode) {
    final isSelected = _selectedLang == langCode;
    return GestureDetector(
      onTap: () {
        if (_selectedLang != langCode) {
          setState(() => _selectedLang = langCode);
          _applyLanguage(langCode);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
