import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:memex/utils/user_storage.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;

  const LockScreen({super.key, required this.onUnlock});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _input = '';
  static const int _codeLength = 4;
  final LocalAuthentication auth = LocalAuthentication();
  bool _isBiometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  Future<void> _initValues() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isBiometricsEnabled = prefs.getBool('app_lock_biometrics_enabled') ?? false;
      });
      if (_isBiometricsEnabled) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: UserStorage.l10n.useFingerprintToUnlock,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: UserStorage.l10n.locked,
            biometricHint: '',
            cancelButton: UserStorage.l10n.cancel,
          ),
        ],
      );

      if (didAuthenticate && mounted) {
        widget.onUnlock();
      }
    } on PlatformException catch (_) {
      // Handle error or cancellation
    }
  }

  void _onKeyPress(String value) {
    if (_input.length < _codeLength) {
      setState(() {
        _input += value;
      });
      HapticFeedback.lightImpact();

      if (_input.length == _codeLength) {
        _checkPassword();
      }
    }
  }

  Future<void> _checkPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString('app_lock_password') ?? '';
    
    if (storedPassword.isEmpty || _input == storedPassword) {
      // Success
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        widget.onUnlock();
        setState(() {
          _input = '';
        });
      });
    } else {
      // Failure
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        HapticFeedback.heavyImpact();
        setState(() {
          _input = ''; // Clear input on failure
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(UserStorage.l10n.wrongPassword),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _onDelete() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
      });
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Header
            const Icon(
              Icons.lock_outline,
              size: 48,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 24),
            Text(
              UserStorage.l10n.enterPassword,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            // Dots
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_codeLength, (index) {
                  final isFilled = index < _input.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFE2E8F0),
                      border: isFilled
                          ? null
                          : Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 1,
                            ),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(flex: 2),
            // Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  _buildKeyRow(['1', '2', '3']),
                  const SizedBox(height: 24),
                  _buildKeyRow(['4', '5', '6']),
                  const SizedBox(height: 24),
                  _buildKeyRow(['7', '8', '9']),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 72), // Empty placeholder
                      _buildKey('0'),
                      SizedBox(
                        width: 72,
                        child: GestureDetector(
                          onTap: _onDelete,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              UserStorage.l10n.cancel,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            // Biometric Icon
             if (_isBiometricsEnabled)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: GestureDetector(
                  onTap: _authenticate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF64748B).withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      size: 32,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 64), // Placeholder to keep spacing
          ],
        ),
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
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 24),
            Text(
              UserStorage.l10n.memexLocked,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
