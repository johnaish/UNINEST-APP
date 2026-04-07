import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property.dart';

const List<Property> _exampleStudentProperties = [
  Property(
    id: 'sample-sunrise-hostel',
    title: 'Sunrise Student Hostel',
    location: 'Moyale Road, 0.8 km from campus',
    pricePerMonth: 8500,
    distanceFromCampusKm: 0.8,
    roomType: 'Bedsitter',
    rating: 4.6,
    amenities: ['Wi-Fi', 'Water', 'Security', 'Study Desk', 'Laundry Area'],
    isVerified: true,
    verificationStatus: 'approved',
    verificationAdminId: 'system',
    verificationNote: 'Example listing for student browsing.',
    imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
    landlordName: 'Grace Wanjiku',
    landlordId: 'sample-landlord-1',
    latitude: -1.2921,
    longitude: 36.8219,
  ),
  Property(
    id: 'sample-campus-view',
    title: 'Campus View Studios',
    location: 'Kasarani Estate, 1.4 km from campus',
    pricePerMonth: 12000,
    distanceFromCampusKm: 1.4,
    roomType: 'Studio',
    rating: 4.8,
    amenities: ['Parking', 'Wi-Fi', 'Hot Shower', 'Caretaker', 'CCTV'],
    isVerified: true,
    verificationStatus: 'approved',
    verificationAdminId: 'system',
    verificationNote: 'Example listing for student browsing.',
    imageUrl: 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80',
    landlordName: 'Peter Mwangi',
    landlordId: 'sample-landlord-2',
    latitude: -1.2810,
    longitude: 36.8240,
  ),
  Property(
    id: 'sample-green-gardens',
    title: 'Green Gardens Residence',
    location: 'Thika Road, 2.1 km from campus',
    pricePerMonth: 15000,
    distanceFromCampusKm: 2.1,
    roomType: 'One Bedroom',
    rating: 4.4,
    amenities: ['Balcony', 'Gym', 'Wi-Fi', 'Water', '24/7 Security'],
    isVerified: true,
    verificationStatus: 'approved',
    verificationAdminId: 'system',
    verificationNote: 'Example listing for student browsing.',
    imageUrl: 'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=1200&q=80',
    landlordName: 'Anne Njeri',
    landlordId: 'sample-landlord-3',
    latitude: -1.2755,
    longitude: 36.8302,
  ),
];

class PropertyService extends ChangeNotifier {
  PropertyService._internal();
  static final PropertyService instance = PropertyService._internal();

  FirebaseFirestore? _db;
  final List<Property> _properties = [];
  bool _loaded = false;

  FirebaseFirestore get _firestore {
    _db ??= FirebaseFirestore.instance;
    return _db!;
  }

