import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
// ignore: depend_on_referenced_packages
import 'package:checkmate/pages/calendar.dart';

/// This file contains the FirestoreDataSource class which is responsible for all the CRUD operations in the Firestore database.

class FirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser(String name, String email) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({"id": _auth.currentUser!.uid, "email": email, "name": name});
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

  Future<String> getName() async {
    try {
      final docSnapShot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      return await docSnapShot.data()!["name"];
    } catch (e) {
      print("Couldn't resolve name!! $e.\n");
      return "FAIL";
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

  // =========================================================================
  // Calebdar database manuplation

  // add event to the calendar
  String createDocId() {
    String docId = Uuid().v4();
    return docId;
  }
  Future<void> addCalendarEvent(String eventName, DateTime eventDay) async {
    try {
      // i
      String docId = createDocId();
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('calendar')
          .doc(docId)
          .set({
            'id': docId,
        'event': eventName,
        'day': eventDay,
      });
      // return true;
    } catch (e) {
      print("Exception: $e");
      // return true;
    }
  }

  // // GET THE ID OF DOC
  // Future<String> getDocId(String eventName, DateTime eventDay) async {
  //   try {
  //     String docId = createDocId();
  //     final docSnapShot = await _firestore
  //         .collection('users')
  //         .doc(_auth.currentUser!.uid)
  //         .collection('calendar')
  //         .where('event', isEqualTo: eventName)
  //         .where('day', isEqualTo: eventDay)
  //         .get();
  //     return docSnapShot.docs[0].id;
  //   } catch (e) {
  //     print("Couldn't resolve name $e");
  //     return "FAIL";
  //   }
  // }
  // ------------------------------------------------------------------------
  Future<String?> getDocId(String eventName, DateTime eventDay) async {
  try {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('calendar')
        .where('event', isEqualTo: eventName)
        .where('day', isEqualTo: eventDay)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0].id;
    } else {
      print("No document found for the given event and day.");
      return null;
    }
  } catch (e) {
    print("Couldn't resolve document ID: $e");
    return null;
  }
}

  // delete event from the calendar
  // Future<void> deleteCalendarEvent(String id) async {
  //   try {
  //     // print(id);
  //     await final collectionRef _firestore
  //         .collection('users')
  //         .doc(_auth.currentUser!.uid)
  //         .collection('calendar');
  //         final querySnapshot = await collectionRef.get();
  //   for (var doc in querySnapshot.docs) {
  //     await doc.reference.delete();
  //   }
  //   print("All calendar events deleted successfully.");
  //   } catch (e) {
  //     print("Exception: $e");
  //   }
  // }
//   Future<void> deleteAllCalendarEvents(String id) async {
//   try {
//     await _firestore
//         .collection('users')
//         .doc(_auth.currentUser!.uid)
//         .collection('calendar')
//         .where('id', isEqualTo: id)
//         .get()
//         .then((querySnapshot) {
//           for (var doc in querySnapshot.docs) {
//             doc.reference.delete();
//           }
//         });
        
//     // final querySnapshot = await collectionRef.get();
//     // for (var doc in querySnapshot.docs) {
//     //   // if (doc.id == docSnapShot.docs[0].id) {
//     //   //   continue;
//     //   // }
//     //   await doc.reference.delete();
//     // }
//     print("All calendar events deleted successfully.");
//   } catch (e) {
//     print("Exception: $e");
//   }
// }


Future<void> deleteCalendarEvent(String eventId) async {
  try {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('calendar')
        .doc(eventId)
        .delete();
    print("Event with ID $eventId deleted successfully.");
  } catch (e) {
    print("Exception: $e");
  }
}

// ==============================================================
// Future<void> addGoals(String eventName, DateTime eventDay) async {
//     try {
      
//       String docId = createDocId();
//       await _firestore
//           .collection('users')
//           .doc(_auth.currentUser!.uid)
//           .collection('calendar')
//           .doc(docId)
//           .set({
//             'id': docId,
//         'event': eventName,
//         'day': eventDay,
//       });
//     } catch (e) {
//       print("Exception: $e");
//     }
// }
}

