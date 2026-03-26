import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

class AppLockSettingsPage extends StatefulWidget {
  const AppLockSettingsPage({super.key});

  @override
  State<AppLockSettingsPage> createState() => _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends State<AppLockSettingsPage> {
  bool _isLockEnabled = false;
  bool _isBiometricsEnabled = false;
  bool _canCheckBiometrics = false;
  String _password = '';
  bool _isLoading = true;
  final Logger _logger = getLogger('AppLockSettingsPage');

  static const String _prefKeyLockEnabled = 'app_lock_enabled';
  static const String _prefKeyPassword = 'app_lock_password';
  static const String _prefKeyBiometricsEnabled = 'app_lock_biometrics_enabled';

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if device supports biometrics
    bool canCheckBio = false;
    try {
      canCheckBio =
          await auth.canCheckBiometrics && await auth.isDeviceSupported();
    } catch (e) {
      _logger.warning('Error checking biometrics: $e', e);
    }

    setState(() {
      _isLockEnabled = prefs.getBool(_prefKeyLockEnabled) ?? false;
      _password = prefs.getString(_prefKeyPassword) ?? '';
      _isBiometricsEnabled = prefs.getBool(_prefKeyBiometricsEnabled) ?? false;
      _canCheckBiometrics = canCheckBio;
      _isLoading = false;
    });
  }

  Future<void> _toggleLock(bool value) async {
    if (value && _password.isEmpty) {
      // Trying to enable but no password set
      _showSetPasswordDialog(enableAfterSet: true);
      return;
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyLockEnabled, value);

    if (mounted) {
      setState(() {
        _isLockEnabled = value;
        _isLoading = false;
      });
      ToastHelper.showSuccess(context,
          value ? UserStorage.l10n.appLockOn : UserStorage.l10n.appLockOff);
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value && !_isLockEnabled) {
      ToastHelper.showError(context, UserStorage.l10n.enableAppLockFirst);
      return;
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyBiometricsEnabled, value);

    if (mounted) {
      setState(() {
        _isBiometricsEnabled = value;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePassword(String newPassword) async {
    if (newPassword.length != 4) {
      ToastHelper.showError(context, UserStorage.l10n.enterFourDigitPassword);
      return;
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyPassword, newPassword);
    // Auto-enable lock if setting password for the first time or explicitly needed
    if (!_isLockEnabled) {
      await prefs.setBool(_prefKeyLockEnabled, true);
    }

    if (mounted) {
      setState(() {
        _password = newPassword;
        _isLockEnabled = true; // Auto enable
        _isLoading = false;
      });
      ToastHelper.showSuccess(context, UserStorage.l10n.passwordSetAndLockOn);
    }
  }

  void _showSetPasswordDialog({bool enableAfterSet = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SetPasswordSheet(
        onSave: (pwd) async {
          await _savePassword(pwd);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          UserStorage.l10n.appLockSettings,
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: _isLoading
          ? Center(child: AgentLogoLoading())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSettingCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          UserStorage.l10n.enableAppLock,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        subtitle: Text(
                          UserStorage.l10n.enableAppLockSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        value: _isLockEnabled,
                        onChanged: _toggleLock,
                        activeColor: const Color(0xFF6366F1),
                      ),
                      if (_canCheckBiometrics && _isLockEnabled) ...[
                        const Divider(height: 1),
                        SwitchListTile(
                          title: Text(
                            UserStorage.l10n.enableBiometrics,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          subtitle: Text(
                            UserStorage.l10n.biometricsSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          value: _isBiometricsEnabled,
                          onChanged: _toggleBiometrics,
                          activeColor: const Color(0xFF6366F1),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLockEnabled || _password.isNotEmpty)
                  _buildSettingCard(
                    child: ListTile(
                      title: Text(
                        UserStorage.l10n.changePassword,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showSetPasswordDialog(),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SetPasswordSheet extends StatefulWidget {
  final Function(String) onSave;

  const _SetPasswordSheet({required this.onSave});

  @override
  State<_SetPasswordSheet> createState() => _SetPasswordSheetState();
}

class _SetPasswordSheetState extends State<_SetPasswordSheet> {
  String _input = '';
  String _firstInput = '';
  bool _isConfirming = false;
  static const int _codeLength = 4;
  late String _title;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _title = UserStorage.l10n.setFourDigitPassword;
  }

  void _onKeyPress(String value) {
    if (_input.length < _codeLength) {
      setState(() {
        _input += value;
        _errorMessage = '';
      });
      HapticFeedback.lightImpact();

      if (_input.length == _codeLength) {
        if (!_isConfirming) {
          // First time entry complete, move to confirm
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              _firstInput = _input;
              _input = '';
              _isConfirming = true;
              _title = UserStorage.l10n.reenterPasswordToConfirm;
            });
          });
        } else {
          // Confirmation entry complete
          if (_input == _firstInput) {
            Future.delayed(const Duration(milliseconds: 200), () {
              widget.onSave(_input);
            });
          } else {
            // Mismatch
            HapticFeedback.heavyImpact();
            setState(() {
              _errorMessage = UserStorage.l10n.passwordMismatch;
              _input = '';
              _firstInput = '';
              _isConfirming = false; // Reset to start
              _title = UserStorage.l10n.setFourDigitPassword;
            });
          }
        }
      }
    }
  }

  void _onDelete() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
        _errorMessage = '';
      });
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            _title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 40),
          // Dots display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_codeLength, (index) {
              final isFilled = index < _input.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE2E8F0),
                ),
              );
            }),
          ),
          const Spacer(),
          // Numpad
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildKeyRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildKeyRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildKeyRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 72),
                      _buildKey('0'),
                      SizedBox(
                        width: 72,
                        child: GestureDetector(
                          onTap: _onDelete,
                          child: const Icon(Icons.backspace_outlined, size: 28),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String value) {
    return GestureDetector(
      onTap: () => _onKeyPress(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
