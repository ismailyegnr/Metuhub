import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:metuhub/actions/user_favs.dart';
import 'package:metuhub/menu/clubs/add_club.dart';
import 'package:metuhub/menu/home.dart';
import 'package:metuhub/services/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {
  final String clubId;

  const DetailsPage({Key key, this.clubId}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  DocumentReference _ref;
  bool _fav;
  UserFavs userLikes = UserFavs();
  DocumentReference _userRef;

  @override
  void initState() {
    _ref = FirebaseFirestore.instance
        .collection("topluluklar")
        .doc("${widget.clubId}");

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (authStatus == AuthStatus.signedIn) {
        _userRef = FirebaseFirestore.instance.collection("users").doc(userId);

        _userRef.get().then((doc) {
          doc.data()["club_favs"].forEach((item) {
            if (item == widget.clubId) {
              setState(() {
                _fav = true;
              });
            }
          });
        });
      }
    });

    super.initState();
  }

  _editIcon(document) {
    if (authStatus == AuthStatus.signedIn) {
      if (isAdmin == true || document["editor"] == userId) {
        return IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddNew(
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
      userLikes.unLike(document["id"], "club");
      setState(() {
        _fav = false;
      });

      final snackBar = SnackBar(
        content: Text("${document['name']}" + "fav_off_soc".tr()),
        duration: Duration(milliseconds: 1200),
        action: SnackBarAction(
          label: "fav_back".tr(),
          onPressed: () {
            userLikes.addLike(document["id"], "club");
            setState(() {
              _fav = true;
            });
          },
        ),
      );
      return snackBar;
    } else {
      userLikes.addLike(document["id"], "club");
      setState(() {
        _fav = true;
      });

      final snackBar = SnackBar(
        content: Text("${document['name']}" + "fav_on_soc".tr()),
        duration: Duration(milliseconds: 1200),
        action: SnackBarAction(
          label: "fav_back".tr(),
          onPressed: () {
            userLikes.unLike(document["id"], "club");
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
    return StreamBuilder(
      stream: _ref.snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        var document = snapshot.data.data();

        return Scaffold(
            appBar: AppBar(
              elevation: 0.4,
              title: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(document["name"],
                    style: TextStyle(fontFamily: "NexaBold")),
              ),
              actions: <Widget>[
                authStatus == AuthStatus.signedIn
                    ? StreamBuilder<Object>(
                        stream: null,
                        builder: (context, snapshot) {
                          return IconButton(
                              icon: Icon(
                                _fav == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              onPressed: () {
                                var snack = _isFavorited(document);
                                Scaffold.of(context).showSnackBar(snack);
                              });
                        })
                    : Container(),
                _editIcon(document),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildClubImage(document),
                    buildClubName(document),
                    buildClubMembers(document),
                    SizedBox(
                      height: 24,
                    ),
                    buildClubAbout(context, document),
                    SizedBox(
                      height: 44,
                    ),
                    Divider(
                      thickness: 0.8,
                    ),
                    buildClubEvents(context, document),
                    SizedBox(
                      height: 44,
                    ),
                    Divider(
                      thickness: 0.8,
                    ),
                    buildClubSocials(context, document),
                    SizedBox(
                      height: 40,
                    ),
                    buildAdminPanel(document)
                  ],
                ),
              ),
            ));
      },
    );
  }

  Widget buildAdminPanel(document) {
    return (authStatus == AuthStatus.signedIn &&
            isAdmin == true &&
            document["status"] == "waiting")
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black)),
                onPressed: () {
                  _updateStatus();
                },
                child: Text(
                  "Yayınla",
                ),
              ),
            ),
          )
        : Container();
  }

  Column buildClubSocials(BuildContext context, document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "soc_media".tr(),
            style: TextStyle(fontSize: 18, color: textColor(context)),
          ),
        ),
        Container(
          height: 50.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: document["socialMedia"].length ~/ 2,
            itemBuilder: (context, index) {
              return Row(children: <Widget>[
                _socials(document["socialMedia"]["site$index"],
                    document["socialMedia"]["text$index"]),
                SizedBox(
                  width: 12,
                )
              ]);
            },
          ),
        ),
      ],
    );
  }

  Column buildClubEvents(BuildContext context, document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "soc_etk".tr(),
            style: TextStyle(fontSize: 18, color: textColor(context)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 14),
          child: Text(
            document["events"],
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Column buildClubAbout(BuildContext context, document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "soc_about".tr(),
            style: TextStyle(fontSize: 18, color: textColor(context)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 14),
          child: Text(
            document["tell"],
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Align buildClubMembers(document) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        document["member"].trim() + "soc_member".tr(),
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Padding buildClubName(document) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          document["name"],
          style: TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  Padding buildClubImage(document) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 86,
            backgroundImage: document["pic"] == "assets/odtu.png"
                ? AssetImage(
                    document["pic"],
                  )
                : CachedNetworkImageProvider(
                    document["pic"],
                  ),
          ),
        ],
      ),
    );
  }

  _updateStatus() {
    _ref.update({"status": "public"});
  }

  _socials(dynamic input, dynamic navigator) {
    if (input == "Facebook") {
      return Ink(
        width: 50,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage("assets/facebook.png"))),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
            onTap: () {
              launch("https:" + navigator);
            },
          ),
        ),
      );
    } else if (input == "Instagram") {
      return Ink(
        width: 52,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage("assets/insta.png"))),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () {
              launch("https:" + navigator);
            },
          ),
        ),
      );
    } else if (input == "Youtube") {
      return Ink(
        width: 50,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage("assets/youtube.png"))),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            onTap: () {
              launch("https:" + navigator);
            },
          ),
        ),
      );
    } else {
      return Ink(
        width: 50,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage("assets/twitter.png"))),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
            onTap: () {
              launch("https:" + navigator);
            },
          ),
        ),
      );
    }
  }
}
