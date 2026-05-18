import 'package:flutter/material.dart';
import 'package:memex/data/services/memex_cloud_service.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Memex 认证区域 — 嵌入到模型配置页中
/// 当用户选择 "Memex AI" 作为 provider 时显示
/// 提供注册/登录/余额显示/充值功能
/// 登录成功后回调 onCredentialsReady 传回 baseUrl + apiKey
class MemexAuthSection extends StatefulWidget {
  final void Function(String baseUrl, String apiKey, List<String> models)?
      onCredentialsReady;

  const MemexAuthSection({super.key, this.onCredentialsReady});

  @override
  State<MemexAuthSection> createState() => _MemexAuthSectionState();
}

class _MemexAuthSectionState extends State<MemexAuthSection> {
  final _service = MemexCloudService.instance;

  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _username;
  UserInfo? _userInfo;

  // Auth form
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isAuthLoading = false;
  bool _isLoginMode = true;

  // Top up
  bool _isTopUpLoading = false;

  // Applied credentials display

  // Pricing info
  double? _groupRatio;

  // Top up selection
  int? _selectedTopUpAmount;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    _isLoggedIn = _service.isLoggedIn;
    _username = await _service.getUsername();

    if (_isLoggedIn) {
      await _loadUserInfo();
      // Auto-fetch credentials if logged in with balance
      if ((_userInfo?.quota ?? 0) > 0) {
        _fetchAndNotifyCredentials();
      }
    }

    // Fetch pricing info (public, doesn't require login)
    _groupRatio = await _service.getGroupRatio();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadUserInfo() async {
    _userInfo = await _service.getUserInfo();
  }

  Future<void> _fetchAndNotifyCredentials() async {
    final credentials = await _service.getCredentials();
    if (credentials != null && widget.onCredentialsReady != null && mounted) {
      widget.onCredentialsReady!(
        credentials.baseUrl,
        credentials.apiKey,
        credentials.models ?? [],
      );
      if (mounted) {
        setState(() {
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pricing info
        if (_groupRatio != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    UserStorage.l10n
                        .memexPricingInfo(_groupRatio!.toStringAsFixed(1)),
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Auth or logged-in section
        if (!_isLoggedIn) _buildAuthForm() else _buildLoggedInSection(),
      ],
    );
  }

  // ============================================================
  // Auth Form
  // ============================================================

  Widget _buildAuthForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                _isLoginMode
                    ? UserStorage.l10n.memexSignInToMemex
                    : UserStorage.l10n.memexCreateMemexAccount,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: UserStorage.l10n.memexUsername,
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: UserStorage.l10n.memexPassword,
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          if (!_isLoginMode) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: UserStorage.l10n.memexConfirmPassword,
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAuthLoading ? null : _handleAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isAuthLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isLoginMode
                      ? UserStorage.l10n.memexSignIn
                      : UserStorage.l10n.memexCreateAccount),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
              child: Text(
                _isLoginMode
                    ? UserStorage.l10n.memexCreateAccountLink
                    : UserStorage.l10n.memexSignInLink,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ToastHelper.showError(context, UserStorage.l10n.memexFillAllFields);
      return;
    }
    if (username.length < 6) {
      ToastHelper.showError(context, UserStorage.l10n.memexUsernameTooShort);
      return;
    }
    if (!_isLoginMode && password != _confirmPasswordController.text) {
      ToastHelper.showError(context, UserStorage.l10n.memexPasswordMismatch);
      return;
    }

    setState(() => _isAuthLoading = true);

    AuthResult result;
    if (_isLoginMode) {
      result = await _service.login(username: username, password: password);
    } else {
      result = await _service.register(username: username, password: password);
    }

    if (!mounted) return;

    if (result.success) {
      _isLoggedIn = true;
      _username = username;
      await _loadUserInfo();
      if ((_userInfo?.quota ?? 0) > 0) {
        await _fetchAndNotifyCredentials();
      }
      setState(() => _isAuthLoading = false);
    } else {
      setState(() => _isAuthLoading = false);
      ToastHelper.showError(
          context, result.error ?? UserStorage.l10n.memexAuthFailed);
    }
  }

  // ============================================================
  // Logged In
  // ============================================================

  Widget _buildLoggedInSection() {
    final balance = _userInfo?.balanceUsd ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: balance > 0 ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$_username · ${UserStorage.l10n.memexBalanceLabel('\$${balance.toStringAsFixed(3)}')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await _service.logout();
                  setState(() {
                    _isLoggedIn = false;
                    _username = null;
                    _userInfo = null;
                  });
                },
                child: Text(UserStorage.l10n.memexLogout,
                    style: TextStyle(fontSize: 12, color: Colors.red[400])),
              ),
            ],
          ),

          if (balance <= 0) ...[
            const SizedBox(height: 12),
            Text(
              UserStorage.l10n.memexTopUp,
              style: TextStyle(fontSize: 12, color: Colors.orange[700]),
            ),
          ],

          // Top up buttons
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...[5, 20, 100].map((amount) {
                final isSelected = _selectedTopUpAmount == amount;
                return SizedBox(
                  width: 70,
                  height: 32,
                  child: OutlinedButton(
                    onPressed: _isTopUpLoading
                        ? null
                        : () => setState(() => _selectedTopUpAmount = amount),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[300]!,
                      ),
                    ),
                    child: Text('\$$amount',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isSelected ? AppColors.primary : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        )),
                  ),
                );
              }),
              SizedBox(
                width: 70,
                height: 32,
                child: OutlinedButton(
                  onPressed: _isTopUpLoading ? null : _handleCustomTopUp,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: _selectedTopUpAmount != null &&
                            ![5, 20, 100].contains(_selectedTopUpAmount)
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: BorderSide(
                      color: _selectedTopUpAmount != null &&
                              ![5, 20, 100].contains(_selectedTopUpAmount)
                          ? AppColors.primary
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    _selectedTopUpAmount != null &&
                            ![5, 20, 100].contains(_selectedTopUpAmount)
                        ? '\$$_selectedTopUpAmount'
                        : '...',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),

          // Pay button
          if (_selectedTopUpAmount != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: _isTopUpLoading
                    ? null
                    : () => _handleTopUp(_selectedTopUpAmount!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isTopUpLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(UserStorage.l10n
                        .memexPayAmount('\$$_selectedTopUpAmount')),
              ),
            ),
          ],

          // Refresh credentials button
          if (balance > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _fetchAndNotifyCredentials();
                  if (mounted) {
                    ToastHelper.showSuccess(
                        context, UserStorage.l10n.memexCredentialsApplied);
                  }
                },
                icon: const Icon(Icons.auto_fix_high, size: 16),
                label: Text(UserStorage.l10n.memexApplyCredentials),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          // View history button
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _showHistorySheet,
              icon: Icon(Icons.receipt_long, size: 16, color: Colors.grey[600]),
              label: Text(
                UserStorage.l10n.memexViewHistory,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => _MemexHistorySheet(
          service: _service,
          scrollController: scrollController,
        ),
      ),
    );
  }

  Future<void> _handleCustomTopUp() async {
    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(UserStorage.l10n.memexCustomAmount),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              hintText: '1 - 10000',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(UserStorage.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final val = int.tryParse(controller.text.trim());
                Navigator.pop(ctx, val);
              },
              child: Text(UserStorage.l10n.ok),
            ),
          ],
        );
      },
    );

    if (amount != null && amount >= 1 && amount <= 10000) {
      setState(() => _selectedTopUpAmount = amount);
    }
  }

  Future<void> _handleTopUp(int amount) async {
    setState(() => _isTopUpLoading = true);

    final result = await _service.createStripePayment(amount);

    if (!mounted) return;

    if (result.success && result.checkoutUrl != null) {
      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              _MemexPaymentWebView(checkoutUrl: result.checkoutUrl!),
        ),
      );

      if (paid == true && mounted) {
        await _loadUserInfo();
        if ((_userInfo?.quota ?? 0) > 0 && mounted) {
          await _fetchAndNotifyCredentials();
        }
        if (mounted) {
          setState(() {});
          ToastHelper.showSuccess(context, UserStorage.l10n.memexTopUpSuccess);
        }
      }
    } else {
      ToastHelper.showError(
          context, result.error ?? UserStorage.l10n.memexPaymentFailed);
    }

    if (mounted) setState(() => _isTopUpLoading = false);
  }
}

