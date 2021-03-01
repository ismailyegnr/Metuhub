import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:metuhub/actions/get_image.dart';
import 'package:metuhub/services/net_connection.dart';
import 'package:metuhub/services/send_mail.dart';
import 'package:metuhub/database/crud.dart';
import 'package:metuhub/user/sign_in.dart';
import 'package:metuhub/menu/home.dart';

class AddNew extends StatefulWidget {
  final dynamic snap;
  const AddNew({Key key, this.snap}) : super(key: key);

  @override
  _AddNewState createState() => _AddNewState();
}

Map<String, dynamic> _formdata = {};
int _index;

class _AddNewState extends State<AddNew> {
  ConnectionStatus _connectionStatus = ConnectionStatus();
  SendMail launchMail = SendMail();
  ImageActions imageAction = ImageActions();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  crudMethods crudObj = new crudMethods();

  bool _isLoading = false;
  String _uploadedImage;
  File _image;

  @override
  void initState() {
    if (widget.snap != null) {
      int times = (widget.snap["socialMedia"].length) ~/ 2;
      _index = times != 0 ? times : 1;
    } else {
      _formdata = {};
      _index = 1;
    }

    super.initState();
  }

  void _add() {
    print(_formdata);
    setState(() {
      ++_index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _socialMedia = new List.generate(
      _index,
      (int i) => CreateSocial(
        doc: widget.snap != null ? widget.snap["socialMedia"] : null,
        index: i,
      ),
    );

    String name1;
    String member;
    Map<String, dynamic> socialMedia = {};
    String events;
    String tell;

    if (widget.snap != null) {
      _uploadedImage = widget.snap["pic"];
    }

    if (widget.snap != null && widget.snap["socialMedia"] != null) {
      _formdata = widget.snap["socialMedia"];
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0.4,
          title: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              widget.snap == null ? "add_soc".tr() : "edit_soc".tr(),
              style: TextStyle(fontFamily: "NexaBold"),
            ),
          ),
        ),
        body: authStatus == AuthStatus.notSignedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("soc_off".tr()),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  OutlineButton(
                    child: new Text(
                      "log_in".tr(),
                      style: TextStyle(fontFamily: "Mulish"),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SignIn();
                          }).then((value) {
                        setState(() {});
                      });
                    },
                    highlightedBorderColor: Colors.red,
                    textColor: Colors.red[600],
                    borderSide: BorderSide(color: Colors.red[600]),
                    shape: StadiumBorder(),
                  ),
                ],
              )
            : Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          widget.snap == null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 14),
                                  child: Text(
                                    "add_soc_exp".tr(),
                                  ),
                                )
                              : SizedBox(height: 20),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 14),
                              child: Ink(
                                  height: 240,
                                  width: 192,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6)),
                                      border: Border.all(
                                          color: Colors.black54, width: 0.8),
                                      image: DecorationImage(
                                          fit: (widget.snap != null &&
                                                  widget.snap["img"] !=
                                                      "assets/odtu.png")
                                              ? (BoxFit.cover)
                                              : (_image == null
                                                  ? BoxFit.contain
                                                  : BoxFit.cover),
                                          image: (widget.snap != null &&
                                                  widget.snap["pic"] !=
                                                      "assets/odtu.png" &&
                                                  _image == null)
                                              ? (CachedNetworkImageProvider(
                                                  widget.snap["pic"]))
                                              : (_image == null
                                                  ? AssetImage(
                                                      "assets/load.png")
                                                  : FileImage(_image)))),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        var newd;
                                        newd = await imageAction.getImage();
                                        setState(() {
                                          _image = newd;
                                        });
                                      },
                                    ),
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12),
                            child: TextFormField(
                              initialValue: widget.snap == null
                                  ? null
                                  : widget.snap["name"],
                              maxLines: 1,
                              onSaved: (value) {
                                name1 = value;
                              },
                              decoration: InputDecoration(
                                labelText: "hint_soc_name".tr(),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "val_soc_name".tr();
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              maxLines: 1,
                              initialValue: widget.snap != null
                                  ? widget.snap["member"]
                                  : null,
                              onSaved: (newValue) {
                                member = newValue;
                              },
                              decoration: InputDecoration(
                                labelText: "hint_soc_member".tr(),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "val_soc_member".tr();
                                }

                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: TextFormField(
                              maxLines: 3,
                              initialValue: widget.snap != null
                                  ? widget.snap["tell"]
                                  : null,
                              onSaved: (newValue) {
                                tell = newValue;
                              },
                              decoration: InputDecoration(
                                labelText: "hint_soc_tell".tr(),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "val_soc_tell_non".tr();
                                }
                                if (value.length <= 3) {
                                  return "val_soc_tell_ins".tr();
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: TextFormField(
                              maxLines: 3,
                              initialValue: widget.snap != null
                                  ? widget.snap["events"]
                                  : null,
                              onSaved: (newValue) {
                                events = newValue;
                              },
                              decoration: InputDecoration(
                                labelText: "hint_soc_etk".tr(),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "val_soc_etk_non".tr();
                                }
                                if (value.length < 3) {
                                  return "val_soc_etk_ins".tr();
                                }
                                return null;
                              },
                            ),
                          ),
                          buildSocialMedia(_socialMedia),
                          if (_isLoading)
                            Center(child: CircularProgressIndicator())
                          else
                            buildAddButton(socialMedia, member, name1, events,
                                tell, context),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  Column buildSocialMedia(List<Widget> _socialMedia) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(children: _socialMedia),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                iconSize: 28,
                icon: Icon(Ionicons.add_circle_outline),
                onPressed: _add),
          ),
        ),
      ],
    );
  }

  Center buildAddButton(Map<String, dynamic> socialMedia, String member,
      String name1, String events, String tell, BuildContext context) {
    return Center(
      child: OutlineButton(
          highlightedBorderColor: Colors.red,
          borderSide: BorderSide(color: Colors.red[600]),
          shape: StadiumBorder(),
          child: Text(
            widget.snap == null ? "submit_add".tr() : "submit_edit".tr(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () =>
              createClub(socialMedia, member, name1, events, tell, context)),
    );
  }

  Future createClub(Map<String, dynamic> socialMedia, String member,
      String name1, String events, String tell, BuildContext context) async {
    if (_formKey.currentState.validate()) {
      bool connection = await _connectionStatus.checkConnection();
      setState(() {
        _isLoading = true;
      });

      if (connection == false) {
        setState(() {
          _isLoading = false;
        });
        _connectionStatus.noConSnackBar(_scaffoldKey);
      } else {
        _formKey.currentState.save();

        int i;
        int a = 0;
        int cont = _index;
        String last;

        if (_image != null) {
          _uploadedImage = await imageAction.uploadImage(_image, "topluluklar");
        }

        for (i = 0; i < cont; i++) {
          if ((_formdata["text$i"] != null) &&
              (_formdata["site$i"] != null) &&
              (_formdata["text$i"] != "")) {
            socialMedia["text$a"] = _formdata["text$i"];
            socialMedia["site$a"] = _formdata["site$i"];

            a++;
          }
        }

        last = member.replaceAll(" ", "");

        Map<String, dynamic> newClub = {
          "name": name1,
          "socialMedia": socialMedia,
          "member": last,
          "pic": _image == null
              ? (widget.snap == null ? "assets/odtu.png" : widget.snap["pic"])
              : _uploadedImage,
          "events": events,
          "tell": tell,
          "editor": userId,
        };
        if (widget.snap == null) {
          await crudObj.addData(newClub);

          launchMail.requestMail(newClub);
        } else {
          await crudObj.updateData(newClub, widget.snap["id"]);
        }
        setState(() {
          _isLoading = false;
        });
        if (widget.snap == null) {
          var snackBar = Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("ok_add_soc".tr()),
            duration: Duration(milliseconds: 1000),
          ));

          snackBar.closed.then((value) {
            Navigator.pop(context);
          });
        } else {
          Navigator.pop(context);
        }
      }
    }
  }
}

