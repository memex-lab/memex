import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'local_server_service.dart';

/// Google OAuth constants (from Gemini CLI)
const _clientId =
    '681255809395-oo8ft2oprdrnp9e3aqf6av3hmdib135j.apps.googleusercontent.com';
const _clientSecret = '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';
const _redirectUri = 'http://localhost:8085/oauth2callback';
const _scopes = [
  'https://www.googleapis.com/auth/cloud-platform',
  'https://www.googleapis.com/auth/userinfo.email',
  'https://www.googleapis.com/auth/userinfo.profile',
];

class GeminiAuthService {
  static final Logger _logger = Logger('GeminiAuthService');

  static String _generateRandomString(int length) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  static Future<void> startAuthFlow({
    required void Function() onStart,
    required void Function(String email) onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      onStart();

      final state = _generateRandomString(32);
      final codeVerifier = _generateRandomString(64);
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      final authUrl =
          Uri.parse('https://accounts.google.com/o/oauth2/v2/auth').replace(
        queryParameters: {
          'client_id': _clientId,
          'response_type': 'code',
          'redirect_uri': _redirectUri,
          'scope': _scopes.join(' '),
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'state': state,
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );

      final completer = Completer<Map<String, String>?>();

      // Redirect URI is localhost:8085; ensure that port is listening before opening browser.
      await LocalServerService.ensureGeminiPort();

      LocalServerService.setGeminiAuthCallback((Uri uri) {
        if (uri.path != '/oauth2callback') return null;

        if (uri.queryParameters.containsKey('error')) {
          completer.completeError(uri.queryParameters['error_description'] ??
              uri.queryParameters['error'] ??
              'Unknown error');
          return 'Authorization failed. You can close this window.';
        }

        if (uri.queryParameters['state'] != state) {
          completer.completeError('State mismatch (possible CSRF attempt)');
          return 'Invalid state. Please try again.';
        }

        final code = uri.queryParameters['code'];
        if (code != null && !completer.isCompleted) {
          completer.complete({'code': code});
          return '''
            <html>
              <body style="font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0">
                <div style="text-align:center">
                  <h2>Authorization successful!</h2>
                  <p>You can close this window and return to Memex.</p>
                  <script>setTimeout(() => window.close(), 500);</script>
                </div>
              </body>
            </html>
          ''';
        }

        completer.completeError('No code in callback');
        return 'Invalid callback. Missing code.';
      });

      if (!await launchUrl(authUrl, mode: LaunchMode.inAppBrowserView)) {
        throw Exception('Could not launch browser for OAuth');
      }

      final result = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw TimeoutException('Authorization timed out'),
      );

      LocalServerService.clearGeminiAuthCallback();
      try {
        await closeInAppWebView();
      } catch (_) {}

      if (result == null) {
        onError('Authorization cancelled');
        return;
      }

      // Exchange code for tokens
      _logger.info('Exchanging code for tokens...');
      final tokenResponse = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'code': result['code']!,
          'grant_type': 'authorization_code',
          'redirect_uri': _redirectUri,
          'code_verifier': codeVerifier,
        },
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception(
            'Token exchange failed: ${tokenResponse.statusCode} ${tokenResponse.body}');
      }

      final data = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 3600;
      final expiresAt =
          DateTime.now().millisecondsSinceEpoch + expiresIn * 1000;

      if (accessToken == null || refreshToken == null) {
        throw Exception('Missing tokens in response');
      }

      // Fetch user email
      String? email;
      try {
        final userInfoResponse = await http.get(
          Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo?alt=json'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );
        if (userInfoResponse.statusCode == 200) {
          final userInfo =
              jsonDecode(userInfoResponse.body) as Map<String, dynamic>;
          email = userInfo['email'] as String?;
        }
      } catch (e) {
        _logger.warning('Failed to fetch user info: $e');
      }

      await _saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        email: email ?? '',
        expiresAt: expiresAt,
      );

      onSuccess(email ?? 'Google Account');
    } catch (e) {
      try {
        await closeInAppWebView();
      } catch (_) {}
      LocalServerService.clearGeminiAuthCallback();
      _logger.severe('Google OAuth error: $e');
      onError(e.toString());
    }
  }

  static Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required String email,
    required int expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_access_token', accessToken);
    await prefs.setString('gemini_refresh_token', refreshToken);
    await prefs.setString('gemini_email', email);
    await prefs.setInt('gemini_expires_at', expiresAt);
  }

  static Future<Map<String, dynamic>?> getSavedTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('gemini_access_token');
    final refreshToken = prefs.getString('gemini_refresh_token');
    final email = prefs.getString('gemini_email');
    final expiresAt = prefs.getInt('gemini_expires_at');

    if (accessToken == null || refreshToken == null) return null;

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'email': email ?? '',
      'expiresAt': expiresAt,
    };
  }

  /// Returns a valid access token, refreshing if expired.
  static Future<String?> getValidAccessToken() async {
    final tokens = await getSavedTokens();
    if (tokens == null) return null;

    final expiresAt = tokens['expiresAt'] as int?;
    final now = DateTime.now().millisecondsSinceEpoch;
    // Refresh 60s before expiry
    if (expiresAt != null && expiresAt > now + 60000) {
      return tokens['accessToken'] as String;
    }

    // Refresh
    return await _refreshAccessToken(tokens['refreshToken'] as String);
  }

  static Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
      );

      if (response.statusCode != 200) {
        _logger.warning('Token refresh failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String?;
      final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 3600;
      final expiresAt =
          DateTime.now().millisecondsSinceEpoch + expiresIn * 1000;

      if (newAccessToken == null) return null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gemini_access_token', newAccessToken);
      await prefs.setInt('gemini_expires_at', expiresAt);
      // Rotate refresh token if provided
      if (data['refresh_token'] != null) {
        await prefs.setString(
            'gemini_refresh_token', data['refresh_token'] as String);
      }

      return newAccessToken;
    } catch (e) {
      _logger.severe('Failed to refresh token: $e');
      return null;
    }
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gemini_access_token');
    await prefs.remove('gemini_refresh_token');
    await prefs.remove('gemini_email');
    await prefs.remove('gemini_expires_at');
    await prefs.remove('gemini_project_id');
  }

  /// Persist the resolved GCP project ID for Cloud Code Assist.
  static Future<void> saveProjectId(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_project_id', projectId);
  }

  static Future<String?> getProjectId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gemini_project_id');
  }
}
