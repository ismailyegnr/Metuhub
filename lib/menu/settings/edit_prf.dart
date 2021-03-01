import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metuhub/database/deps.dart';
import 'package:metuhub/menu/home.dart';
import 'package:metuhub/services/net_connection.dart';

class EditProfile extends StatefulWidget {
  final String dept;

  const EditProfile({Key key, this.dept}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  ConnectionStatus _connectionStatus = ConnectionStatus();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  DocumentReference _userRef;
  String newName;
  String newSurname;
  String newDept;

  // ignore: non_constant_identifier_names
  final String url_tr = "deps/deps_tr.json";
  // ignore: non_constant_identifier_names
  final String url_en = "deps/deps_en.json";
  List depsEn = [];
  List depsTr = [];

  getJsonData() async {
    var responseTR = await rootBundle.loadString(url_tr);
    var responseEN = await rootBundle.loadString(url_en);

    setState(() {
      var convertedTR = jsonDecode(responseTR);
      var convertedEN = jsonDecode(responseEN);

      depsEn = convertedEN["departments"];
      depsTr = convertedTR["departments"];
    });
  }

  @override
  void initState() {
    _userRef = FirebaseFirestore.instance.collection("users").doc("$userId");
    _textController.text = widget.dept;
    currentDept = widget.dept;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.4,
        title: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "edit_prof".tr(),
            style: TextStyle(fontFamily: "NexaBold"),
          ),
        ),
      ),
      body: StreamBuilder(
          stream: _userRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            var document = snapshot.data.data();

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      buildProfile(),
                      SizedBox(
                        height: 12,
                      ),
                      buildName(document),
                      buildSurname(document),
                      buildDepartment(context),
                      buildMail(),
                      buildSaveButton()
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Column buildProfile() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Icon(
              Icons.person,
              size: 30,
              color: Colors.blueAccent,
            ),
          ),
        ),
        Center(
            child: Text(
          "prof".tr(),
          style: TextStyle(
            fontSize: 18,
          ),
        )),
      ],
    );
  }

  Padding buildName(document) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
      child: TextFormField(
        initialValue: document["username"],
        onSaved: (newValue) {
          newName = newValue;
        },
        decoration: InputDecoration(labelText: "name".tr()),
      ),
    );
  }

  Padding buildSurname(document) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
      child: TextFormField(
        initialValue: document["surname"],
        onSaved: (newValue) {
          newSurname = newValue;
        },
        decoration: InputDecoration(labelText: "s_name".tr()),
      ),
    );
  }

  Padding buildDepartment(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
      child: TextFormField(
        controller: _textController,
        readOnly: true,
        decoration: InputDecoration(
            suffixIcon: Icon(Icons.chevron_right), labelText: "dep".tr()),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Departments(current: currentDept),
            )).whenComplete(() => setState(() {
              _textController.text = currentDept;
            })),
      ),
    );
  }

  Padding buildMail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
      child: TextFormField(
        initialValue: userMail,
        enabled: false,
        decoration: InputDecoration(labelText: "Mail", enabled: false),
      ),
    );
  }

  Padding buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: TextButton(
        style: TextButton.styleFrom(
            primary: Colors.grey,
            shape: StadiumBorder(),
            backgroundColor: Colors.grey[300]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            "save".tr(),
            style: TextStyle(color: Colors.black87),
          ),
        ),
        onPressed: () => _save(),
      ),
    );
  }

  _save() async {
    bool connection = await _connectionStatus.checkConnection();
    if (connection == false) {
      _connectionStatus.noConSnackBar(_scaffoldKey);
    } else {
      _formKey.currentState.save();

      if (currentDept != null) {
        await getJsonData();

        var deptTr;
        var deptEn;

        if (context.locale == Locale("tr")) {
          var index = depsTr.indexOf(currentDept);
          deptTr = currentDept;
          deptEn = depsEn[index];
        } else {
          var index = depsEn.indexOf(currentDept);
          deptEn = currentDept;
          deptTr = depsTr[index];
        }

        await _userRef.update({
          "username": newName,
          "surname": newSurname,
          "depEN": deptEn,
          "depTR": deptTr
        });
      } else {
        await _userRef.update({
          "username": newName,
          "surname": newSurname,
        });
      }

      Navigator.pop(context);
    }
  }
}
