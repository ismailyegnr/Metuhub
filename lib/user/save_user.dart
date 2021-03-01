import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metuhub/menu/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLogs {
  var list;
  login(user) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var admin;

    if (user != null) {
      authStatus = AuthStatus.signedIn;
      userId = user.uid;
      userMail = user.email;
      await getUser(userId).then((value) => admin = value);
      isAdmin = admin;
      preferences.setBool("logged", true);
      preferences.setString("userId", user.uid);
      preferences.setString("userMail", user.email);
      preferences.setBool("isAdmin", admin);
    }
  }

  Future<bool> getUser(userId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get()
        .then((value) {
      list = value.data()["isAdmin"];
    });
    return Future<bool>.value(list);
  }

  logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    authStatus = AuthStatus.notSignedIn;
    preferences.setBool("logged", false);
  }

  checkLog() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool logged;

    logged = preferences.getBool("logged");

    if (logged == true) {
      authStatus = AuthStatus.signedIn;
      userId = preferences.getString("userId");
      userMail = preferences.getString("userMail");
      isAdmin = preferences.getBool("isAdmin");
    } else {
      authStatus = AuthStatus.notSignedIn;
    }
  }
}
