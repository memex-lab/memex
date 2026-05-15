import 'package:flutter/material.dart';
import 'package:memex/data/services/location_context_service.dart';
import 'package:memex/domain/models/location_context_config.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/user_storage.dart';

typedef CurrentLocationContextLoader = Future<CurrentLocationContext> Function(
    {bool forceRefresh});

class LocationContextSettingsPage extends StatefulWidget {
  const LocationContextSettingsPage({super.key, this.loadCurrentContext});

  final CurrentLocationContextLoader? loadCurrentContext;

  @override
  State<LocationContextSettingsPage> createState() =>
      _LocationContextSettingsPageState();
}

class _LocationContextSettingsPageState
    extends State<LocationContextSettingsPage> {
  LocationContextConfig _config = const LocationContextConfig();
  late final TextEditingController _amapKeyController;
  bool _loading = true;
  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _amapKeyController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _amapKeyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final config = await UserStorage.getLocationContextConfig();
    if (!mounted) return;
    setState(() {
      _config = config;
      _amapKeyController.text = config.amapApiKey;
      _loading = false;
    });
  }

  Future<void> _save(LocationContextConfig config) async {
    setState(() => _config = config);
    await UserStorage.saveLocationContextConfig(config);
  }

  Future<void> _testLocation() async {
    final l10n = UserStorage.l10n;
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      final loader = widget.loadCurrentContext ??
          LocationContextService.instance.getCurrentContext;
      final context = await loader(forceRefresh: true);
      final summary = context.address?.summary(context.granularity);
      if (!mounted) return;
      setState(() {
        _testResult = context.isFresh
            ? [
                if (summary != null && summary.isNotEmpty) summary,
                if (context.address?.fullAddress != null)
                  context.address!.fullAddress!,
                '${context.latitude?.toStringAsFixed(6)}, ${context.longitude?.toStringAsFixed(6)}',
              ].join('\n')
            : '${context.status}: ${context.reason ?? l10n.locationUnavailable}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _testResult = l10n.locationTestFailed(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _testing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(l10n.locationContextTitle),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(
                      Icons.my_location_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.locationContextAttachTitle),
                    subtitle: Text(l10n.locationContextAttachDesc),
                    value: _config.enabled,
                    onChanged: (value) =>
                        _save(_config.copyWith(enabled: value)),
                  ),
                ),
                const SizedBox(height: 16),
                _section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reverseGeocodingProvider,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<GeocodingProvider>(
                        key: ValueKey(_config.provider),
                        initialValue: _config.provider,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        selectedItemBuilder: (_) => [
                          const Text('OpenStreetMap / Nominatim'),
                          Text(l10n.amapProviderName),
                        ],
                        items: [
                          const DropdownMenuItem(
                            value: GeocodingProvider.openStreetMap,
                            child: Text('OpenStreetMap / Nominatim'),
                          ),
                          DropdownMenuItem(
                            value: GeocodingProvider.amap,
                            child: Text(l10n.amapProviderName),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          _save(_config.copyWith(provider: value));
                        },
                      ),
                      if (_config.provider == GeocodingProvider.amap) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _amapKeyController,
                          decoration: InputDecoration(
                            labelText: l10n.amapApiKey,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) =>
                              _save(_config.copyWith(amapApiKey: value.trim())),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.amapGcj02Note,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.contextGranularity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<LocationContextGranularity>(
                        key: ValueKey(_config.granularity),
                        initialValue: _config.granularity,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: LocationContextGranularity.city,
                            child: Text(l10n.granularityCity),
                          ),
                          DropdownMenuItem(
                            value: LocationContextGranularity.district,
                            child: Text(l10n.granularityDistrict),
                          ),
                          DropdownMenuItem(
                            value: LocationContextGranularity.neighborhood,
                            child: Text(l10n.granularityNeighborhood),
                          ),
                          DropdownMenuItem(
                            value: LocationContextGranularity.street,
                            child: Text(l10n.granularityStreet),
                          ),
                          DropdownMenuItem(
                            value: LocationContextGranularity.full,
                            child: Text(l10n.granularityFullAddress),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          _save(_config.copyWith(granularity: value));
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.locationFreshness,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        key: ValueKey(_config.ttlMinutes),
                        initialValue: _config.ttlMinutes,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 5,
                            child: Text(l10n.minutesShort(5)),
                          ),
                          DropdownMenuItem(
                            value: 15,
                            child: Text(l10n.minutesShort(15)),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text(l10n.minutesShort(30)),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text(l10n.oneHour),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          _save(_config.copyWith(ttlMinutes: value));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilledButton.icon(
                        onPressed: _testing ? null : _testLocation,
                        icon: _testing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.location_searching),
                        label: Text(l10n.testCurrentLocation),
                      ),
                      if (_testResult != null) ...[
                        const SizedBox(height: 12),
                        SelectableText(
                          _testResult!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
