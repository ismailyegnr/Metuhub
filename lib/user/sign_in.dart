import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:metuhub/services/push_notification_service.dart';
import 'package:metuhub/user/save_user.dart';
import 'package:metuhub/user/sign_up.dart';

class SignIn extends StatefulWidget {
  final String from;
  final int initIndex;

  const SignIn({Key key, this.from, this.initIndex}) : super(key: key);

  @override
  _SignPageState createState() => _SignPageState();
}

class _SignPageState extends State<SignIn> with SingleTickerProviderStateMixin {
  PushNotificationService _notificationService = PushNotificationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  UserLogs _logs = UserLogs();
  bool _isLoading = false;
  String _email, _password;
  String _error;

  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(
        vsync: this,
        length: 2,
        initialIndex: widget.initIndex != null ? widget.initIndex : 0);
    super.initState();
  }

  showAlert() {
    if (_error != null) {
      return Container(
        padding: EdgeInsets.all(8),
        color: Colors.amber,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
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
              icon: Icon(Icons.close, color: Colors.black87),
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
  Widget build(BuildContext context) {
    return widget.from == "settings"
        ? Scaffold(
            appBar: AppBar(
              elevation: 0.4,
              title: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  "user".tr(),
                  style: TextStyle(
                    fontFamily: "NexaBold",
                  ),
                ),
              ),
              bottom: _bottomBar(),
            ),
            body: _signForms(),
          )
        : Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: _signForms());
  }

  _bottomBar() {
    return TabBar(
      labelStyle: TextStyle(fontFamily: "NexaBold"),
      controller: _tabController,
      labelColor: Theme.of(context).iconTheme.color,
      tabs: [
        Container(height: 46, child: Tab(text: "log".tr())),
        Container(height: 46, child: Tab(text: "sign".tr()))
      ],
    );
  }

  _signForms() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            widget.from != "settings" ? _bottomBar() : SizedBox(),
            Container(
                height: widget.from != "settings"
                    ? (MediaQuery.of(context).size.height) * 3 / 5
                    : ((MediaQuery.of(context).size.height) * 5 / 6),
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _signInPart(),
                    SignUp(
                      fromSettings: widget.from == "settings" ? true : false,
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  _signInPart() {
    return Form(
      key: _formKey,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height / 16),
        showAlert(),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email"),
            onSaved: (value) {
              _email = value;
            },
            validator: (input) {
              if (input.isEmpty) {
                return "val_mail".tr();
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
                return "val_pw".tr();
              }
              return null;
            },
            obscureText: true,
          ),
        ),
        SizedBox(
          height: 36,
        ),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : Builder(
                builder: (context) => SizedBox(
                  height: 38,
                  width: 90,
                  child: TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          backgroundColor: Colors.grey[200]),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await signIn();
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      child: Text(
                        "log_in".tr(),
                        style: TextStyle(color: Colors.black87),
                      )),
                ),
              )
      ]),
    );
  }

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();

      try {
        UserCredential userCredential = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _email.trim(), password: _password));

        User user = userCredential.user;
        print(user.email);
        print(user.uid);

        await _logs.login(user);

        _notificationService.userOnline();

        await Future.delayed(const Duration(milliseconds: 400), () {});
        Navigator.pop(context);
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
          case "user-not-found":
            {
              setState(() {
                _error = "no_user".tr();
              });
            }
            break;
          case "wrong-password":
            {
              setState(() {
                _error = "wrong_pw".tr();
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
