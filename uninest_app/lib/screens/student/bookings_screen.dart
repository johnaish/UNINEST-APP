import 'package:flutter/material.dart';
import '../../services/booking_service.dart';

class BookingsScreen extends StatefulWidget {
  static const routeName = '/bookings';
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService service = BookingService();

  @override
  Widget build(BuildContext context) {
    final bookings = service.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFFF68B1E),
      ),
      body: bookings.isEmpty
          ? const Center(child: Text('No bookings yet.'))
          : ListView.separated(
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final b = bookings[i];
                return ListTile(
                  title: Text(b.propertyTitle),
                  subtitle: Text('Landlord: ${b.landlordName}\nStatus: ${b.status}\n${b.message}'),
                  isThreeLine: true,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFF68B1E),
        onPressed: () {
          setState(() {
            service.addBooking(
              propertyId: 'demo',
              propertyTitle: 'Demo Booking Property',
              landlordName: 'Demo Landlord',
              message: 'I would like to book/view this place.',
            );
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Demo Booking'),
      ),
    );
  }
}