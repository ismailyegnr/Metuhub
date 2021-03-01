import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime> selectDate(BuildContext context, selectedDate) async {
  DateTime _dateNow = DateTime.now();

  final DateTime picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2018),
    lastDate: DateTime(2030),
    builder: (BuildContext context, Widget child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.redAccent[400],
          accentColor: Colors.redAccent[400],
          colorScheme: ColorScheme.light(primary: Colors.redAccent[400]),
          buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child,
      );
    },
  );

  if (picked != null && picked != _dateNow) {
    return picked;
  }
  return selectedDate;
}

Future selectTime(BuildContext context, selectedTime) async {
  final TimeOfDay picked = await showTimePicker(
    context: context,
    helpText: EasyLocalization.of(context).locale.toString() == "tr"
        ? "ZAMAN SEÇİN"
        : "SELECT TIME",
    initialTime: selectedTime,
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.redAccent[400],
          accentColor: Colors.redAccent[400],
          colorScheme: ColorScheme.light(primary: Colors.redAccent[400]),
          buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child,
      );
    },
  );

  if (picked != null) {
    return picked;
  }
  return selectedTime;
}

weekdayTurkish(day) {
  switch (day) {
    case 1:
      return "Pazartesi";
    case 2:
      return "Salı";
    case 3:
      return "Çarşamba";
    case 4:
      return "Perşembe";
    case 5:
      return "Cuma";
    case 6:
      return "Cumartesi";
    case 7:
      return "Pazar";
  }
}
