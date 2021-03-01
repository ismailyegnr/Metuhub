import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:metuhub/actions/user_favs.dart';
import 'package:metuhub/menu/meetings/meeting_detail.dart';
import 'package:metuhub/menu/clubs/club_detail.dart';
import 'package:metuhub/menu/clubs/clubs_page.dart';
import 'package:metuhub/menu/home.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  DocumentReference _userRef;
  List _clubs = [];
  bool _ready = false;
  List _finalClubs;
  List _likedMeetings = [];
  CollectionReference _meetingRef;
  CollectionReference _clubRef;
  DateTime dateNow = DateTime.now();
  UserFavs userLikes = UserFavs();
  DateTime today;

  @override
  void initState() {
    super.initState();
    _clubRef = FirebaseFirestore.instance.collection("topluluklar");
    _meetingRef = FirebaseFirestore.instance.collection("meetings");
    today = DateTime(dateNow.year, dateNow.month, dateNow.day);

    _getUserFavs();
  }

  /// giriş yapan userın favladığı club listesi
  _getUserFavs() async {
    _userRef = FirebaseFirestore.instance.collection("users").doc(userId);
    _finalClubs = [];
    await _userRef.get().then((value) {
      _clubs = value.data()["club_favs"];
      _likedMeetings = value.data()["meeting_favs"];
    });
    if (_clubs.isEmpty) {
      if (this.mounted) {
        setState(() {
          _ready = true;
        });
      }
    } else {
      _getFavInfos();
    }
  }

  ///club listteki toplulukların düzenlediği meetingleri alması için başka fonka gönderiyor.
  _getFavInfos() async {
    await Future.forEach(_clubs, (element) async {
      await _clubRef.doc("$element").get().then((value) async {
        if (value.exists) {
          await _actionInforms(value.data(), element);
        } else {
          _userRef.update({
            "club_favs": FieldValue.arrayRemove([element])
          });
        }
      });
    });

    if (this.mounted) {
      setState(() {
        _ready = true;
      });
    }
  }

  /// en sonda tüm toplulukların ve onların meetinglerinin bir mape atılması
  _actionInforms(value, clubID) async {
    // club finalsda her bir elementte club id karşısına ana -> topluluk bilgisi , actions-> ne kadar toplantı varsa onların bilgi listi
    Map<String, dynamic> _clubParts = {};
    List _actionsInfos = [];

    _clubParts["main"] = value;

    await Future.forEach(value["actions"], (meetingId) async {
      await _meetingRef.doc("$meetingId").get().then((value) {
        if (value.exists) {
          if (value.data()["date"].toDate().isAfter(today)) {
            _actionsInfos.add(value.data());
          } else {
            _userRef.update({
              "meeting_favs": FieldValue.arrayRemove([meetingId])
            });
          }
        } else {
          _clubRef.doc("$clubID").update({
            "actions": FieldValue.arrayRemove([meetingId])
          });
        }
      });
    });
    _clubParts["actions"] = _actionsInfos;
    _finalClubs.add(_clubParts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (!_ready)
          ? Center(child: CircularProgressIndicator())
          : ((_clubs.isEmpty)
              ? buildNoFavPage(context)
              : buildFavListPage(context)),
    );
  }

  Column buildFavListPage(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemCount: _finalClubs.length,
              itemBuilder: (context, index) {
                _finalClubs.sort(
                    (a, b) => (a["main"]["name"]).compareTo(b["main"]["name"]));
                return _buildClubList(context, _finalClubs[index]);
              }),
        ),
        TextButton(
            child: Text("more_fav".tr(),
                style: TextStyle(
                    fontFamily: "NexaBold",
                    color: Theme.of(context).accentColor)),
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Community()))
                  .then((value) {
                _getUserFavs();
              });
            }),
      ],
    );
  }

  Container buildNoFavPage(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        heightFactor: .52,
        widthFactor: 1,
        alignment: Alignment.topCenter,
        child: (Column(
          children: <Widget>[
            Image.asset("assets/heart.png", scale: 2.2),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "no_fav".tr(),
                style: TextStyle(fontSize: 15),
              ),
            ),
            TextButton(
              child: Text(
                "add_soc".tr(),
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Community(),
                  )).then((value) => _getUserFavs()),
            )
          ],
        )),
      ),
    );
  }

  _buildClubList(context, clubElement) {
    var main = clubElement["main"];
    final theme = Theme.of(context).copyWith(
      dividerColor: Colors.transparent,
      unselectedWidgetColor: Colors.red[400],
    );
    return clubElement["actions"].length > 0
        ? Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Theme(
              data: theme,
              child: ExpansionTile(
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsPage(
                                      clubId: main["id"],
                                    ),
                                  )).then((value) {
                                _getUserFavs();
                              }),
                          child: Text(main["name"])),
                    ],
                  ),
                ),
                leading: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(
                          clubId: main["id"],
                        ),
                      )).then((value) {
                    _getUserFavs();
                  }),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: main["pic"] == "assets/odtu.png"
                        ? AssetImage(main["pic"])
                        : CachedNetworkImageProvider(main["pic"]),
                  ),
                ),
                children: <Widget>[
                  Column(
                    children: [
                      Container(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: clubElement["actions"].length,
                            itemBuilder: (context, index) {
                              clubElement["actions"].sort((a, b) {
                                DateTime date1 = (a["date"].toDate());
                                DateTime date2 = (b["date"].toDate());
                                return date1.compareTo(date2);
                              });

                              return _buildActionList(
                                  context, clubElement["actions"][index]);
                            }),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                    clubId: main["id"],
                                  ),
                                )).then((value) {
                              _getUserFavs();
                            }),
                        child: Text(main["name"])),
                  ],
                ),
              ),
              leading: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsPage(
                        clubId: main["id"],
                      ),
                    )).then((value) {
                  _getUserFavs();
                }),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: main["pic"] == "assets/odtu.png"
                      ? AssetImage(main["pic"])
                      : CachedNetworkImageProvider(main["pic"]),
                ),
              ),
            ),
          );
  }

  _buildActionList(context, actionElement) {
    final _isFav = _likedMeetings.contains(actionElement["id"]);
    String _date =
        DateFormat("dd.MM.yyyy  HH:mm").format(actionElement["date"].toDate());

    _changed() {
      setState(() {
        if (_isFav) {
          userLikes.unLike(actionElement["id"], "meeting");
          _likedMeetings.remove(actionElement["id"]);
        } else {
          userLikes.addLike(actionElement["id"], "meeting");
          _likedMeetings.add(actionElement["id"]);
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 4, top: 4),
      child: ListTile(
        title: Text(actionElement["name"]),
        subtitle: Text(_date),
        leading: actionElement["img"] == "assets/odtu.png"
            ? Image.asset(actionElement["img"])
            : CachedNetworkImage(imageUrl: actionElement["img"]),
        trailing: IconButton(
          icon: (_isFav) ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
          onPressed: () => _changed(),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeetingDetails(
                  meetingId: actionElement["id"],
                ),
              )).then((value) => _getUserFavs());
        },
      ),
    );
  }
}