class CreateSocial extends StatefulWidget {
  final int index;
  final dynamic doc;

  const CreateSocial({Key key, this.doc, this.index}) : super(key: key);

  @override
  _CreateSocialState createState() => _CreateSocialState();
}

class _CreateSocialState extends State<CreateSocial> {
  int keyValue = _index;

  @override
  Widget build(BuildContext context) {
    if (widget.doc != null) {
      keyValue = widget.index + 1;
    }

    return Row(
      key: Key("$keyValue"),
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 22.0, right: 10, top: 32),
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: Icon(
                Icons.arrow_downward,
                size: 20,
              ),
              items: _dropDownMenuItems,
              onChanged: changedDropDownItem,
              value: _currentItemSelected,
              hint: Text("hint_media_soc".tr()),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 22.0, left: 16, top: 20),
            child: TextFormField(
              initialValue:
                  widget.doc != null ? widget.doc["text${keyValue - 1}"] : null,
              onChanged: (val) {
                _formdata["text${keyValue - 1}"] = val;
              },
              decoration: InputDecoration(
                labelText: "hint_link_soc".tr(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List _social = ["Twitter", "Instagram", "Facebook", "Youtube"];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentItemSelected;

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    if (widget.doc != null && widget.doc["site${widget.index}"] != null) {
      _currentItemSelected = widget.doc["site${widget.index}"];
    } else {
      _currentItemSelected = null;
    }

    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = [];

    for (String one in _social) {
      items.add(new DropdownMenuItem(
          value: one,
          child: new Text(
            one,
            style: TextStyle(fontSize: 15),
          )));
    }
    return items;
  }

  void changedDropDownItem(String newValueSelected) {
    setState(() {
      _currentItemSelected = newValueSelected;
    });
    _formdata["site${keyValue - 1}"] = newValueSelected;
  }
}
