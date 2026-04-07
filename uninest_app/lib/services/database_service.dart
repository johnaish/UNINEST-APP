import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addProperty(Map<String, dynamic> propertyData) async {
    try {
      await _db.collection('properties').add(propertyData);
      print("Property Added Successfully");
    } catch (e) {
      print("Error adding property: $e");
      rethrow; // Pass the error back to the UI to show a message to the user
    }
  }
}
