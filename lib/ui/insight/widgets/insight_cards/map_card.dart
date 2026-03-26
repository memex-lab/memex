import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:memex/utils/user_storage.dart';

/// Model for a location on the map
class MapLocation {
  final LatLng point;
  final String? name;

  const MapLocation({
    required this.point,
    this.name,
  });
}

class MapCard extends StatelessWidget {
  final String? title;
  final String? infoTitle;
  final String? infoDetail;
  final String? insight;
  final List<MapLocation> locations;
  final bool isDetail;

  MapCard({
    super.key,
    this.title,
    this.infoTitle,
    this.infoDetail,
    this.insight,
    this.locations = const [],
    this.isDetail = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? UserStorage.l10n.footprintMap;
    if (isDetail) {
      return _buildDetailCard(context, effectiveTitle);
    }
    return _buildListCard(context, effectiveTitle);
  }

  Widget _buildListCard(BuildContext context, String effectiveTitle) {
    // Filter invalid locations
    final validLocations = locations.where((loc) {
      // Basic range check for Lat/Lng
      return loc.point.latitude.isFinite &&
          loc.point.longitude.isFinite &&
          loc.point.latitude.abs() <= 90 &&
          loc.point.longitude.abs() <= 180;
    }).toList();

    // Use WGS-84 coordinates directly (OSM tiles use WGS-84)
    final hasLocations = validLocations.isNotEmpty;

    final initialCenter = hasLocations
        ? validLocations.first.point
        : const LatLng(31.2304, 121.4737); // Shanghai (approx)

    // Conditional info panel: show if at least one info field is present
    final showInfo = (infoTitle != null && infoTitle!.isNotEmpty) ||
        (infoDetail != null && infoDetail!.isNotEmpty);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF7F8FA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          IgnorePointer(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 11,
                // Disable interaction in list view to prevent conflict with scrolling
                // Only use bounds fit if we have multiple points to avoid infinite zoom on single point
                initialCameraFit: (hasLocations && validLocations.length > 1)
                    ? CameraFit.bounds(
                        bounds: LatLngBounds.fromPoints(
                            validLocations.map((e) => e.point).toList()),
                        padding: const EdgeInsets.all(50),
                      )
                    : null,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.memexlab.memex',
                ),
                MarkerLayer(
                  markers: validLocations
                      .map((location) => Marker(
                            point: location.point,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF5B6CFF), // Unified color for now
                              size: 40,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          // Title overlay
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.map,
                    size: 16,
                    color: Color(0xFF5B6CFF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    effectiveTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom info card
          if (showInfo)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (infoTitle != null && infoTitle!.isNotEmpty)
                            Text(
                              infoTitle!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF4A5565),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (infoTitle != null &&
                              infoTitle!.isNotEmpty &&
                              infoDetail != null &&
                              infoDetail!.isNotEmpty)
                            const SizedBox(height: 1),
                          if (infoDetail != null && infoDetail!.isNotEmpty)
                            Text(
                              infoDetail!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0A0A0A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF99A1AF),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String effectiveTitle) {
    // Filter invalid locations
    final validLocations = locations.where((loc) {
      return loc.point.latitude.isFinite &&
          loc.point.longitude.isFinite &&
          loc.point.latitude.abs() <= 90 &&
          loc.point.longitude.abs() <= 180;
    }).toList();

    // Use WGS-84 coordinates directly (OSM tiles use WGS-84)
    final hasLocations = validLocations.isNotEmpty;

    final initialCenter = hasLocations
        ? validLocations.first.point
        : const LatLng(31.2304, 121.4737);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Insight Section
        if (insight != null && insight!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF166534),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Rich Info Section
        if (infoTitle != null || infoDetail != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: Color(0xFF5B6CFF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (infoTitle != null)
                        Text(
                          infoTitle!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A5565),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (infoDetail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          infoDetail!,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF0A0A0A),
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Expanded Map View
        Container(
          height: 240, // Reduced height for details as requested
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF7F8FA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 11,
              // Enable full interaction in detail view
              // Only use bounds fit if we have multiple points to avoid infinite zoom on single point
              initialCameraFit: (hasLocations && validLocations.length > 1)
                  ? CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints(
                          validLocations.map((e) => e.point).toList()),
                      padding: const EdgeInsets.all(50),
                    )
                  : null,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.memexlab.memex',
              ),
              MarkerLayer(
                markers: validLocations
                    .map((location) => Marker(
                          point: location.point,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF5B6CFF),
                            size: 40,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),

        // Coordinate List
        if (validLocations.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            UserStorage.l10n.waypointPlaces,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A0A0A),
            ),
          ),
          const SizedBox(height: 12),
          ...validLocations.asMap().entries.map((entry) {
            final index = entry.key;
            final location = entry.value;
            final name = location.name ?? UserStorage.l10n.unknownPlace;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF7F8FA)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A5565),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }
}
