import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get current user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  /// Update current user data in Firestore
  Future<void> updateCurrentUserData(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _db.collection('users').doc(user.uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  /// Update current user's display name in Firebase Auth
  Future<void> updateDisplayName(String displayName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.updateDisplayName(displayName);
      await updateCurrentUserData({'fullName': displayName});
    } catch (e) {
      print('Error updating display name: $e');
      rethrow;
    }
  }

  /// Request email change flow for the current user in Firebase Auth and Firestore
  Future<void> updateEmail(String email) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Firebase 6.x may require using verifyBeforeUpdateEmail.
      await user.verifyBeforeUpdateEmail(email);
      await _db.collection('users').doc(user.uid).update({'email': email});
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    }
  }

  /// Update current user password in Firebase Auth
  Future<void> updatePassword(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.updatePassword(password);
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }
}
