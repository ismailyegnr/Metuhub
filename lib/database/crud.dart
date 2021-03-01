import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metuhub/actions/act_club.dart';

// ignore: camel_case_types
class crudMethods {
  /// USERS
  Future<void> addUser(user, userUid) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection("users").doc(userUid);

    reference.set(user);
  }

  /// TOPLULUKLAR
  Future<void> addData(club) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(("topluluklar"));

    final docRef = await reference.add(club);

    docRef.update({"id": docRef.id, "status": "waiting", "actions": []});
  }

  Future<void> updateData(club, document) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection("topluluklar").doc(document);

    reference.update(club);
  }

  /// ETKİNLİK VE TOPLANTILAR
  Future<void> addEventorMeet(index, toWhere) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(toWhere);

    final docRef = await reference.add(index);

    docRef.update({"id": docRef.id, "notification": "scheduled"});

    if (toWhere == "meetings") {
      actionToClub(index["clubID"], docRef.id);
    }
  }

  Future<void> updateEventorMeet(index, document, toWhere) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection(toWhere).doc(document);

    reference.update(index);
  }

  Future<void> deleteEventorMeet(document, toWhere) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection(toWhere).doc(document);

    await reference.delete();
  }
}
