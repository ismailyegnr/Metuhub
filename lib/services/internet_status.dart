import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class ConnectivityCheck extends StatelessWidget {
  final Widget child;

  ConnectivityCheck({@required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
        stream: Connectivity().onConnectivityChanged,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == ConnectivityResult.none) {
            return Center(
              child: FractionallySizedBox(
                heightFactor: .52,
                widthFactor: 1,
                alignment: Alignment.topCenter,
                child: (Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/wifi.png",
                      color: Theme.of(context).accentColor,
                      scale: 4.5,
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
              ),
            );
          } else {
            return child;
          }
        });
  }
}
