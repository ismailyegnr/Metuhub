import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:metuhub/main.dart';
import 'package:metuhub/menu/events/event_detail.dart';
import 'package:metuhub/menu/meetings/meeting_detail.dart';
import 'package:metuhub/menu/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

// herkes notifications topicine üye oluyor.

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  DocumentReference _userRef;

  Future initialize() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        var data = message["data"];
        _navigator(data);
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        var data = message["data"];
        _navigator(data);
        print("onResume: $message");
      },
    );
  }

  _navigator(data) {
    if (data["type"] == "meeting") {
      navigatorKey.currentState.push(MaterialPageRoute(
          builder: (_) => MeetingDetails(
                meetingId: data["id"],
              )));
    } else if (data["type"] == "event") {
      navigatorKey.currentState.push(MaterialPageRoute(
          builder: (_) => EventDetails(
                eventId: data["id"],
              )));
    }
  }

  //user logged in
  userOnline() async {
    _userRef = FirebaseFirestore.instance.collection("users").doc(userId);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List favs = [];

    if (prefs.getBool("notification") == true) {
      await _userRef.get().then((value) async {
        favs = value.data()["meeting_favs"];
        favs.addAll(value.data()["event_favs"]);
      });

      _fcm.subscribeToTopic("notifications");
      Future.forEach(favs, (element) => _fcm.subscribeToTopic(element));
    }
  }

  //user logged out
  userOff() async {
    _userRef = FirebaseFirestore.instance.collection("users").doc(userId);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List favs = [];

    if (prefs.getBool("notification") == true) {
      await _userRef.get().then((value) async {
        favs = value.data()["meeting_favs"];
        favs.addAll(value.data()["event_favs"]);
      });

      _fcm.unsubscribeFromTopic("notifications");
      Future.forEach(favs, (element) => _fcm.unsubscribeFromTopic(element));
    }
  }

  //user liked an event or meeting
  newLike(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("notification") == true) {
      _fcm.subscribeToTopic(id);
    }
  }

  //user unliked an event or meeting
  disLike(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("notification") == true) {
      _fcm.unsubscribeFromTopic(id);
    }
  }
}
