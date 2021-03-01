import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metuhub/menu/home.dart';
import 'package:metuhub/services/push_notification_service.dart';

class UserFavs {
  PushNotificationService notifications = PushNotificationService();
  addLike(docID, collection) {
    DocumentReference _userRef;
    List<String> newResult = [];

    _userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    List<String> toList(doc) {
      doc["${collection}_favs"].forEach((item) {
        newResult.add(item);
      });
      newResult.add(docID);

      return newResult.toList();
    }

    //add notification subscription
    notifications.newLike(docID);

    _userRef.get().then((doc) async {
      toList(doc.data());
      doc.reference.update({"${collection}_favs": newResult});
    });
  }

  unLike(docID, collection) {
    DocumentReference _userRef;
    List<String> newResult = [];

    _userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    List<String> toList(doc) {
      doc["${collection}_favs"].forEach((item) {
        if (item != docID) {
          newResult.add(item);
        }
      });
      return newResult.toList();
    }

    //delete notification subscription
    notifications.disLike(docID);

    _userRef.get().then((doc) async {
      toList(doc.data());
      doc.reference.update({"${collection}_favs": newResult});
    });
  }
}
