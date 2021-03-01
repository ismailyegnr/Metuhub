import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:metuhub/menu/events/event_detail.dart';
import 'package:metuhub/menu/meetings/meeting_detail.dart';
import 'package:metuhub/menu/home.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController _calendarController;
  DocumentReference _userRef;
  CollectionReference _meetingRef, _eventRef;
  List meetingFavs = [];
  List eventFavs = [];
  Map<DateTime, List> _events = {};
  List _selectedEvents;
  static DateTime dateNow = DateTime.now();
  bool _loading = true;
  DateTime _selectedDay;

  @override
  void initState() {
    super.initState();

    _userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    _meetingRef = FirebaseFirestore.instance.collection("meetings");
    _eventRef = FirebaseFirestore.instance.collection("events");

    _getUserPrefs();
    _selectedDay = DateTime(dateNow.year, dateNow.month, dateNow.day);

    _calendarController = CalendarController();
  }

  _getUserPrefs() async {
    _events = {};

    await _userRef.get().then((value) {
      meetingFavs = value.data()["meeting_favs"];
      eventFavs = value.data()["event_favs"];
    });

    if (meetingFavs.isEmpty && eventFavs.isEmpty) {
      if (mounted) {
        setState(() {
          _selectedEvents = [];
          _loading = false;
        });
      }
    } else {
      _getDateTimes();
    }
  }

  _getDateTimes() async {
    await Future.forEach(meetingFavs, (element) async {
      await _meetingRef.doc("$element").get().then((value) {
        if (value.exists) {
          _manageDates(value, element);
        } else {
          _userRef.update({
            "meeting_favs": FieldValue.arrayRemove([element])
          });
        }
      });
    });

    await Future.forEach(eventFavs, (element) async {
      await _eventRef.doc("$element").get().then((value) {
        if (value.exists) {
          _manageDates(value, element);
        } else {
          _userRef.update({
            "event_favs": FieldValue.arrayRemove([element])
          });
        }
      });
    });

    if (mounted) {
      setState(() {
        _selectedEvents = _events[_selectedDay] ?? [];
        _loading = false;
      });
    }
  }

  _manageDates(value, element) {
    DateTime _eventOn = value.data()["date"].toDate();
    DateTime _willAdded = DateTime(_eventOn.year, _eventOn.month, _eventOn.day);
    DateTime _today = DateTime(dateNow.year, dateNow.month, dateNow.day);

    if (_eventOn.isAfter(_today)) {
      if (_events[_willAdded] == null) {
        _events[_willAdded] = [];
      }
      _events[_willAdded].add(value.data());
    }
  }

  _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedDay = DateTime(day.year, day.month, day.day);
      _selectedEvents = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_loading)
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                buildCalendar(context),
                buildBottomList(),
              ],
            ),
    );
  }

  Expanded buildBottomList() {
    return Expanded(
        child: ListView.builder(
            itemCount: _selectedEvents.length,
            itemBuilder: (context, index) {
              _selectedEvents.sort((a, b) {
                return a['name']
                    .toLowerCase()
                    .compareTo(b['name'].toLowerCase());
              });

              _selectedEvents.sort(
                  (a, b) => (a["date"].toDate()).compareTo(b["date"].toDate()));
              return _buildEventList(context, _selectedEvents[index]);
            }));
  }

  Padding buildCalendar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, left: 4, right: 4, bottom: 12),
      child: Container(
        child: TableCalendar(
          onDaySelected: _onDaySelected,
          events: _events,
          locale: context.locale.toString(),
          headerStyle:
              HeaderStyle(centerHeaderTitle: true, formatButtonVisible: false),
          startDay: DateTime.now(),
          calendarController: _calendarController,
          startingDayOfWeek: StartingDayOfWeek.monday,
        ),
      ),
    );
  }

  Widget _buildEventList(context, element) {
    String _date = DateFormat("HH:mm").format(element["date"].toDate());
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 2, left: 18, right: 18),
      child: Ink(
          decoration: BoxDecoration(
              color: DynamicTheme.of(context).brightness == Brightness.light
                  ? Colors.grey[300]
                  : Colors.white24,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(8))),
          height: 92,
          child: InkWell(
            onTap: () {
              if (element["club"] == null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetails(
                        eventId: element["id"],
                      ),
                    )).then((value) async {
                  await Future.delayed(Duration(milliseconds: 350), () {});
                  if (mounted) {
                    setState(() {
                      _loading = false;
                      _getUserPrefs();
                    });
                  }
                });
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeetingDetails(
                        meetingId: element["id"],
                      ),
                    )).whenComplete(() async {
                  await Future.delayed(Duration(milliseconds: 350), () {});
                  if (this.mounted) {
                    setState(() {
                      _loading = false;
                      _getUserPrefs();
                    });
                  }
                });
              }
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Ink(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: element["img"] == "assets/odtu.png"
                              ? AssetImage(
                                  element["img"],
                                )
                              : CachedNetworkImageProvider(element["img"]),
                          fit: BoxFit.cover)),
                  width: 70,
                  height: 92,
                ),
                SizedBox(
                  width: 260,
                  child: ListTile(
                    title: Text(element["name"]),
                    subtitle: Text(_date),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
