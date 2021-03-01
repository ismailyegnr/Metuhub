import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:metuhub/menu/settings/edit_prf.dart';
import 'package:metuhub/menu/home.dart';
import 'package:metuhub/services/push_notification_service.dart';
import 'package:metuhub/user/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBody extends StatefulWidget {
  final Function() notifyParent;

  const SettingsBody({Key key, this.notifyParent}) : super(key: key);
  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  PushNotificationService _notificationService = PushNotificationService();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  DocumentReference reference;
  bool _delayed = false;

  @override
  void initState() {
    super.initState();
  }

  refresh() {
    setState(() {});
  }

  void _notifChanged(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("notification", value);

    if (authStatus == AuthStatus.signedIn) {
      value == true
          ? _notificationService.userOnline()
          : _notificationService.userOff();
    }

    setState(() {
      willNotifs = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          authStatus == AuthStatus.signedIn ? buildProfile() : _logButtons(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          SizedBox(
            height: 20,
          ),
          buildNotifications(),
          buildLanguage(),
          buildTheme(),
        ],
      ),
    );
  }

  StreamBuilder<DocumentSnapshot> buildProfile() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var doc = snapshot.data.data();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: Icon(Icons.person),
                title: Text("${doc["username"]} ${doc["surname"]}"),
                subtitle: context.locale == Locale("tr")
                    ? Text(doc["depTR"])
                    : Text(doc["depEN"]),
                trailing: IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 22,
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfile(
                                dept: context.locale == Locale("tr")
                                    ? doc["depTR"]
                                    : doc["depEN"],
                              ),
                          fullscreenDialog: true)),
                ),
              ),
            ),
          );
        });
  }

  Padding buildNotifications() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Icon(Icons.notifications_none),
        title: Text(
          "set_notif".tr(),
        ),
        trailing: Switch(
          value: willNotifs,
          onChanged: (value) => _notifChanged(value),
        ),
      ),
    );
  }

  Padding buildLanguage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: Icon(Icons.language),
          title: Text(
            "set_lang".tr(),
          ),
          trailing: _languageButton()),
    );
  }

  Padding buildTheme() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: Icon(Icons.bedtime),
          title: Text(
            "theme".tr(),
          ),
          trailing: IconButton(
            icon: Icon(Icons.colorize_sharp),
            onPressed: showChooser,
          )),
    );
  }

  Widget _logButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 38,
            width: 90,
            child: TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(8)),
                    ),
                    backgroundColor: Colors.grey[300]),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => SignIn(
                              from: "settings",
                              initIndex: 0,
                            ))).then((value) => widget.notifyParent()),
                child: Text(
                  "log".tr(),
                  style: TextStyle(color: Colors.black87),
                )),
          ),
          SizedBox(
            height: 38,
            width: 90,
            child: TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(8)),
                    ),
                    backgroundColor: Colors.grey[200]),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => SignIn(
                              from: "settings",
                              initIndex: 1,
                            ))).then((value) => widget.notifyParent()),
                child: Text(
                  "sign".tr(),
                  style: TextStyle(color: Colors.black87),
                )),
          ),
        ],
      ),
    );
  }

  void showChooser() {
    showDialog<void>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("sel_them".tr()),
            children: <Widget>[
              RadioListTile<Brightness>(
                value: Brightness.light,
                groupValue: Theme.of(context).brightness,
                onChanged: (Brightness value) {
                  DynamicTheme.of(context).setBrightness(Brightness.light);
                },
                title: Text('light'.tr()),
              ),
              RadioListTile<Brightness>(
                value: Brightness.dark,
                groupValue: Theme.of(context).brightness,
                onChanged: (Brightness value) {
                  DynamicTheme.of(context).setBrightness(Brightness.dark);
                },
                title: Text('dark'.tr()),
              ),
            ],
          );
        });
  }

  _languageButton() {
    Locale _currentLang = context.locale;

    String _selectedLang = _currentLang.toString();
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        hint: Padding(
          padding: const EdgeInsets.only(
            left: 3,
          ),
          child: _delayed == true
              ? SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                )
              : Image.asset(
                  _selectedLang != "tr"
                      ? 'icons/flags/png/sh.png'
                      : 'icons/flags/png/tr.png',
                  package: 'country_icons',
                  scale: 2.5,
                ),
        ),
        iconSize: 0,
        items: <String>['English', 'Türkçe']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) {
          _langChanged(value);
        },
      ),
    );
  }

  _langChanged(value) async {
    if (context.locale == Locale("tr") && value == "English") {
      setState(() {
        _delayed = true;
      });
      await Future.delayed(Duration(milliseconds: 800), () {});
      context.locale = Locale("en");
      DynamicTheme.of(context).setThemeData(
          new ThemeData(primaryColor: Theme.of(context).primaryColor));
      setState(() {
        _delayed = false;
      });
    } else if (context.locale == Locale("en") && value == "Türkçe") {
      setState(() {
        _delayed = true;
      });
      await Future.delayed(Duration(milliseconds: 800), () {});
      context.locale = Locale("tr");
      DynamicTheme.of(context).setThemeData(
          new ThemeData(primaryColor: Theme.of(context).primaryColor));
      setState(() {
        _delayed = false;
      });
    }
  }
}
