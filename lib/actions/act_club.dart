import 'package:cloud_firestore/cloud_firestore.dart';

actionToClub(clubId, meetingId) {
  DocumentReference _clubRef;
  List<String> newResult = [];

  _clubRef = FirebaseFirestore.instance.collection("topluluklar").doc(clubId);

  List<String> toList(doc) {
    doc["actions"].forEach((item) {
      newResult.add(item);
    });
    newResult.add(meetingId);

    return newResult.toList();
  }

  _clubRef.get().then((doc) {
    toList(doc.data());
    doc.reference.update({"actions": newResult});
  });
}
