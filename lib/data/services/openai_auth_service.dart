import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:logging/logging.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_server_service.dart';
import 'package:memex/utils/user_storage.dart';

class OpenAiAuthService {
  static final Logger _logger = Logger('OpenAiAuthService');

  static const String clientId = 'app_EMoamEEZ73f0CkXaXp7hrann';
  static const String issuer = 'https://auth.openai.com';
  static const int oauthPort = 1455;
  static const String redirectUri = 'http://localhost:$oauthPort/auth/callback';

  /// Generates a random string of a given length
  static String _generateRandomString(int length) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Generates the PKCE Code Challenge from the Verifier
  static String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    // Base64Url encode without padding as per PKCE spec
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Starts the browser PKCE flow
  static Future<void> startAuthFlow({
    required Function() onStart,
    required Function(String accountId) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      onStart();

      // 1. Generate State and PKCE Challenge
      final state = _generateRandomString(32);
      final codeVerifier = _generateRandomString(64);
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      // 2. Prepare Authorization URL
      final authUrl =
          Uri.parse('$issuer/oauth/authorize').replace(queryParameters: {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': 'openid profile email offline_access',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
        'id_token_add_organizations': 'true',
        'codex_cli_simplified_flow': 'true',
        'originator': 'opencode', // Or memex
        'state': state,
      });

      // 3. Setup Local Server Listener for Callback
      final completer = Completer<Map<String, String>?>();
      LocalServerService.setAuthCallback((Uri uri) {
        if (uri.path == '/cancel') {
          completer.complete(null); // Cancelled
          return 'Flow cancelled. You can close this window.';
        }

        if (uri.queryParameters['state'] != state) {
          completer.completeError('Invalid state received from callback');
          return 'Invalid state. Please try again.';
        }

        if (uri.queryParameters.containsKey('error')) {
          completer
              .completeError(uri.queryParameters['error'] ?? 'Unknown error');
          return 'Authorization failed: ${uri.queryParameters['error']}';
        }

        final code = uri.queryParameters['code'];
        if (code != null) {
          if (!completer.isCompleted) {
            completer.complete({'code': code});
          }
          final l10n = UserStorage.l10n;
          final title = l10n.oauthSuccessTitle;
          final msg = l10n.oauthSuccessMessage;
          return '''
            <html>
              <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <title>$title</title>
                <style>
                  body {
                    margin: 0;
                    height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-family: -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
                    background: #f9fafb;
                    color: #0f172a;
                  }
                  .card {
                    background: #ffffff;
                    border-radius: 16px;
                    padding: 24px 20px;
                    box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
                    max-width: 320px;
                    text-align: center;
                  }
                  .icon {
                    font-size: 32px;
                    margin-bottom: 12px;
                  }
                  h2 {
                    margin: 0 0 8px;
                    font-size: 20px;
                  }
                  p {
                    margin: 4px 0;
                    font-size: 14px;
                    color: #4b5563;
                  }
                </style>
              </head>
              <body>
                <div class="card">
                  <div class="icon">✅</div>
                  <h2>$title</h2>
                  <p>$msg</p>
                  <script>
                    setTimeout(function() { window.close(); }, 800);
                  </script>
                </div>
              </body>
            </html>
          ''';
        }

        completer.completeError('No code found in callback');
        return 'Invalid callback response. Missing code.';
      });

      // 4. Launch In-App Browser (prevents the app from going to the background and being killed by the OS)
      if (!await launchUrl(authUrl, mode: LaunchMode.inAppBrowserView)) {
        throw Exception('Could not launch browser for OAuth');
      }

      // 5. Wait for the Callback (with timeout)
      final result = await completer.future.timeout(const Duration(minutes: 5),
          onTimeout: () {
        throw TimeoutException('Authorization timed out');
      });

      // Cleanup listener
      LocalServerService.clearAuthCallback();

      // Close the in-app web view (if supported/open)
      try {
        await closeInAppWebView();
      } catch (_) {}

      if (result == null) {
        onError('Authorization cancelled by user');
        return;
      }

      final code = result['code']!;

      // 6. Exchange Code for Tokens
      _logger.info('Exchanging code for tokens...');
      final tokenResponse = await http.post(
        Uri.parse('$issuer/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'code_verifier': codeVerifier,
        },
      );

      if (tokenResponse.statusCode != 200) {
        _logger.severe('Token exchange failed: ${tokenResponse.body}');
        throw Exception('Failed to get token: ${tokenResponse.statusCode}');
      }

      _logger.info('Token exchange successful.');

      final data = jsonDecode(tokenResponse.body);
      final idToken = data['id_token'];
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];
      // The expiry is usually returned, let's keep track:
      final expiresInNum = data['expires_in'] ?? 3600;
      final expiresIn = expiresInNum is num
          ? expiresInNum.toInt()
          : int.parse(expiresInNum.toString());
      final expiresAt =
          DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);

      // 7. Extract Account ID
      String? accountId;

