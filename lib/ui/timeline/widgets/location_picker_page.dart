import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'dart:convert';
import 'dart:async';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/back_button.dart';
import 'package:memex/ui/core/themes/app_colors.dart';

class LocationPickerResult {
  final LatLng point;
  final String? name;
  final String? address;

  LocationPickerResult({
    required this.point,
    this.name,
    this.address,
  });
}

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialPoint;
  final String? initialName;

  const LocationPickerPage({
    super.key,
    this.initialPoint,
    this.initialName,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final Logger _logger = getLogger('LocationPickerPage');
  late final MapController _mapController;
  late LatLng _currentCenter;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialPoint != null) {
      _currentCenter = widget.initialPoint!;
    } else {
      _currentCenter = const LatLng(39.9042, 116.4074); // Beijing
    }

    _searchController.text = widget.initialName ?? '';
    _searchController.addListener(_onSearchChanged);

    // If no initial point but has name, try to auto-locate
    if (widget.initialPoint == null &&
        widget.initialName != null &&
        widget.initialName!.isNotEmpty) {
      // Delay slightly to let initial render happen (optional, but safer for map controller)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoSearchAndLocate(widget.initialName!);
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchLocations(query);
    });
  }

  Future<void> _searchLocations(String query) async {
    try {
      // OpenStreetMap Nominatim search API (free, no API key required)
      final uri = Uri.parse('https://nominatim.openstreetmap.org/search')
          .replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '10',
        'accept-language': 'zh',
      });

      final response = await http.get(uri, headers: {
        'User-Agent': 'memex_app',
      });

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        // Transform Nominatim results to match our suggestion format
        final validResults = results
            .where((r) => r['lat'] != null && r['lon'] != null)
            .map((r) => {
                  'name': r['display_name']?.toString().split(',').first ?? '',
                  'district': r['display_name'] ?? '',
                  'location': '${r['lon']},${r['lat']}',
                })
            .toList();

        if (mounted) {
          setState(() {
            _suggestions = validResults;
            _showSuggestions = true;
          });
        }
      }
    } catch (e) {
      _logger.severe('Error searching locations: $e', e);
    }
  }

  Future<void> _autoSearchAndLocate(String query) async {
    // Perform search
    await _searchLocations(query);

    // If we found suggestions, pick the first one automatically
    if (mounted && _suggestions.isNotEmpty) {
      final bestMatch = _suggestions.first;
      _onSuggestionSelected(bestMatch);
      // Ensure suggestions are hidden after auto-selection
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onSuggestionSelected(dynamic suggestion) {
    final locationStr = suggestion['location'] as String;
    final parts = locationStr.split(',');
    if (parts.length == 2) {
      final lon = double.parse(parts[0]);
      final lat = double.parse(parts[1]);

      final displayName = suggestion['name'] as String? ?? '';

      setState(() {
        _showSuggestions = false;
        _searchController.text = displayName;
      });

      // Nominatim returns WGS-84, which matches OSM tiles directly
      final targetPoint = LatLng(lat, lon);
      _mapController.move(targetPoint, 15);
      _currentCenter = targetPoint;
    }
  }

  void _onMapPositionChanged(dynamic camera, bool hasGesture) {
    if (hasGesture) {
      setState(() {
        _currentCenter = camera.center;
        _showSuggestions = false; // Hide suggestions on map move
      });
    }
  }

  void _confirmSelection() {
    // Show dialog to confirm/edit location name
    final nameController = TextEditingController(
      text: _searchController.text.isNotEmpty
          ? _searchController.text
          : UserStorage.l10n.selectedLocation,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(UserStorage.l10n.confirmLocationName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              UserStorage.l10n.confirmLocationNameHint,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: UserStorage.l10n.nameLabel,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _returnResult(nameController.text);
            },
            child: Text(UserStorage.l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _returnResult(String name) {
    final result = LocationPickerResult(
      point: _currentCenter,
      name: name.trim().isNotEmpty
          ? name.trim()
          : UserStorage.l10n.selectedLocation,
      address:
          'Lat: ${_currentCenter.latitude.toStringAsFixed(4)}, Lng: ${_currentCenter.longitude.toStringAsFixed(4)}',
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15,
              onPositionChanged: _onMapPositionChanged,
              onTap: (_, __) {
                // Dismiss keyboard and suggestions
                FocusScope.of(context).unfocus();
                setState(() {
                  _showSuggestions = false;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.memexlab.memex',
              ),
            ],
          ),

          // Center Pin (Fixed)
          const Center(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: 40), // Adjust for pin anchor
              child: Icon(
                Icons.location_on,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),

          // Top Search Bar & Back Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Back Button
                        const AppBackButton(),
                        const SizedBox(width: 12),
                        // Search Input
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: UserStorage.l10n.inputPlaceNameHint,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                suffixIcon: const Icon(Icons.search,
                                    color: AppColors.textTertiary),
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Suggestions List
                    if (_showSuggestions && _suggestions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 56, top: 8), // Align with search bar
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              final name = suggestion['name'] as String? ?? '';
                              final district =
                                  suggestion['district'] as String? ?? '';
                              return ListTile(
                                title: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: district.isNotEmpty
                                    ? Text(
                                        district,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      )
                                    : null,
                                leading: const Icon(Icons.location_on_outlined,
                                    size: 20, color: AppColors.textSecondary),
                                onTap: () => _onSuggestionSelected(suggestion),
                                dense: true,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    UserStorage.l10n.currentCoordinates(
                        _currentCenter.latitude.toStringAsFixed(5),
                        _currentCenter.longitude.toStringAsFixed(5)),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      UserStorage.l10n.confirmLocation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
