import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script to clean up invalid user roles in Firestore.
/// Sets any unrecognized roles to 'student' as default.
/// Also ensures all users have a role field.
///
/// Run this script once after deploying the app to fix existing data.
///
/// Usage: Add this to your main.dart temporarily and run the app,
/// or run as a standalone Dart script with proper Firebase config.
Future<void> cleanupUserRoles() async {
  // Initialize Firebase if not already done
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final usersCollection = firestore.collection('users');

  print('Starting user role cleanup...');

  try {
    final querySnapshot = await usersCollection.get();

    int updatedCount = 0;
    int totalCount = querySnapshot.docs.length;

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final role = data['role'] as String?;

      if (role == null || !_isValidRole(role)) {
        print('Updating user ${doc.id}: invalid/null role "$role" -> "student"');
        await doc.reference.update({
          'role': 'student',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        updatedCount++;
      }
    }

    print('Cleanup complete: $updatedCount/$totalCount users updated.');
  } catch (e) {
    print('Error during cleanup: $e');
  }
}

bool _isValidRole(String role) {
  return role == 'admin' || role == 'landlord' || role == 'student';
}

/// Example usage in main.dart (temporary):
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   await cleanupUserRoles(); // Run once, then remove
///   runApp(MyApp());
/// }
