import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  // Initialize Firebase with explicit web options (like init_firestore.dart)
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
  const landlordUid = '0cOf5IsWDzgPhREDAKLFiPh0Io52';
  
  print('Setting landlord role for UID: $landlordUid');
  
  await db.collection('users').doc(landlordUid).set({
    'role': 'landlord',
    'fullName': 'Landlord User',
    'email': 'landlord@example.com',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  
  print('✅ Landlord role set successfully!');
  print('Restart app/browser & test landlord login/add property.');
}
