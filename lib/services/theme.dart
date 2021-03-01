import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

appTheme(brightness) {
  switch (brightness) {
    case Brightness.dark: //dark case
      return ThemeData(
          brightness: brightness,
          scaffoldBackgroundColor: Colors.black87.withOpacity(0.85),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              primary: Colors.black,
            ),
          ),
          textTheme: TextTheme(headline3: TextStyle(color: Colors.red)),
          appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(color: Colors.white),
              textTheme: TextTheme(
                  subtitle2: TextStyle(
                      color: Colors.black,
                      fontFamily: "NexaBold",
                      fontSize: 20),
                  headline6: TextStyle(
                      color: Colors.white,
                      fontFamily: "NexaBold",
                      fontSize: 20))));
      break;
    default: // light case
      return ThemeData(
          brightness: brightness,
          primaryColor: Colors.indigo,
          indicatorColor: Colors.indigo,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              primary: Colors.black,
            ),
          ),
          accentColor: Colors.indigo,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
              color: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              textTheme: TextTheme(
                  headline6: TextStyle(
                      color: Colors.black,
                      fontFamily: "NexaBold",
                      fontSize: 20))));
  }
}

Color textColor(BuildContext context) {
  return DynamicTheme.of(context).brightness == Brightness.light
      ? Colors.grey[600]
      : Colors.white70;
}
