class Property {
  final String id;
  final String title;
  final String location;
  final double pricePerMonth;
  final double distanceFromCampusKm;
  final String roomType;
  final double rating;
  final List<String> amenities;
  final bool isVerified;
  final String verificationStatus;
  final String verificationAdminId;
  final String verificationNote;
  final String imageUrl;
  final String landlordName;
  final String landlordId;
  final double latitude;
  final double longitude;

  const Property({
    required this.id,
    required this.title,
    required this.location,
    required this.pricePerMonth,
    required this.distanceFromCampusKm,
    required this.roomType,
    required this.rating,
    required this.amenities,
    required this.isVerified,
    required this.verificationStatus,
    required this.verificationAdminId,
    required this.verificationNote,
    required this.imageUrl,
    required this.landlordName,
    required this.landlordId,
    required this.latitude,
    required this.longitude,
  });

  factory Property.fromMap(Map<String, dynamic> map, String id) {
    return Property(
      id: id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      pricePerMonth: (map['pricePerMonth'] ?? 0.0).toDouble(),
      distanceFromCampusKm: (map['distanceFromCampusKm'] ?? 0.0).toDouble(),
      roomType: map['roomType'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      amenities: List<String>.from(map['amenities'] ?? []),
      isVerified: map['isVerified'] ?? false,
      verificationStatus: map['verificationStatus'] ?? 'pending',
      verificationAdminId: map['verificationAdminId'] ?? '',
      verificationNote: map['verificationNote'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      landlordName: map['landlordName'] ?? '',
      landlordId: map['landlordId'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }
}