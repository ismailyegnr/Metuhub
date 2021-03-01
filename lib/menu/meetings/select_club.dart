import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:metuhub/menu/meetings/add_meetings.dart';

class SelectionPage extends StatefulWidget {
  final String current;
  final String clubId;

  const SelectionPage({Key key, this.current, this.clubId}) : super(key: key);

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  String _selected;
  String _clubId;

  @override
  void initState() {
    if (widget.current != null) {
      _selected = widget.current;
      _clubId = widget.clubId;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("topluluklar")
            .where("status", isEqualTo: "public")
            .orderBy("name")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return Scaffold(
            appBar: AppBar(
                elevation: 0.6,
                backgroundColor: Colors.grey[300],
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    "sel_club".tr(),
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                )),
            bottomNavigationBar: BottomAppBar(
              color: Colors.grey[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    height: 58,
                    width: MediaQuery.of(context).size.width / 2,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "cancel".tr(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 58,
                    width: MediaQuery.of(context).size.width / 2,
                    child: TextButton(
                      onPressed: _selected != null
                          ? () {
                              currentClubId = _clubId;
                              currentClub = _selected;
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text(
                        "ok".tr(),
                        style: TextStyle(
                            color:
                                _selected != null ? Colors.black : Colors.grey),
                      ),
                    ),
                  )
                ],
              ),
            ),
            body: ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) =>
                    _listViewBuilder(context, snapshot.data.documents[index])),
          );
        });
  }

  Widget _listViewBuilder(BuildContext context, DocumentSnapshot snap) {
    var snapshot = snap.data();
    return Column(
      children: <Widget>[
        Ink(
          height: 66,
          decoration: BoxDecoration(
            color: _selected == snapshot["name"] ? Colors.grey[300] : null,
            border: Border(bottom: BorderSide(width: 0.1)),
          ),
          child: ListTileTheme(
            selectedColor: Colors.black,
            child: ListTile(
              selected: _selected == snapshot["name"] ? true : false,
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  snapshot["name"],
                ),
              ),
              onTap: () {
                setState(() {
                  _selected = snapshot["name"];
                  _clubId = snapshot["id"];
                });
              },
            ),
          ),
        )
      ],
    );
  }
}