      // Try parsing id_token first
      if (idToken != null) {
        try {
          final jwt = JWT.decode(idToken);
          final payload = jwt.payload as Map<String, dynamic>;

          accountId = payload['chatgpt_account_id'];
          if (accountId == null &&
              payload.containsKey('https://api.openai.com/auth')) {
            accountId =
                payload['https://api.openai.com/auth']['chatgpt_account_id'];
          }
          if (accountId == null && payload.containsKey('organizations')) {
            final orgs = payload['organizations'] as List;
            if (orgs.isNotEmpty) {
              accountId = orgs[0]['id'];
            }
          }
        } catch (e) {
          _logger.warning('Failed to parse id_token: $e');
        }
      }

      // Fallback: try parsing access_token
      if (accountId == null && accessToken != null) {
        try {
          final jwt = JWT.decode(accessToken);
          final payload = jwt.payload as Map<String, dynamic>;
          accountId = payload['chatgpt_account_id'];
          if (accountId == null &&
              payload.containsKey('https://api.openai.com/auth')) {
            accountId =
                payload['https://api.openai.com/auth']['chatgpt_account_id'];
          }
        } catch (e) {
          _logger.warning('Failed to parse access_token: $e');
        }
      }

      if (accountId == null) {
        _logger.warning('Could not extract Account ID, using default');
        accountId = 'default_account'; // Don't crash, just use a placeholder
      }

      // 8. Securely Store Tokens
      _logger.info('--- OpenAI Auth Success Info ---');
      _logger.info('Account ID: $accountId');
      _logger.info('Access Token: $accessToken');
      _logger.info('Refresh Token: $refreshToken');
      _logger.info('ID Token: $idToken');
      _logger.info(
          'Expires At: ${DateTime.fromMillisecondsSinceEpoch(expiresAt)}');
      _logger.info('--------------------------------');

      await _saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        idToken: idToken,
        accountId: accountId,
        expiresAt: expiresAt,
      );

      onSuccess(accountId);
    } catch (e) {
      // Close the in-app web view on error as well
      try {
        await closeInAppWebView();
      } catch (_) {}

      _logger.severe('OAuth error: $e');
      LocalServerService.clearAuthCallback();
      onError(e.toString());
    }
  }

  static Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required String idToken,
    required String accountId,
    required int expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openai_access_token', accessToken);
    await prefs.setString('openai_refresh_token', refreshToken);
    await prefs.setString('openai_account_id', accountId);
    await prefs.setInt('openai_expires_at', expiresAt);
  }

  /// Get the saved tokens as a Map
  static Future<Map<String, dynamic>?> getSavedTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('openai_access_token');
    final refreshToken = prefs.getString('openai_refresh_token');
    final accountId = prefs.getString('openai_account_id');
    final expiresAt = prefs.getInt('openai_expires_at');

    if (accessToken == null || refreshToken == null || accountId == null) {
      return null;
    }

    return {
      'accountId': accountId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt,
    };
  }

  /// Clear the saved tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('openai_access_token');
    await prefs.remove('openai_refresh_token');
    await prefs.remove('openai_account_id');
    await prefs.remove('openai_expires_at');
  }

  /// Fetch available models using the models.dev API (matching opencode's approach)
  ///
  /// models.dev/api.json structure: { "openai": { "models": { "modelId": {...} } }, ... }
  /// We extract the "openai" provider's models, then filter to Codex-allowed ones.
  static Future<List<dynamic>> getModels() async {
    final tokens = await getSavedTokens();
    if (tokens == null) throw Exception('Unauthorized, please login first');

    _logger.info('Fetching models from models.dev/api.json...');
    final response = await http
        .get(Uri.parse('https://models.dev/api.json'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch model list: Status ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Extract the "openai" provider's models (same as opencode)
    final openaiProvider = data['openai'] as Map<String, dynamic>?;
    final openaiModels =
        (openaiProvider?['models'] as Map<String, dynamic>?) ?? {};

    // Allowed models whitelist (from opencode codex.ts)
    const allowedModels = {
      'gpt-5.2',
      'gpt-5.1-codex-max',
      'gpt-5.1-codex-mini',
      'gpt-5.2-codex',
      'gpt-5.3-codex',
      'gpt-5.1-codex',
      'gpt-5.4',
    };

    List<Map<String, dynamic>> finalModels = [];

    // Filter: keep models that contain "codex" in the id OR are in the allowedModels set
    openaiModels.forEach((modelId, modelInfo) {
      if (modelId.contains('codex') || allowedModels.contains(modelId)) {
        final info = modelInfo as Map<String, dynamic>;
        finalModels.add({
          'id': modelId,
          'name': info['name'] ?? modelId,
          'limit': info['limit'],
          'reasoning': info['reasoning'] ?? false,
          'cost': 0, // Codex models are free with ChatGPT subscription
        });
      }
    });

    // Manually inject gpt-5.3-codex if not present (same as opencode)
    if (!finalModels.any((m) => m['id'] == 'gpt-5.3-codex')) {
      finalModels.add({
        'id': 'gpt-5.3-codex',
        'name': 'GPT-5.3 Codex',
        'limit': {'context': 400000, 'input': 272000, 'output': 128000},
        'reasoning': true,
        'cost': 0,
      });
    }

    finalModels
        .sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
    return finalModels;
  }
}
