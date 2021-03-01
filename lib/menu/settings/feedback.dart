import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:metuhub/services/net_connection.dart';
import 'package:metuhub/services/send_mail.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.6,
        title: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "Feedback",
            style: TextStyle(fontFamily: "NexaBold"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: HelpPageForm(),
      ),
    );
  }
}

class HelpPageForm extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPageForm> {
  ConnectionStatus _connectionStatus = ConnectionStatus();
  SendMail _sendMail = SendMail();
  final _textController = TextEditingController();
  final _feedbackKey = GlobalKey<FormState>();

  bool sending = false;
  String content;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
            child: Text(
              "fb_exp".tr(),
            ),
          ),
          Form(
            key: _feedbackKey,
            child: Column(
              children: <Widget>[buildFBInput(), buildSendButton()],
            ),
          )
        ],
      ),
    );
  }

  Padding buildFBInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6),
      child: Center(
        child: TextFormField(
          onSaved: (newValue) {
            content = newValue;
          },
          controller: _textController,
          maxLines: 5,
          decoration: InputDecoration(
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red[800], width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red[800], width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.indigo[900], width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue[800], width: 1.5),
              )),
          validator: (value) {
            if (value.isEmpty) {
              return "fb_emp".tr();
            }
            return null;
          },
        ),
      ),
    );
  }

  Padding buildSendButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: sending == true
          ? CircularProgressIndicator()
          : SizedBox(
              height: 36,
              width: 88,
              child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      backgroundColor: Colors.grey[200]),
                  onPressed: () => _sendFeedback(),
                  child: Text(
                    "send".tr(),
                    style: TextStyle(color: Colors.black87),
                  )),
            ),
    );
  }

  _sendFeedback() async {
    if (_feedbackKey.currentState.validate()) {
      bool connection = await _connectionStatus.checkConnection();

      // there is no connection
      if (connection == false) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("no_connect".tr()),
          duration: const Duration(milliseconds: 1000),
        ));
      } // there is connection
      else {
        _feedbackKey.currentState.save();

        setState(() {
          sending = true;
        });
        await _sendMail.feedbackMail(content);
        setState(() {
          sending = false;
        });

        var snackBar = Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("suc_fb".tr()),
          duration: Duration(milliseconds: 1000),
        ));

        FocusScope.of(context).unfocus();

        snackBar.closed.then((value) {
          _handleSubmitted(_textController.text);
        });
      }
    }
  }

  void _handleSubmitted(String text) {
    _textController.clear();
  }
}
