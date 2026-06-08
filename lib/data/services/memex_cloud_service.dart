import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Memex Cloud Service - 与 memex_server 通信的客户端
/// 处理用户认证、套餐购买、凭证获取等
class MemexCloudService {
  // TODO: 发布时改为实际域名
  static const String _baseUrl = 'https://www.memexlab.ai';

  static const String _keyAuthToken = 'memex_cloud_auth_token';
  static const String _keyUserId = 'memex_cloud_user_id';
  static const String _keyUsername = 'memex_cloud_username';

  static MemexCloudService? _instance;
  static MemexCloudService get instance => _instance ??= MemexCloudService._();

  MemexCloudService._();

  String? _authToken;
  int? _userId;

  /// 是否已登录
  bool get isLoggedIn => _authToken != null && _userId != null;

  /// 初始化（从本地存储恢复登录状态）
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_keyAuthToken);
    _userId = prefs.getInt(_keyUserId);
  }

  /// 获取存储的用户名
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // ============================================================
  // Auth
  // ============================================================

  /// 注册
  Future<AuthResult> register({
    required String username,
    required String password,
  }) async {
    final response = await _post('/api/auth/register', {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String?;
      final userId = data['userId'] as int?;
      if (token != null && userId != null) {
        await _saveAuth(token, userId, username);
        return AuthResult(success: true, username: username);
      }
    }
    if (response.statusCode == 409) {
      return AuthResult(success: false, error: 'Username already taken');
    }
    final data = jsonDecode(response.body);
    return AuthResult(
      success: false,
      error: data['error'] ?? 'Registration failed',
    );
  }

  /// 登录
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final response = await _post('/api/auth/login', {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String?;
      final userId = data['userId'] as int?;
      if (token != null && userId != null) {
        await _saveAuth(token, userId, username);
        return AuthResult(success: true, username: username);
      }
    }
    final data = jsonDecode(response.body);
    return AuthResult(success: false, error: data['error'] ?? 'Login failed');
  }

  /// 登出
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    _authToken = null;
    _userId = null;
  }

  // ============================================================
  // User Info
  // ============================================================

  /// 获取用户信息（余额、用量）
  Future<UserInfo?> getUserInfo() async {
    final response = await _get('/api/user/self', authenticated: true);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserInfo.fromJson(data);
    }
    return null;
  }

  // ============================================================
  // Plans
  // ============================================================

  /// 获取可用套餐列表
  Future<List<dynamic>> getPlans() async {
    final response = await _get('/api/plans', authenticated: true);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['plans'] as List? ?? [];
    }
    return [];
  }

  // ============================================================
  // Payments
  // ============================================================

  /// 创建 Stripe 充值支付（返回 Checkout URL）
  Future<PaymentResult> createStripePayment(int amount) async {
    final response = await _post(
        '/api/payments/stripe',
        {
          'amount': amount,
          'payment_method': 'stripe',
        },
        authenticated: true);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentResult(success: true, checkoutUrl: data['checkoutUrl']);
    }
    final data = jsonDecode(response.body);
    return PaymentResult(
      success: false,
      error: data['error'] ?? 'Payment creation failed',
    );
  }

  /// 创建订阅制支付
  Future<PaymentResult> createSubscriptionPayment(
    Map<String, dynamic> body,
  ) async {
    final response = await _post(
      '/api/payments/subscription',
      body,
      authenticated: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentResult(success: true, checkoutUrl: data['checkoutUrl']);
    }
    final data = jsonDecode(response.body);
    return PaymentResult(
      success: false,
      error: data['error'] ?? 'Payment creation failed',
    );
  }

  // ============================================================
  // Credentials (核心：获取 LLM API 凭证)
  // ============================================================

  /// 获取 LLM API 凭证
  /// 返回 baseUrl + apiKey，App 直接用于配置 LLM
  Future<CredentialResult?> getCredentials() async {
    final response = await _get('/api/credentials', authenticated: true);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CredentialResult.fromJson(data);
    }
    return null;
  }

  /// 获取使用日志（分页）
  Future<LogsResult> getLogs({int page = 1, int pageSize = 20}) async {
    final response = await _get(
      '/api/logs?page=$page&page_size=$pageSize',
      authenticated: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LogsResult.fromJson(data);
    }
    return LogsResult(items: [], total: 0);
  }

  /// 获取 App 配置（文案、充值估算等非敏感配置）
  Future<AppConfigResult?> getAppConfig({required String locale}) async {
    final response = await _get(
      '/api/app-config?locale=${Uri.encodeQueryComponent(locale)}',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['code'] == 0 && data['data'] is Map<String, dynamic>) {
        return AppConfigResult.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      }
    }
    return null;
  }

  /// 获取可用模型列表
  Future<List<String>> getAvailableModels() async {
    final response = await _get('/api/models', authenticated: true);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['models'] ?? []);
    }
    return [];
  }

  // ============================================================
  // Private helpers
  // ============================================================

  Future<void> _saveAuth(String token, int userId, String username) async {
    _authToken = token;
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
  }

  Map<String, String> _buildHeaders({bool authenticated = false}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authenticated && _authToken != null && _userId != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      headers['X-User-Id'] = '$_userId';
    }
    return headers;
  }

  Future<http.Response> _get(String path, {bool authenticated = false}) async {
    return http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _buildHeaders(authenticated: authenticated),
    );
  }

  Future<http.Response> _post(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = false,
  }) async {
    return http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _buildHeaders(authenticated: authenticated),
      body: jsonEncode(body),
    );
  }
}

