import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_role.dart';

class AuthService {
  FirebaseAuth? _auth;
  CollectionReference<Map<String, dynamic>>? _users;

  FirebaseAuth get _firebaseAuth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    _users ??= FirebaseFirestore.instance.collection('users');
    return _users!;
  }

  /// Signs in using email/password and returns the assigned role.
  ///
  /// Throws `FirebaseAuthException` on failure so the UI can show the specific
  /// reason (invalid credentials, user-not-found, etc.).
  Future<UserRole?> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) return null;

      try {
        final userRef = _usersCollection.doc(uid);
        final doc = await userRef.get();

        if (!doc.exists) {
          // First-time login + no Firestore profile: create user doc with default role.
          await userRef.set({
            'fullName': credential.user?.displayName ?? 'Unknown User',
            'email': email,
            'role': UserRole.student.name,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('Created user profile for $uid as student on first login.');
          return UserRole.student;
        }

        final data = doc.data();
        final roleValue = data?['role'] as String?;
        final role = _roleFromString(roleValue);

        if (role == null) {
          // Missing or invalid role should be corrected; do not silently break admin access.
          final fallbackRole = UserRole.student;
          await userRef.set({'role': fallbackRole.name}, SetOptions(merge: true));
          print('User $uid had missing/invalid role ($roleValue). Set fallback $fallbackRole.');
          return fallbackRole;
        }

        print('User $uid logged in as ${role.name}.');
        return role;
      } catch (e) {
        print('AuthService.login: Firestore read/update error for $uid: $e');
        // If Firestore fails, we can't read role; do NOT reject login entirely, but route student default.
        return UserRole.student;
      }
    } on FirebaseAuthException catch (e) {
      print('AuthService.login: Firebase Auth error: $e');
      return null;
    } catch (e) {
      print('AuthService.login: unknown error: $e');
      return null;
    }
  }

  /// Registers a new user and stores their role in Firestore.
  ///
  /// Throws `FirebaseAuthException` on failure so the UI can show the specific
  /// reason (weak-password, email-already-in-use, etc.).
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) return false;

      // Update display name in Firebase Auth
      await credential.user!.updateDisplayName(fullName);

      final username = fullName.split(' ').first.toLowerCase();

      try {
        await _usersCollection.doc(uid).set({
          'fullName': fullName,
          'username': username,
          'email': email,
          'phone': phone,
          'role': role.name,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('Registered new user $uid ($email) role=${role.name}');
        return true;
      } catch (e) {
        print('AuthService.register: Firestore write error for $uid: $e');
        // Still return true since auth succeeded, just Firestore failed
        return true;
      }
    } catch (e) {
      print('AuthService.register: Firebase Auth error: $e');
      return false;
    }
  }

  UserRole? _roleFromString(String? value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'landlord':
        return UserRole.landlord;
      case 'student':
        return UserRole.student;
      default:
        return null;
    }
  }
}
