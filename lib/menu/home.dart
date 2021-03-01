import 'package:ant_icons/ant_icons.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:metuhub/menu/clubs/clubs_page.dart';
import 'package:metuhub/menu/events/events_page.dart';
import 'package:metuhub/menu/favs/favs_switch.dart';
import 'package:metuhub/menu/meetings/meetings_page.dart';
import 'package:metuhub/menu/settings/settings.dart';
import 'package:metuhub/services/net_connection.dart';
import 'package:metuhub/services/push_notification_service.dart';
import 'package:metuhub/user/save_user.dart';
import 'package:ionicons/ionicons.dart' as Ionics;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

String userMail;
String userId;

enum AuthStatus { signedIn, notSignedIn }

var authStatus = AuthStatus.notSignedIn;

bool isAdmin;

int currentIndex = 0;

final PageController mainPageController = PageController();

bool willNotifs = true;

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PushNotificationService _pushNotificationService = PushNotificationService();
  ConnectionStatus _connectionStatus = ConnectionStatus();
  UserLogs _logs = UserLogs();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      start();
    });

    _checkForConnection();

    _pushNotificationService.initialize();

    _notifControl();
  }

  start() async {
    await _logs.checkLog();

    setState(() {});
  }

  _checkForConnection() async {
    bool connection = await _connectionStatus.checkConnection();
    if (connection == false) {
      _connectionStatus.noConSnackBar(_scaffoldKey);
    }
  }

  _notifControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      willNotifs = prefs.getBool("notification") ?? true;
    });
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: _buildCustomNavigationBar(),
      body: PageView(
        onPageChanged: (page) {
          if (mounted) {
            setState(() {
              currentIndex = page;
            });
          }
        },
        controller: mainPageController,
        children: <Widget>[
          Community(),
          EventPage(),
          MeetingsPage(),
          FavPage(),
          Settings(),
        ],
      ),
    );
  }

  Widget _buildCustomNavigationBar() {
    return BottomNavigationBar(
      elevation: 4,
      iconSize: 27,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: DynamicTheme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white, //Color.fromRGBO(227, 24, 55, 1), //Color(0xff0c18fb),
      /*strokeColor: DynamicTheme.of(context).brightness == Brightness.light
          ? Colors.grey[800].withOpacity(0.3)
          : Colors.white.withOpacity(0.3), */

      unselectedItemColor:
          DynamicTheme.of(context).brightness == Brightness.light
              ? Colors.grey[600].withOpacity(0.9)
              : Colors.white54,
      backgroundColor: DynamicTheme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black26,
      showSelectedLabels: false,
      showUnselectedLabels: false,

      items: [
        BottomNavigationBarItem(
            label: "title_top".tr(),
            icon: currentIndex == 0
                ? Icon(Ionics.Ionicons.school)
                : Icon(Ionics.Ionicons.school_outline)),
        BottomNavigationBarItem(
            label: "title_etk".tr(),
            icon: currentIndex == 1
                ? Icon(
                    AntIcons.notification,
                  )
                : Icon(
                    AntIcons.notification_outline,
                  )),
        BottomNavigationBarItem(
          label: "title_meet".tr(),
          icon: currentIndex == 2
              ? Icon(
                  MaterialCommunityIcons.getIconData("account-group"),
                )
              : Icon(
                  MaterialCommunityIcons.getIconData("account-group-outline"),
                ),
        ),
        BottomNavigationBarItem(
            label: "title_fav".tr(),
            icon: currentIndex == 3
                ? Icon(
                    AntDesign.getIconData("star"),
                  )
                : Icon(
                    AntDesign.getIconData("staro"),
                  )),
        BottomNavigationBarItem(
          label: "title_set".tr(),
          icon: Icon(
            AntDesign.getIconData("user"),
          ),
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
          mainPageController.jumpToPage(index);
        });
      },
    );
  }
}