// ============================================================
// Data Models
// ============================================================

class AuthResult {
  final bool success;
  final String? username;
  final String? error;

  AuthResult({required this.success, this.username, this.error});
}

class UserInfo {
  final String username;
  final String? displayName;
  final int quota;
  final int usedQuota;
  final double balanceUsd;
  final double usedUsd;

  UserInfo({
    required this.username,
    this.displayName,
    required this.quota,
    required this.usedQuota,
    required this.balanceUsd,
    required this.usedUsd,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'] ?? '',
      displayName: json['displayName'],
      quota: json['quota'] ?? 0,
      usedQuota: json['usedQuota'] ?? 0,
      balanceUsd: (json['balanceUsd'] ?? 0).toDouble(),
      usedUsd: (json['usedUsd'] ?? 0).toDouble(),
    );
  }
}

class PaymentResult {
  final bool success;
  final String? checkoutUrl;
  final String? error;

  PaymentResult({required this.success, this.checkoutUrl, this.error});
}

class AppConfigResult {
  final AppConfigContent content;

  AppConfigResult({required this.content});

  factory AppConfigResult.fromJson(Map<String, dynamic> json) {
    return AppConfigResult(
      content: AppConfigContent.fromJson(
        (json['content'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class AppConfigContent {
  final AiServiceConfig aiService;

  AppConfigContent({required this.aiService});

  factory AppConfigContent.fromJson(Map<String, dynamic> json) {
    return AppConfigContent(
      aiService: AiServiceConfig.fromJson(
        (json['aiService'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class AiServiceConfig {
  final MemexConnectionConfig memexConnection;

  AiServiceConfig({required this.memexConnection});

  factory AiServiceConfig.fromJson(Map<String, dynamic> json) {
    return AiServiceConfig(
      memexConnection: MemexConnectionConfig.fromJson(
        (json['memexConnection'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class MemexConnectionConfig {
  final MemexTopUpConfig? topUp;

  MemexConnectionConfig({this.topUp});

  factory MemexConnectionConfig.fromJson(Map<String, dynamic> json) {
    return MemexConnectionConfig(
      topUp: json['topUp'] is Map<String, dynamic>
          ? MemexTopUpConfig.fromJson(json['topUp'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MemexTopUpConfig {
  final int perUsdMinRecords;
  final int perUsdMaxRecords;
  final List<String> descriptionLines;

  MemexTopUpConfig({
    required this.perUsdMinRecords,
    required this.perUsdMaxRecords,
    required this.descriptionLines,
  });

  factory MemexTopUpConfig.fromJson(Map<String, dynamic> json) {
    final estimate =
        (json['perUsdRecordEstimate'] as Map<String, dynamic>?) ?? const {};
    final min = estimate['min'];
    final max = estimate['max'];
    final lines = json['descriptionLines'];
    return MemexTopUpConfig(
      perUsdMinRecords: min is num ? min.toInt() : 5,
      perUsdMaxRecords: max is num ? max.toInt() : 20,
      descriptionLines:
          lines is List ? lines.whereType<String>().toList() : const [],
    );
  }
}

class CredentialResult {
  final String baseUrl;
  final String apiKey;
  final String provider;
  final List<String>? models;
  final int quota;
  final int usedQuota;
  final double balanceUsd;

  CredentialResult({
    required this.baseUrl,
    required this.apiKey,
    required this.provider,
    this.models,
    required this.quota,
    required this.usedQuota,
    required this.balanceUsd,
  });

  factory CredentialResult.fromJson(Map<String, dynamic> json) {
    return CredentialResult(
      baseUrl: json['baseUrl'] ?? '',
      apiKey: json['apiKey'] ?? '',
      provider: json['provider'] ?? 'chat_completion',
      models: json['models'] != null ? List<String>.from(json['models']) : null,
      quota: json['quota'] ?? 0,
      usedQuota: json['usedQuota'] ?? 0,
      balanceUsd: (json['balanceUsd'] ?? 0).toDouble(),
    );
  }
}

class LogsResult {
  final List<LogEntry> items;
  final int total;

  LogsResult({required this.items, required this.total});

  factory LogsResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) {
      final items = (data['items'] as List? ?? [])
          .map((e) => LogEntry.fromJson(e))
          .toList();
      return LogsResult(items: items, total: data['total'] ?? 0);
    }
    // fallback: data is list directly
    if (data is List) {
      return LogsResult(
        items: data.map((e) => LogEntry.fromJson(e)).toList(),
        total: data.length,
      );
    }
    return LogsResult(items: [], total: 0);
  }
}

class LogEntry {
  final int id;
  final String type; // "Consume" or "Top Up" or "System"
  final String model;
  final String tokenName;
  final int promptTokens;
  final int completionTokens;
  final double quota; // quota consumed (raw units)
  final String content; // detail text
  final int createdAt; // unix timestamp

  LogEntry({
    required this.id,
    required this.type,
    required this.model,
    required this.tokenName,
    required this.promptTokens,
    required this.completionTokens,
    required this.quota,
    required this.content,
    required this.createdAt,
  });

  /// Quota in USD
  double get quotaUsd {
    if (type == 'Top Up' && quota == 0 && content.isNotEmpty) {
      // Parse amount from content like "充值金额: ＄1.000000"
      final match = RegExp(r'[\$＄]([\d.]+)').firstMatch(content);
      if (match != null) return double.tryParse(match.group(1)!) ?? 0;
    }
    return quota / 500000;
  }

  DateTime get createdTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] ?? 0,
      type: _mapType(json['type'] ?? 0),
      model: json['model_name'] ?? json['model'] ?? '',
      tokenName: json['token_name'] ?? '',
      promptTokens: json['prompt_tokens'] ?? 0,
      completionTokens: json['completion_tokens'] ?? 0,
      quota: (json['quota'] ?? 0).toDouble(),
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? 0,
    );
  }

  static String _mapType(dynamic type) {
    if (type is String) return type;
    switch (type) {
      case 1:
        return 'Top Up';
      case 2:
        return 'Consume';
      case 3:
        return 'System';
      default:
        return 'Unknown';
    }
  }
}
