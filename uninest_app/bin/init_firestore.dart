import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  // Initialize Firebase with explicit credentials
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCb6ihnr-QxCKjUVfCN-BA0R8B0a4P0IxI',
      authDomain: 'uninest-app-1.firebaseapp.com',
      projectId: 'uninest-app-1',
      storageBucket: 'uninest-app-1.firebasestorage.app',
      messagingSenderId: '43761353988',
      appId: '1:43761353988:web:8d0d5a040ee7d2a65b3c51',
      measurementId: 'G-9GFF4GFWY4',
    ),
  );

  final db = FirebaseFirestore.instance;

  print('Initializing Firestore collections...');

  try {
    // Create users collection with sample users
    await db.collection('users').doc('admin-user-123').set({
      'fullName': 'Admin User',
      'email': 'admin@uninest.com',
      'phone': '+1234567890',
      'username': 'admin',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('✓ Created admin user');

    await db.collection('users').doc('landlord-user-456').set({
      'fullName': 'John Landlord',
      'email': 'landlord@uninest.com',
      'phone': '+1987654321',
      'username': 'johnlandlord',
      'role': 'landlord',
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('✓ Created landlord user');

    await db.collection('users').doc('student-user-789').set({
      'fullName': 'Jane Student',
      'email': 'student@uninest.com',
      'phone': '+1555555555',
      'username': 'janestudent',
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('✓ Created student user');

    // Create properties collection with sample property
    await db.collection('properties').add({
      'title': 'Cozy Studio Near Campus',
      'location': 'Downtown Area',
      'pricePerMonth': 500,
      'distanceFromCampusKm': 2.5,
      'roomType': 'Studio',
      'rating': 4.5,
      'amenities': ['WiFi', 'Parking', 'Furnished'],
      'isVerified': true,
      'verificationStatus': 'approved',
      'verificationAdminId': 'admin-user-123',
      'verificationNote': 'Property meets all standards',
      'imageUrl': '',
      'landlordName': 'John Landlord',
      'landlordId': 'landlord-user-456',
      'latitude': 40.7128,
      'longitude': -74.0060,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('✓ Created sample property');

    // Create bookings collection (empty, ready for use)
    await db.collection('bookings').doc('sample').set({
      'placeholder': true,
    });
    await db.collection('bookings').doc('sample').delete();
    print('✓ Created bookings collection');

    // Create messages collection (empty, ready for use)
    await db.collection('messages').doc('sample').set({
      'placeholder': true,
    });
    await db.collection('messages').doc('sample').delete();
    print('✓ Created messages collection');

    // Create conversations collection (empty, ready for use)
    await db.collection('conversations').doc('sample').set({
      'placeholder': true,
    });
    await db.collection('conversations').doc('sample').delete();
    print('✓ Created conversations collection');

    print('\n✅ Firestore initialization complete!');
    print('Collections created: users, properties, bookings, messages, conversations');
  } catch (e) {
    print('❌ Error initializing Firestore: $e');
  }
}
