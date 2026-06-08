import 'package:flutter/material.dart';
import 'package:memex/data/services/memex_cloud_service.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _memexAuthBorder = Color(0xFFC6C5D8);
const _memexAuthSurface = Color(0xFFFFFFFF);
const _memexAuthSecondary = Color(0xFF006397);
const _memexPricingPurple = Color(0xFF7C3AED);
const _memexPricingAmber = Color(0xFFFFB800);
const _memexTopUpAmounts = [5, 20, 100];

/// Memex 认证区域 — 嵌入到模型配置页中
/// 当用户选择 "Memex AI" 作为 provider 时显示
/// 提供注册/登录/余额显示/充值功能
/// 登录成功后回调 onCredentialsReady 传回 baseUrl + apiKey
class MemexAuthSection extends StatefulWidget {
  final void Function(String baseUrl, String apiKey, List<String> models)?
      onCredentialsReady;
  final ValueChanged<bool>? onLoginStateChanged;
  final VoidCallback? onLogout;
  final MemexTopUpConfig? topUpConfig;

  const MemexAuthSection({
    super.key,
    this.onCredentialsReady,
    this.onLoginStateChanged,
    this.onLogout,
    this.topUpConfig,
  });

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

  // Top up selection
  int? _selectedTopUpAmount;

  int get _activeTopUpAmount =>
      _selectedTopUpAmount ?? _memexTopUpAmounts.first;

  String _estimatedRecordsLabel(int amount) {
    final topUpConfig = widget.topUpConfig;
    if (topUpConfig == null) return '';
    final minPerUsd = topUpConfig.perUsdMinRecords;
    final maxPerUsd = topUpConfig.perUsdMaxRecords;
    final range = '${amount * minPerUsd}-${amount * maxPerUsd}';
    return UserStorage.l10n.memexTopUpEstimatedRecords(range);
  }

  String _topUpPlanTitle(int amount) {
    switch (amount) {
      case 5:
        return UserStorage.l10n.memexTopUpPlanStarter;
      case 20:
        return UserStorage.l10n.memexTopUpPlanEveryday;
      case 100:
        return UserStorage.l10n.memexTopUpPlanHighVolume;
    }
    return UserStorage.l10n.memexTopUpPlanCustom;
  }

