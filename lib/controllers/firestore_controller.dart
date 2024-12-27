import 'package:checkmate/controllers/user_provider.dart';
import 'package:checkmate/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// This file contains the FirestoreDataSource class which is responsible for all the CRUD operations in the Firestore database.

class FirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser(String name, String email) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "id": _auth.currentUser!.uid,
        "email": email.toLowerCase(),
        "name": name,
        "xp": 0,
      });
      print("===============================================");
      print(_auth.currentUser!.uid);
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final DocumentReference userDoc =
          _firestore.collection("users").doc(userId);

      // Delete subcollections
      final subcollections = await userDoc.collection("routine").get();
      for (var doc in subcollections.docs) {
        await doc.reference.delete();
      }

      // Delete main document
      await userDoc.delete();
      print("User $userId deleted successfully.");
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  // Updates the name of the user in the Firestore database
  Future<void> updateName(String name, BuildContext context) async {
    try {
      await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .update({"name": name});

      // Fetching the user's name for extra security
      final userDoc = await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();
      if (userDoc.exists) {
        Provider.of<UserProvider>(context, listen: false).setUser(UserModel(
          name: userDoc.data()!["name"],
          email: userDoc.data()!["email"],
          xp: userDoc.data()!["xp"],
        ));
      }
    } catch (e) {
      print("Error updating name: $e");
    }
  }

  Future<bool> addRoutine(String title, int duration) async {
    try {
      var uuid =
          Uuid().v4(); // Creates a unique id for the collection (Primary Key)
      DateTime data = DateTime.now();
      await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .collection("routine")
          .doc(uuid)
          .set({
        "id": uuid,
        "title": title,
        "duration": duration,
        "time": data,
        "isDone": false,
      });
      return true;
    } catch (e) {
      print("Exception: $e");
      return true;
    }
  }
}
