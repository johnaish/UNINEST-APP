class Booking {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String landlordName;
  final String message;
  final DateTime createdAt;
  final String status; // pending/confirmed/cancelled

  Booking({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.landlordName,
    required this.message,
    required this.createdAt,
    required this.status,
  });
}

class BookingService {
  BookingService._internal();
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;

  final List<Booking> _bookings = [];

  List<Booking> getAll() => List.unmodifiable(_bookings);

  void addBooking({
    required String propertyId,
    required String propertyTitle,
    required String landlordName,
    required String message,
  }) {
    _bookings.insert(
      0,
      Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        landlordName: landlordName,
        message: message,
        createdAt: DateTime.now(),
        status: 'pending',
      ),
    );
  }

  void clear() => _bookings.clear();
}