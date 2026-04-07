import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/booking_service.dart';

class PropertyDetailScreen extends StatelessWidget {
  static const routeName = '/property-detail';
  const PropertyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final property = ModalRoute.of(context)!.settings.arguments as Property;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Property Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              property.imageUrl.isNotEmpty
                  ? property.imageUrl
                  : 'https://picsum.photos/800/400',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.network(
                'https://picsum.photos/800/400',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            property.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            property.location,
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            'KES ${property.pricePerMonth.toStringAsFixed(0)} / month',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text('Landlord: ${property.landlordName}'),
          const SizedBox(height: 16),

          const Text('Amenities', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: property.amenities.map((a) => Chip(label: Text(a))).toList(),
          ),

          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                BookingService().addBooking(
                  propertyId: property.id,
                  propertyTitle: property.title,
                  landlordName: property.landlordName,
                  message: 'Requesting booking / viewing.',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking created ✅ Check My Bookings')),
                );
              },
              child: const Text('Book / Request Viewing'),
            ),
          ),
        ],
      ),
    );
  }
}