/// 使用记录 BottomSheet
class _MemexHistorySheet extends StatefulWidget {
  final MemexCloudService service;
  final ScrollController scrollController;

  const _MemexHistorySheet({
    required this.service,
    required this.scrollController,
  });

  @override
  State<_MemexHistorySheet> createState() => _MemexHistorySheetState();
}

class _MemexHistorySheetState extends State<_MemexHistorySheet> {
  final List<LogEntry> _logs = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadMore();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >=
            widget.scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    final result =
        await widget.service.getLogs(page: _page, pageSize: _pageSize);
    if (mounted) {
      setState(() {
        _logs.addAll(result.items);
        _hasMore = _logs.length < result.total;
        _page++;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                UserStorage.l10n.memexViewHistory,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${_logs.length} records',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _logs.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : ListView.separated(
                  controller: widget.scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _logs.length + (_hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index >= _logs.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    final log = _logs[index];
                    return _buildLogItem(log);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLogItem(LogEntry log) {
    final isTopUp = log.type == 'Top Up';
    final time = log.createdTime;
    final timeStr =
        '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTopUp ? Colors.green[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isTopUp ? Icons.add_circle_outline : Icons.remove_circle_outline,
              size: 18,
              color: isTopUp ? Colors.green : Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTopUp ? 'Top Up' : log.model,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isTopUp
                      ? timeStr
                      : '$timeStr · ${log.promptTokens}+${log.completionTokens} tokens',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '${isTopUp ? '+' : '-'}\$${log.quotaUsd.abs().toStringAsFixed(4)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isTopUp ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// 内嵌支付 WebView
class _MemexPaymentWebView extends StatefulWidget {
  final String checkoutUrl;
  const _MemexPaymentWebView({required this.checkoutUrl});

  @override
  State<_MemexPaymentWebView> createState() => _MemexPaymentWebViewState();
}

class _MemexPaymentWebViewState extends State<_MemexPaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            final url = change.url ?? '';
            if (url.contains('/console/log') || url.contains('pay=success')) {
              Navigator.pop(context, true);
            } else if (url.contains('/console/topup') ||
                url.contains('pay=cancel') ||
                url.contains('pay=fail')) {
              Navigator.pop(context, false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
