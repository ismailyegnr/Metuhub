import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:metuhub/database/crud.dart';
import 'package:metuhub/menu/home.dart';
import 'package:flutter/material.dart';
import 'package:metuhub/actions/get_image.dart';
import 'package:metuhub/actions/select_date.dart';
import 'package:intl/intl.dart';
import 'package:metuhub/services/net_connection.dart';

class AddEvent extends StatefulWidget {
  final dynamic snap;

  const AddEvent({Key key, this.snap}) : super(key: key);
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 12, minute: 0);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  ImageActions imageAction = ImageActions();
  ConnectionStatus _connectionStatus = ConnectionStatus();

  File _image;
  crudMethods crudObj = crudMethods();
  final _textController = TextEditingController();
  bool _isLoading = false;

  String name;
  String explain;
  DateTime date;

  String place;
  String _uploadedImage;

  @override
  void initState() {
    if (widget.snap != null) {
      _textController.text = widget.snap["club"];

      selectedDate = widget.snap["date"].toDate();
      selectedTime = TimeOfDay.fromDateTime(widget.snap["date"].toDate());
    }
    super.initState();
    {}
  }

  refresh() {
    setState(() {});
  }

  _deleteDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${widget.snap["name"]}"),
          content: Text(
            "del_etk".tr(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "cancel".tr(),
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                await Future.delayed(const Duration(milliseconds: 300), () {});
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 300), () {});
                await crudObj.deleteEventorMeet(widget.snap["id"], "events");
              },
              child: Text("ok".tr(), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.snap != null) {
      _uploadedImage = widget.snap["img"];
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.4,
        title: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            widget.snap == null ? "add_etk".tr() : "edit_etk".tr(),
            style: TextStyle(fontFamily: "NexaBold"),
          ),
        ),
        actions: <Widget>[
          widget.snap != null
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteDialog(),
                )
              : Container()
        ],
      ),
      body: _meetBody(),
    );
  }

  Widget _meetBody() {
    return authStatus == AuthStatus.notSignedIn
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("etk_off".tr()),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              OutlineButton(
                child: new Text(
                  "go_set".tr(),
                  style: TextStyle(fontFamily: "Mulish"),
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 4;
                    mainPageController.jumpToPage(4);
                  });
                  Navigator.pop(context);
                },
                highlightedBorderColor: Colors.red,
                textColor: Colors.red[600],
                borderSide: BorderSide(color: Colors.red[600]),
                shape: StadiumBorder(),
              ),
            ],
          )
        : StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 6,
                        ),
                        widget.snap == null
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 14),
                                child: Text("add_etk_exp".tr()),
                              )
                            : SizedBox(
                                height: 20,
                              ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 16),
                            child: Ink(
                                height: 300,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    border: Border.all(
                                        color: Colors.black54, width: 1),
                                    image: DecorationImage(
                                        fit: (widget.snap != null &&
                                                widget.snap["img"] !=
                                                    "assets/odtu.png")
                                            ? (BoxFit.cover)
                                            : (_image == null
                                                ? BoxFit.contain
                                                : BoxFit.cover),
                                        image: (widget.snap != null &&
                                                widget.snap["img"] !=
                                                    "assets/odtu.png" &&
                                                _image == null)
                                            ? (CachedNetworkImageProvider(
                                                widget.snap["img"]))
                                            : (_image == null
                                                ? AssetImage("assets/load.png")
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
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 14),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return "val_etk_name".tr();
                              }
                              return null;
                            },
                            initialValue: widget.snap == null
                                ? null
                                : widget.snap["name"],
                            onSaved: (newValue) {
                              name = newValue;
                            },
                            decoration: InputDecoration(
                              hintText: "hint_etk_name".tr(),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 14),
                          child: TextFormField(
                            onSaved: (newValue) {
                              explain = newValue;
                            },
                            initialValue: widget.snap == null
                                ? null
                                : widget.snap["explain"],
                            maxLines: 2,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "val_etk_exp".tr();
                              }
                              return null;
                            },
                            decoration:
                                InputDecoration(hintText: "hint_etk_exp".tr()),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //Etkinlik zaman baş
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 12),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 2),
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.calendar_today),
                                      onPressed: () async {
                                        var time;
                                        time = await selectDate(
                                            context, selectedDate);
                                        setState(() {
                                          selectedDate = time;
                                        });
                                      },
                                    ),
                                    Text(
                                      DateFormat("dd.MM.yyyy")
                                          .format(selectedDate),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 6),
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.schedule),
                                      onPressed: () async {
                                        var time;
                                        time = await selectTime(
                                            context, selectedTime);
                                        setState(() {
                                          selectedTime = time;
                                        });
                                      },
                                    ),
                                    Text(
                                      selectedTime.format(context),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ), //Etkinlik zaman bitiş
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 14),
                          child: TextFormField(
                            onSaved: (newValue) {
                              place = newValue;
                            },
                            initialValue: widget.snap == null
                                ? null
                                : widget.snap["place"],
                            validator: (value) {
                              if (value.isEmpty) {
                                return "val_etk_place".tr();
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: "hint_etk_place".tr()),
                          ),
                        ),
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 26.0),
                                  child: OutlineButton(
                                    highlightedBorderColor: Colors.red,
                                    borderSide:
                                        BorderSide(color: Colors.red[600]),
                                    shape: StadiumBorder(),
                                    child: Text(
                                      widget.snap == null
                                          ? "submit_add".tr()
                                          : "submit_edit".tr(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        bool connection =
                                            await _connectionStatus
                                                .checkConnection();
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        if (connection == false) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          _connectionStatus
                                              .noConSnackBar(_scaffoldKey);
                                        } else {
                                          String day;
                                          _formKey.currentState.save();

                                          if (_image != null) {
                                            _uploadedImage =
                                                await imageAction.uploadImage(
                                                    _image, "etkinlikler");
                                          }
                                          date = DateTime(
                                              selectedDate.year,
                                              selectedDate.month,
                                              selectedDate.day,
                                              selectedTime.hour,
                                              selectedTime.minute);
                                          day = weekdayTurkish(
                                              selectedDate.weekday);

                                          Map<String, dynamic> event = {
                                            "name": name,
                                            "explain": explain,
                                            "place": place,
                                            "date": date,
                                            "day": day,
                                            "img": _image == null
                                                ? (widget.snap == null
                                                    ? "assets/odtu.png"
                                                    : widget.snap["img"])
                                                : _uploadedImage,
                                            "editor": userId,
                                          };

                                          if (widget.snap == null) {
                                            await crudObj.addEventorMeet(
                                                event, "events");
                                          } else {
                                            await crudObj.updateEventorMeet(
                                                event,
                                                widget.snap["id"],
                                                "events");
                                          }

                                          setState(() {
                                            _isLoading = false;
                                          });

                                          if (widget.snap == null) {
                                            var snackBar = Scaffold.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text("suc_etk".tr()),
                                              duration:
                                                  Duration(milliseconds: 1000),
                                            ));

                                            snackBar.closed.then((value) {
                                              Navigator.pop(context);
                                            });
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
  }
}
