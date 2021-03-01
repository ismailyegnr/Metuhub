import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:metuhub/menu/meetings/meeting_detail.dart';
import 'package:metuhub/menu/meetings/add_meetings.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MeetingsPage extends StatefulWidget {
  @override
  _MeetingsPageState createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  static DateTime now = DateTime.now();
  DateTime _start = DateTime(now.year, now.month, now.day);

  _stream() {
    return FirebaseFirestore.instance
        .collection("meetings")
        .where("date", isGreaterThanOrEqualTo: _start)
        .orderBy("date")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.8,
        title: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "title_meet".tr(),
            style: TextStyle(fontFamily: "NexaBold"),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(context,
                CupertinoPageRoute(builder: (context) => AddMeeting())),
            iconSize: 24,
          )
        ],
      ),
      body: StreamBuilder(
          stream: _stream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            if (snapshot.data.documents.length == 0) {
              return Center(
                child: FractionallySizedBox(
                  heightFactor: .52,
                  widthFactor: 1,
                  alignment: Alignment.topCenter,
                  child: (Column(
                    children: <Widget>[
                      Image.asset(
                        "assets/no_meet.png",
                        scale: 1.2,
                      ),
                      SizedBox(
                        height: 28,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          "no_meet".tr(),
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  )),
                ),
              );
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.495),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.docs[index]),
            );
          }),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snap) {
    var snapshot = snap.data();
    String _date = DateFormat("dd.MM.yyyy").format((snapshot["date"].toDate()));
    String _day = context.locale == Locale("tr")
        ? snapshot["day"]
        : DateFormat("EEEE").format((snapshot["date"].toDate()));
    String _time =
        TimeOfDay.fromDateTime(snapshot["date"].toDate()).format(context);

    var deviceWidth = (MediaQuery.of(context).size.width - 44) / 2;

    return Ink(
      padding: EdgeInsets.symmetric(horizontal: 11),
      height: 270,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 20),
          Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                color: DynamicTheme.of(context).brightness == Brightness.light
                    ? Colors.grey[300].withOpacity(0.8)
                    : Colors.white24),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeetingDetails(
                        meetingId: snap.id,
                      ),
                    ));
              },
              child: Column(
                children: <Widget>[
                  Ink(
                    width: deviceWidth,
                    height: deviceWidth * 1.5,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: snapshot["img"] == "assets/odtu.png"
                                ? AssetImage(snapshot["img"])
                                : CachedNetworkImageProvider(snapshot["img"]))),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(8),
                    title: Container(
                      height: 34,
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        snapshot["name"],
                        maxLines: 2,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 6,
                        ),
                        Text(_date + " " + _day),
                        SizedBox(
                          height: 4,
                        ),
                        Text(_time),
                        SizedBox(
                          height: 4,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
