import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ConnectionStatus {
  checkConnection() async {
    bool hasConnection;

    try {
      final result = await InternetAddress.lookup('example.com');
      print(result);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    return hasConnection;
  }

  noConSnackBar(scaffoldKey) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("no_connect".tr()),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: "retry".tr(),
        onPressed: () async {
          bool newConnection = await checkConnection();
          if (newConnection == false) {
            noConSnackBar(scaffoldKey);
          } else {
            connectedSnackBar(scaffoldKey);
          }
        },
      ),
    ));
  }

  connectedSnackBar(scaffoldKey) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.green[700],
      content: Text("connected".tr()),
      duration: const Duration(seconds: 2),
    ));
  }
}

Widget noInternetConnection() {
  return Center(
    child: (Column(
      children: <Widget>[
        Image.asset(
          "assets/wifi.png",
          scale: 3,
        ),
        SizedBox(
          height: 28,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "There is no active internet connection.",
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    )),
  );
}
