import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metuhub/menu/home.dart';
import 'package:metuhub/services/theme.dart';
import 'package:flutter_config/flutter_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterConfig.loadEnvVariables();

  await Firebase.initializeApp();

  runApp(EasyLocalization(
    child: MyApp(),
    path: "langs",
    useOnlyLangCode: true,
    startLocale: Locale("tr"),
    fallbackLocale: Locale('en'),
    saveLocale: true,
    supportedLocales: [Locale("tr"), Locale("en")],
  ));
}

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => appTheme(brightness),
      themedWidgetBuilder: (context, data) {
        return MaterialApp(
          home: HomePage(),
          navigatorKey: navigatorKey,
          theme: data,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          locale: context.locale,
        );
      },
    );
  }
}
