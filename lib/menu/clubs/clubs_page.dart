import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:metuhub/menu/clubs/club_detail.dart';
import 'package:metuhub/menu/clubs/add_club.dart';
import 'package:metuhub/menu/clubs/search_del.dart';
import 'package:metuhub/menu/home.dart';

List<Map> clubList = [];
List<String> clubNames = [];
List randomList = [];

class Community extends StatefulWidget {
  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  _stream() {
    if (authStatus == AuthStatus.signedIn && isAdmin == true) {
      return FirebaseFirestore.instance
          .collection("topluluklar")
          .orderBy("name")
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection("topluluklar")
          .where("status", isEqualTo: "public")
          .orderBy("name")
          .snapshots();
    }
  }

  _randomList() {
    var rng = new Random();
    int length = clubNames.length;

    if (length < 4) {
      randomList = clubNames;
    } else {
      while (randomList.length < 4) {
        var element = clubNames[rng.nextInt(length)];
        // ignore: unnecessary_statements
        randomList.contains(element) == false ? randomList.add(element) : null;
      }
      randomList.sort((a, b) => (a).compareTo(b));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.8,
        title: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "Metuhub",
            style: TextStyle(fontFamily: "NexaBold"),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _randomList();
              showSearch(context: context, delegate: DataSearch());
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (context) => AddNew()));
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _stream(),
          builder: (context, snapshot) {
            clubList = [];
            clubNames = [];
            randomList = [];
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          }),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot doc) {
    var document = doc.data();

    var clubMap = {"name": document["name"], "id": document["id"]};
    clubList.add(clubMap);
    clubNames.add(document["name"]);
    return Column(
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          title: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Ink(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(10), left: Radius.circular(8)),
                    color:
                        DynamicTheme.of(context).brightness == Brightness.light
                            ? Colors.grey[300].withOpacity(0.8)
                            : Colors.white24),
                child: Ink(
                  height: 176,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsPage(
                                      clubId: doc.id,
                                    )));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Ink(
                            width: 141,
                            height: 176,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: document["pic"] == "assets/odtu.png"
                                        ? AssetImage(document["pic"])
                                        : CachedNetworkImageProvider(
                                            document["pic"]))),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        AutoSizeText(document["name"],
                                            overflow: TextOverflow.clip,
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontSize: 17,
                                            )),
                                        (authStatus == AuthStatus.signedIn &&
                                                isAdmin == true &&
                                                document["status"] == "waiting")
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                child: Text(
                                                  "B",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.red,
                                                      fontSize: 18),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    AutoSizeText(
                                      document["tell"],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                      minFontSize: 13,
                                      style: TextStyle(
                                        color: DynamicTheme.of(context)
                                                    .brightness ==
                                                Brightness.light
                                            ? Colors.black54
                                            : Colors.grey[200],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0, bottom: 2),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            document["member"],
                                            style: TextStyle(fontSize: 13),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: Icon(
                                              Icons.people,
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ),
        ),
        SizedBox(
          height: 6,
        )
      ],
    );
  }
}
