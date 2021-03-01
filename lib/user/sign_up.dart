import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metuhub/database/crud.dart';
import 'package:metuhub/database/deps.dart';

class SignUp extends StatefulWidget {
  final bool fromSettings;

  const SignUp({Key key, this.fromSettings}) : super(key: key);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _nameCont = TextEditingController();
  final _surnameCont = TextEditingController();
  final _mailCont = TextEditingController();
  final _textController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  crudMethods crudObj = new crudMethods();

  bool _isLoading = false;
  String _error;
  String _email, _password, _name, _surName;

  // ignore: non_constant_identifier_names
  final String url_tr = "deps/deps_tr.json";
  // ignore: non_constant_identifier_names
  final String url_en = "deps/deps_en.json";
  List depsEn = [];
  List depsTr = [];

  bool emailValid(email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

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

  showAlert() {
    if (_error != null) {
      return Container(
        padding: EdgeInsets.all(8),
        color: _error == "suc_sign".tr() ? Colors.green : Colors.amber,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _error == "suc_sign".tr()
                  ? Icon(
                      Icons.check,
                      color: Colors.black87,
                    )
                  : Icon(
                      Icons.error,
                      color: Colors.black87,
                    ),
            ),
            Expanded(
              child: Text(
                _error,
                maxLines: 3,
                style: TextStyle(color: Colors.black87),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  _error = null;
                });
              },
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }

  @override
  void initState() {
    currentDept = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                widget.fromSettings == true ? showAlert() : SizedBox(),
                SizedBox(
                  height: 6,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _nameCont,
                    decoration: InputDecoration(labelText: "name".tr()),
                    onSaved: (value) {
                      _name = value;
                    },
                    validator: (input) {
                      if (input.isEmpty) {
                        return "val_name".tr();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _surnameCont,
                    decoration: InputDecoration(labelText: "s_name".tr()),
                    onSaved: (value) {
                      _surName = value;
                    },
                    validator: (input) {
                      if (input.isEmpty) {
                        return "val_sname".tr();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _textController,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.chevron_right),
                      hintText: "dep".tr(),
                    ),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Departments(current: currentDept),
                        )).whenComplete(() => setState(() {
                          _textController.text = currentDept;
                        })),
                    validator: (input) {
                      if (input.isEmpty) {
                        return "val_dep".tr();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _mailCont,
                    decoration: InputDecoration(labelText: "Email"),
                    onSaved: (value) {
                      _email = value;
                    },
                    validator: (value) {
                      if (emailValid(value) == false) {
                        return "inv_mail".tr();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "pw".tr(),
                    ),
                    onSaved: (input) {
                      _password = input;
                    },
                    validator: (input) {
                      if (input.length < 6) {
                        return "un_pw".tr();
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                widget.fromSettings == false ? showAlert() : SizedBox(),
                _isLoading
                    ? CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: SizedBox(
                          height: 38,
                          width: 90,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  primary: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  backgroundColor: Colors.grey[200]),
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await _signUp();
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              child: Text(
                                "sign".tr(),
                                style: TextStyle(color: Colors.black87),
                              )),
                        )),
                SizedBox(
                  height: 126,
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      await getJsonData();

      try {
        UserCredential result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _email.trim(), password: _password);

        User user = result.user;
        List<String> meeting = [];
        List<String> event = [];
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

        Map<String, dynamic> newUser = {
          "uid": user.uid,
          "username": _name,
          "surname": _surName,
          "depTR": deptTr,
          "depEN": deptEn,
          "isAdmin": false,
          "meeting_favs": meeting,
          "event_favs": event,
          "club_favs": [],
        };

        await crudObj.addUser(newUser, user.uid);
        setState(() {
          _error = "suc_sign".tr();
        });
        await FirebaseAuth.instance.signOut();

        await Future.delayed(Duration(seconds: 1), () {});

        _formKey.currentState.reset();
        _textController.clear();
        _nameCont.clear();
        _surnameCont.clear();
        _mailCont.clear();

        FocusScope.of(context).unfocus();
      } on FirebaseAuthException catch (e) {
        print(e);

        switch (e.code) {
          case "invalid-email":
            {
              setState(() {
                _error = "inv_mail".tr();
              });
            }
            break;
          case "email-already-in-use":
            {
              setState(() {
                _error = "al_mail".tr();
              });
            }
            break;

          case "network-request-failed":
            {
              setState(() {
                _error = "no_con".tr();
              });
            }
            break;
        }
      }
    }
  }
}