  String _topUpPlanSubtitle(int amount) {
    switch (amount) {
      case 5:
        return UserStorage.l10n.memexTopUpPlanStarterSubtitle;
      case 20:
        return UserStorage.l10n.memexTopUpPlanEverydaySubtitle;
      case 100:
        return UserStorage.l10n.memexTopUpPlanHighVolumeSubtitle;
    }
    return UserStorage.l10n.memexTopUpPlanCustomSubtitle;
  }

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
      if ((_userInfo?.quota ?? 0) > 0) {
        _fetchAndNotifyCredentials();
      }
    }

    widget.onLoginStateChanged?.call(_isLoggedIn);
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
        setState(() {});
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
      return _buildLoadingPlaceholder();
    }

    return _isLoggedIn ? _buildLoggedInSection() : _buildAuthForm();
  }

  Widget _buildLoadingPlaceholder() {
    return Column(
      children: [
        _buildSkeletonBox(height: 48),
        const SizedBox(height: 8),
        _buildSkeletonBox(height: 48),
        const SizedBox(height: 12),
        _buildSkeletonBox(height: 48, color: AppColors.primary),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.center,
          child: _buildSkeletonBox(width: 134, height: 18),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: _buildSkeletonBox(width: 210, height: 14),
        ),
      ],
    );
  }

  Widget _buildSkeletonBox({
    double? width,
    required double height,
    Color color = const Color(0xFFEDEDF2),
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: color == AppColors.primary ? 0.16 : 1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E2E5)),
      ),
    );
  }

  // ============================================================
  // Auth Form
  // ============================================================

  Widget _buildAuthForm() {
    final l10n = UserStorage.l10n;
    return Column(
      children: [
        _buildAuthField(
          controller: _usernameController,
          icon: Icons.person_outline_rounded,
          label: l10n.memexUsername,
        ),
        const SizedBox(height: 8),
        _buildAuthField(
          controller: _passwordController,
          icon: Icons.lock_outline_rounded,
          label: l10n.memexPassword,
          obscureText: true,
        ),
        if (!_isLoginMode) ...[
          const SizedBox(height: 8),
          _buildAuthField(
            controller: _confirmPasswordController,
            icon: Icons.verified_user_outlined,
            label: l10n.memexConfirmPassword,
            obscureText: true,
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: _isAuthLoading ? null : _handleAuth,
            iconAlignment: IconAlignment.end,
            icon: _isAuthLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.arrow_forward_rounded, size: 22),
            label: Text(
              _isLoginMode ? l10n.memexSignIn : l10n.memexCreateAccount,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: const Color(0xFFE2E2E5),
              disabledForegroundColor: const Color(0xFF757687),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              _isLoginMode ? l10n.memexCreateAccountLink : l10n.memexSignInLink,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF757687)),
        filled: true,
        fillColor: _memexAuthSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _memexAuthBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
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
      widget.onLoginStateChanged?.call(true);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAccountSummary(balance),
        if (balance <= 0) ...[
          const SizedBox(height: 12),
          _buildLowBalanceNotice(),
        ],
        const SizedBox(height: 12),
        _buildTopUpEntryCard(),
      ],
    );
  }

  Widget _buildAccountSummary(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E5)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: balance > 0
                  ? AppColors.success.withValues(alpha: 0.1)
                  : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              balance > 0
                  ? Icons.check_circle_outline_rounded
                  : Icons.account_balance_wallet_outlined,
              color: balance > 0 ? AppColors.success : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username ?? 'Memex',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1C1E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  UserStorage.l10n
                      .memexBalanceLabel('\$${balance.toStringAsFixed(3)}'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757687),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showHistorySheet,
            icon: const Icon(Icons.receipt_long_rounded, size: 19),
            color: _memexAuthSecondary,
            tooltip: UserStorage.l10n.memexViewHistory,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: () async {
              await _service.logout();
              widget.onLoginStateChanged?.call(false);
              widget.onLogout?.call();
              setState(() {
                _isLoggedIn = false;
                _username = null;
                _userInfo = null;
              });
            },
            icon: const Icon(Icons.logout_rounded, size: 19),
            color: AppColors.danger,
            tooltip: UserStorage.l10n.memexLogout,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildLowBalanceNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              UserStorage.l10n.memexTopUp,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpEntryCard() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        onPressed: _isTopUpLoading ? null : _showPricingSheet,
        style: FilledButton.styleFrom(
          backgroundColor: _memexPricingPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        child: Text(UserStorage.l10n.memexTopUpButton),
      ),
    );
  }

  void _showPricingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            final maxHeight = MediaQuery.of(context).size.height * 0.9;
            return SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(maxHeight: maxHeight),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F9FC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D8E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            UserStorage.l10n.memexTopUpButton,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1C1E),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _isTopUpLoading
                              ? null
                              : () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                          color: const Color(0xFF757687),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: SingleChildScrollView(
                        child: _buildPricingPanel(
                          refresh: () => refresh(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSheetPrimaryCta(
                      amount: _activeTopUpAmount,
                      onTopUp: (amount) async {
                        await _handleTopUpFromSheet(
                          amount,
                          sheetContext: sheetContext,
                          refreshSheet: refresh,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPricingPanel({VoidCallback? refresh}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UserStorage.l10n.memexTopUpChooseAmount,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 8),
        _buildTopUpAmountGrid(refresh: refresh),
        const SizedBox(height: 14),
        _buildPricingFeatureRows(),
      ],
    );
  }

  Widget _buildSheetPrimaryCta({
    required int amount,
    required Future<void> Function(int amount) onTopUp,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: _isTopUpLoading ? null : () => onTopUp(amount),
        iconAlignment: IconAlignment.end,
        icon: _isTopUpLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.arrow_forward_rounded, size: 21),
        label: Text(UserStorage.l10n.memexPayAmount('\$$amount')),
        style: FilledButton.styleFrom(
          backgroundColor: _memexPricingAmber,
          foregroundColor: const Color(0xFF1A1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildTopUpAmountGrid({VoidCallback? refresh}) {
    return Column(
      children: [
        ..._memexTopUpAmounts.map(
          (amount) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTopUpChip(amount, refresh: refresh),
          ),
        ),
        _buildCustomTopUpChip(refresh: refresh),
      ],
    );
  }

  Widget _buildTopUpChip(int amount, {VoidCallback? refresh}) {
    final isSelected = _activeTopUpAmount == amount;
    return _buildPlanTile(
      isSelected: isSelected,
      amountLabel: '\$$amount',
      title: _topUpPlanTitle(amount),
      subtitle: _topUpPlanSubtitle(amount),
      estimate: _estimatedRecordsLabel(amount),
      onPressed: _isTopUpLoading
          ? null
          : () {
              _selectedTopUpAmount = amount;
              if (refresh != null) {
                refresh();
              } else {
                setState(() {});
              }
            },
    );
  }

  Widget _buildCustomTopUpChip({VoidCallback? refresh}) {
    final isSelected = _selectedTopUpAmount != null &&
        !_memexTopUpAmounts.contains(_selectedTopUpAmount);
    return _buildPlanTile(
      isSelected: isSelected,
      amountLabel: isSelected ? '\$$_selectedTopUpAmount' : '...',
      title: UserStorage.l10n.memexTopUpPlanCustom,
      subtitle: _topUpPlanSubtitle(-1),
      estimate: widget.topUpConfig == null
          ? ''
          : UserStorage.l10n.memexTopUpCustomEstimate,
      onPressed:
          _isTopUpLoading ? null : () => _handleCustomTopUp(refresh: refresh),
    );
  }

  Widget _buildPlanTile({
    required bool isSelected,
    required String amountLabel,
    required String title,
    required String subtitle,
    required String estimate,
    required VoidCallback? onPressed,
  }) {
    final borderColor =
        isSelected ? _memexPricingPurple : const Color(0xFFE2E2E5);
    return Material(
      color: isSelected
          ? _memexPricingPurple.withValues(alpha: 0.07)
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 74),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 1.3 : 1),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? _memexPricingPurple
                        : const Color(0xFFC6C5D8),
                    width: 1.6,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _memexPricingPurple,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1C1E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757687),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (estimate.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        estimate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF454655),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                amountLabel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? _memexPricingPurple
                      : const Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingFeatureRows() {
    final rows = _buildConfiguredPricingRows();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E5)),
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(row.$1, size: 17, color: _memexPricingPurple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Color(0xFF454655),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  List<(IconData, String)> _buildConfiguredPricingRows() {
    final lines = widget.topUpConfig?.descriptionLines ?? const [];
    if (lines.isEmpty) return const [];

    return [
      for (var i = 0; i < lines.length; i++)
        (
          i == 0
              ? Icons.payments_outlined
              : i == 1
                  ? Icons.bolt_rounded
                  : Icons.tune_rounded,
          lines[i],
        ),
    ];
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

  Future<void> _handleCustomTopUp({VoidCallback? refresh}) async {
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
      _selectedTopUpAmount = amount;
      if (refresh != null) {
        refresh();
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _handleTopUpFromSheet(
    int amount, {
    required BuildContext sheetContext,
    required StateSetter refreshSheet,
  }) async {
    final sheetNavigator = Navigator.of(sheetContext);

    setState(() => _isTopUpLoading = true);
    refreshSheet(() {});

    final result = await _service.createStripePayment(amount);

    if (!mounted) return;

    if (result.success && result.checkoutUrl != null) {
      if (sheetNavigator.canPop()) {
        sheetNavigator.pop();
      }

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

      if (mounted) setState(() => _isTopUpLoading = false);
      return;
    }

    ToastHelper.showError(
        context, result.error ?? UserStorage.l10n.memexPaymentFailed);

    if (mounted) {
      setState(() => _isTopUpLoading = false);
      refreshSheet(() {});
    }
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
