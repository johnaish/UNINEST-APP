import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/property_service.dart';
import '../../models/property.dart';
import 'property_detail_screen.dart';

class MapScreen extends StatelessWidget {
  static const routeName = '/map';

  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = PropertyService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final List<Property> properties = service.properties;

        // ✅ LatLng is NOT const. Remove const to avoid red-line.
        final LatLng center = properties.isNotEmpty
            ? LatLng(properties[0].latitude, properties[0].longitude)
            : LatLng(-0.3970, 36.9609);

        return Scaffold(
          appBar: AppBar(title: const Text('Find Near Me')),
          body: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.uninest_app',
              ),
              MarkerLayer(
                markers: properties.map((p) {
                  return Marker(
                    point: LatLng(p.latitude, p.longitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          PropertyDetailScreen.routeName,
                          arguments: p,
                        );
                      },
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}