  Future<void> loadProperties({bool forceRefresh = false}) async {
    if (_loaded && !forceRefresh) return;

    try {
      final snapshot = await _firestore.collection('properties').get();
      _properties.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        _properties.add(Property.fromMap(data, doc.id));
      }
      if (_properties.isEmpty) {
        _properties.addAll(_exampleStudentProperties);
      }
      _loaded = true;
      notifyListeners();
      print('Loaded ${_properties.length} properties for students.');
    } catch (e) {
      print('Error loading properties: $e');
      _properties
        ..clear()
        ..addAll(_exampleStudentProperties);
      _loaded = true;
      notifyListeners();
    }
  }

  final Set<String> _wishlistIds = {};

  List<Property> get properties => List.unmodifiable(_properties);

  List<Property> landlordProperties({required String landlordId, String? landlordName}) {
    return _properties
        .where((p) => p.landlordId == landlordId || (landlordName != null && p.landlordName == landlordName))
        .toList(growable: false);
  }

  List<Property> get savedProperties =>
      _properties.where((p) => _wishlistIds.contains(p.id)).toList(growable: false);

  bool isSaved(String propertyId) => _wishlistIds.contains(propertyId);

  void toggleWishlist(String propertyId) {
    if (_wishlistIds.contains(propertyId)) {
      _wishlistIds.remove(propertyId);
    } else {
      _wishlistIds.add(propertyId);
    }
    notifyListeners();
  }

  Future<void> addProperty(Property property) async {
    try {
      final docRef = await _firestore.collection('properties').add({
        'title': property.title,
        'location': property.location,
        'pricePerMonth': property.pricePerMonth,
        'distanceFromCampusKm': property.distanceFromCampusKm,
        'roomType': property.roomType,
        'rating': property.rating,
        'amenities': property.amenities,
        'isVerified': property.isVerified,
        'verificationStatus': property.verificationStatus,
        'verificationAdminId': property.verificationAdminId,
        'verificationNote': property.verificationNote,
        'imageUrl': property.imageUrl,
        'landlordName': property.landlordName,
        'landlordId': property.landlordId,
        'latitude': property.latitude,
        'longitude': property.longitude,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the property with the Firestore-generated ID
      final updatedProperty = Property(
        id: docRef.id,
        title: property.title,
        location: property.location,
        pricePerMonth: property.pricePerMonth,
        distanceFromCampusKm: property.distanceFromCampusKm,
        roomType: property.roomType,
        rating: property.rating,
        amenities: property.amenities,
        isVerified: property.isVerified,
        verificationStatus: property.verificationStatus,
        verificationAdminId: property.verificationAdminId,
        verificationNote: property.verificationNote,
        imageUrl: property.imageUrl,
        landlordName: property.landlordName,
        landlordId: property.landlordId,
        latitude: property.latitude,
        longitude: property.longitude,
      );

      _properties.add(updatedProperty);
      notifyListeners();
      print('Property ${docRef.id} added by landlord ${property.landlordId}.');
    } catch (e) {
      print('Error adding property: $e');
      rethrow;
    }
  }

  List<Property> get pendingProperties =>
      _properties.where((p) => p.verificationStatus == 'pending').toList(growable: false);

  List<Property> get approvedProperties => _properties
      .where((p) => p.isVerified && p.verificationStatus == 'approved')
      .toList(growable: false);

  Future<void> updatePropertyVerification(String propertyId,
      {required bool isVerified,
      required String verificationStatus,
      required String adminId,
      String note = ''}) async {
    final index = _properties.indexWhere((p) => p.id == propertyId);
    if (index == -1) return;

    try {
      await _firestore.collection('properties').doc(propertyId).update({
        'isVerified': isVerified,
        'verificationStatus': verificationStatus,
        'verificationAdminId': adminId,
        'verificationNote': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _properties[index] = Property(
        id: _properties[index].id,
        title: _properties[index].title,
        location: _properties[index].location,
        pricePerMonth: _properties[index].pricePerMonth,
        distanceFromCampusKm: _properties[index].distanceFromCampusKm,
        roomType: _properties[index].roomType,
        rating: _properties[index].rating,
        amenities: _properties[index].amenities,
        isVerified: isVerified,
        verificationStatus: verificationStatus,
        verificationAdminId: adminId,
        verificationNote: note,
        imageUrl: _properties[index].imageUrl,
        landlordName: _properties[index].landlordName,
        landlordId: _properties[index].landlordId,
        latitude: _properties[index].latitude,
        longitude: _properties[index].longitude,
      );

      notifyListeners();
      print('Property $propertyId verification updated to $verificationStatus by admin $adminId.');
    } catch (e) {
      print('Error updating property verification: $e');
      // Still update local list even if Firestore fails
      _properties[index] = Property(
        id: _properties[index].id,
        title: _properties[index].title,
        location: _properties[index].location,
        pricePerMonth: _properties[index].pricePerMonth,
        distanceFromCampusKm: _properties[index].distanceFromCampusKm,
        roomType: _properties[index].roomType,
        rating: _properties[index].rating,
        amenities: _properties[index].amenities,
        isVerified: isVerified,
        verificationStatus: verificationStatus,
        verificationAdminId: adminId,
        verificationNote: note,
        imageUrl: _properties[index].imageUrl,
        landlordName: _properties[index].landlordName,
        landlordId: _properties[index].landlordId,
        latitude: _properties[index].latitude,
        longitude: _properties[index].longitude,
      );
      notifyListeners();
    }
  }
}
