import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlaceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const PlaceCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String name = data['name'] ?? 'Place';
    final String address = data['address'] ?? '';
    final double? lat = (data['latitude'] ?? data['lat']) as double?;
    final double? lng = (data['longitude'] ?? data['lng']) as double?;

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map Preview
          SizedBox(
            height: 140, // Slightly taller for better map view
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMap(lat, lng),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      if (address.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Icon(
                                  Icons
                                      .location_on_outlined, // Changed to outlined
                                  size: 14,
                                  color: const Color(0xFF4A5565)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.white,
                                          Colors.white,
                                          Colors.white,
                                          Colors.transparent
                                        ],
                                        stops: [0.0, 0.8, 0.9, 1.0],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          Text(
                                            address,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: const Color(0xFF4A5565),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text('📍', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(double? lat, double? lng) {
    if (lat == null || lng == null) {
      return Container(
        color: const Color(0xFFF7F8FA),
        child: const Center(
            child: Icon(Icons.map, color: Color(0xFFE2E8F0), size: 48)),
      );
    }

    // Use WGS-84 coordinates directly (OSM tiles use WGS-84)
    final point = LatLng(lat, lng);

    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none), // Static preview
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.memexlab.memex',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFEF4444),
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
