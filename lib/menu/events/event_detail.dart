import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:metuhub/actions/user_favs.dart';
import 'package:metuhub/menu/events/add_event.dart';
import 'package:metuhub/actions/photo_dets.dart';
import 'package:metuhub/menu/home.dart';
import 'package:metuhub/services/theme.dart';

class EventDetails extends StatefulWidget {
  final String eventId;

  const EventDetails({Key key, this.eventId}) : super(key: key);
  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  DocumentReference _reference;
  UserFavs userLikes = UserFavs();
  bool _fav = false;
  DocumentReference _userRef;

  @override
  void initState() {
    _reference = FirebaseFirestore.instance
        .collection("events")
        .doc("${widget.eventId}");

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (authStatus == AuthStatus.signedIn) {
        _userRef = FirebaseFirestore.instance.collection("users").doc(userId);

        _userRef.get().then((doc) {
          doc.data()["event_favs"].forEach((item) {
            if (item == widget.eventId) {
              setState(() {
                _fav = true;
              });
            }
          });
        });
      }
    });
  }

  _editIcon(document) {
    if (authStatus == AuthStatus.signedIn) {
      if (isAdmin == true || document["editor"] == userId) {
        return IconButton(
          icon: Icon(
            Icons.edit,
          ),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddEvent(
                        snap: document,
                      ))),
        );
      }
      return Container();
    } else {
      return Container();
    }
  }

  _isFavorited(document) {
    if (_fav == true) {
      userLikes.unLike(document["id"], "event");
      setState(() {
        _fav = false;
      });

      final snackBar = SnackBar(
        content: Text("${document['name']}" + "fav_off".tr()),
        duration: Duration(milliseconds: 1200),
        action: SnackBarAction(
          label: "fav_back".tr(),
          onPressed: () {
            userLikes.addLike(document["id"], "event");
            setState(() {
              _fav = true;
            });
          },
        ),
      );
      return snackBar;
    } else {
      userLikes.addLike(document["id"], "event");
      setState(() {
        _fav = true;
      });

      final snackBar = SnackBar(
        content: Text("${document['name']}" + "fav_on".tr()),
        duration: Duration(milliseconds: 1200),
        action: SnackBarAction(
          label: "fav_back".tr(),
          onPressed: () {
            userLikes.unLike(document["id"], "event");
            setState(() {
              _fav = false;
            });
          },
        ),
      );
      return snackBar;
    }
  }

  @override
  Widget build(BuildContext context) {
    var _lang = context.locale;
    return StreamBuilder(
      stream: _reference.snapshots(),
      builder: (context, snapshot) {
        var screenWidth = MediaQuery.of(context).size.width * 2 / 3;
        var adjustedHeight = screenWidth * 1.5;

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var document = snapshot.data.data();

        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              authStatus == AuthStatus.signedIn
                  ? StreamBuilder<Object>(
                      stream: null,
                      builder: (context, snapshot) {
                        return IconButton(
                            icon: Icon(
                              _fav == true
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              size: 26,
                            ),
                            onPressed: () {
                              var snack = _isFavorited(document);
                              Scaffold.of(context).showSnackBar(snack);
                            });
                      })
                  : Container(),
              _editIcon(document)
            ],
            elevation: 0.4,
            title: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                document["name"],
                overflow: TextOverflow.fade,
                style: TextStyle(fontFamily: "NexaBold"),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildEventImage(
                      adjustedHeight, screenWidth, document, context),
                  Container(
                      decoration: BoxDecoration(
                          border: Border(top: BorderSide(width: 0.16)))),
                  SizedBox(
                    height: 8,
                  ),
                  buildEventName(document),
                  divider(),
                  buildEventTime(context, document, _lang),
                  divider(),
                  buildEventPlace(context, document),
                  divider(),
                  buildEventDetails(context, document),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Padding divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(
        thickness: 0.8,
      ),
    );
  }

  Row buildEventImage(double adjustedHeight, double screenWidth, document,
      BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Ink(
          height: adjustedHeight,
          width: screenWidth,
          child: Hero(
            tag: document["img"],
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoDetails(
                    photoURL: document["img"],
                  ),
                ),
              ),
              child: document["img"] == "assets/odtu.png"
                  ? Image.asset(
                      document["img"],
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: document["img"],
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Padding buildEventName(document) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10, left: 9, right: 12),
      child: AutoSizeText(
        document["name"],
        minFontSize: 20,
      ),
    );
  }

  Padding buildEventTime(BuildContext context, document, Locale _lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 6,
          ),
          Icon(
            Icons.access_time,
            size: 28,
            color: Theme.of(context).accentColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat("dd.MM.yyyy")
                              .format((document["date"].toDate())) +
                          "  ",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      _lang == Locale("tr")
                          ? document["day"]
                          : DateFormat("EEEE")
                              .format((document["date"].toDate())),
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  TimeOfDay.fromDateTime(document["date"].toDate())
                      .format(context),
                  style: TextStyle(fontSize: 15, color: textColor(context)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding buildEventPlace(BuildContext context, document) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 6,
          ),
          Icon(Icons.location_on_outlined,
              size: 28, color: Theme.of(context).accentColor),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: AutoSizeText(
                  document["place"],
                  maxLines: 3,
                )),
          )
        ],
      ),
    );
  }

  Column buildEventDetails(BuildContext context, document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Text(
            "details".tr(),
            style: TextStyle(fontSize: 18, color: textColor(context)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
          child: Text(
            document["explain"],
          ),
        ),
      ],
    );
  }
}
