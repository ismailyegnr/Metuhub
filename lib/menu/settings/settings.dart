import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:metuhub/menu/settings/set_body.dart';
import 'package:metuhub/menu/settings/feedback.dart';
import 'package:metuhub/menu/home.dart';
import 'package:metuhub/services/push_notification_service.dart';
import 'package:metuhub/user/save_user.dart';
import 'package:easy_localization/easy_localization.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  PushNotificationService _notificationService = PushNotificationService();
  UserLogs _logs = UserLogs();

  logOut() async {
    await _notificationService.userOff();

    await _logs.logout();

    refresh();

    await FirebaseAuth.instance.signOut();
  }

  refresh() {
    setState(() {});
  }

  _logOutAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("log_off".tr()),
            content: Text("sub_log".tr()),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "cancel".tr(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red[600]),
                  )),
              TextButton(
                onPressed: () async {
                  await logOut();

                  await Future.delayed(Duration(milliseconds: 100), () {});

                  Navigator.pop(context);
                },
                child: Text(
                  "ok".tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red[600]),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.4,
          title: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              "title_set".tr().toString(),
              style: TextStyle(fontFamily: "NexaBold"),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.feedback_outlined,
              ),
              tooltip: "Feedback",
              onPressed: () {
                openPage(context);
              },
            ),
            authStatus == AuthStatus.signedIn
                ? IconButton(
                    icon: Icon(
                      FontAwesome.logout,
                      size: 22,
                    ),
                    onPressed: () async {
                      await _logOutAlert();
                    })
                : Container(),
          ],
        ),
        body: SettingsBody(
          notifyParent: refresh,
        ));
  }
}

void openPage(BuildContext context) {
  Navigator.push(context, CupertinoPageRoute(builder: (context) => HelpPage()));
}
