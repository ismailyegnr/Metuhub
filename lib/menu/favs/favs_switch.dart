import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:metuhub/menu/favs/calendar_page.dart';
import 'package:metuhub/menu/favs/favs_page.dart';
import 'package:metuhub/menu/home.dart';

class FavPage extends StatefulWidget {
  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            bottom: authStatus == AuthStatus.notSignedIn
                ? null
                : TabBar(
                    labelColor: Colors.redAccent[400],
                    tabs: [
                      Tab(
                        icon: Icon(Icons.favorite),
                      ),
                      Tab(
                        icon: Icon(Icons.today),
                      ),
                    ],
                  ),
            title: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                "fav_tab".tr(),
                style: TextStyle(fontFamily: "NexaBold"),
              ),
            ),
            elevation: 0.6,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          body: authStatus == AuthStatus.notSignedIn
              ? buildNotSignedPage()
              : TabBarView(children: <Widget>[
                  FavoritesPage(),
                  CalendarPage(),
                ])),
    );
  }

  Container buildNotSignedPage() {
    return Container(
        child: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text("fav_log".tr()),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: OutlineButton(
            child: new Text(
              "go_set".tr(),
              style: TextStyle(fontFamily: "Mulish"),
            ),
            onPressed: () {
              setState(() {
                currentIndex = 4;
                mainPageController.jumpToPage(4);
              });
            },
            highlightedBorderColor: Colors.red,
            textColor: Colors.red[600],
            borderSide: BorderSide(color: Colors.red[600]),
            shape: StadiumBorder(),
          ),
        ),
      ]),
    ));
  }
}
