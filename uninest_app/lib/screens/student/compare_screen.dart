import 'package:flutter/material.dart';
import '../../models/property.dart';

class CompareScreen extends StatelessWidget {
  static const routeName = '/compare';

  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties =
        ModalRoute.of(context)!.settings.arguments as List<Property>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Listings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: properties.map((p) {
            return SizedBox(
              width: 260,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(p.location),
                      const SizedBox(height: 8),
                      Text('Price: KES ${p.pricePerMonth.toStringAsFixed(0)}'),
                      Text('Distance: ${p.distanceFromCampusKm} km'),
                      Text('Type: ${p.roomType}'),
                      Text('Rating: ${p.rating.toStringAsFixed(1)} ★'),
                      const SizedBox(height: 8),
                      const Text(
                        'Amenities:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...p.amenities.map((a) => Text('• $a')),
                      const SizedBox(height: 8),
                      if (p.isVerified)
                        const Text(
                          'Verified Listing',
                          style: TextStyle(color: Colors.green),
                        )
                      else
                        const Text(
                          'Not yet verified',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
