import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_config/flutter_config.dart';

class SendMail {
  requestMail(club) async {
    String username = FlutterConfig.get("GMAIL");
    String password = FlutterConfig.get("GMAIL_PASSWORD");

    // ignore: deprecated_member_use
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, "Topluluk mesajları")
      ..recipients.add("neoplis@outlook.com")
      ..subject = "Yeni topluluk talebi :: ${DateTime.now()}"
      ..text = "Topluluk Adı: ${club["name"]} \n" +
          "Açıklama: ${club["tell"]} \n" +
          "Etkinlik açıklaması: ${club["events"]} \n" +
          "Üye sayısı: ${club["member"]} \n";

    try {
      final sendReport = await send(message, smtpServer);
      print("Message sent: " + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  feedbackMail(content) async {
    String username = FlutterConfig.get("GMAIL");
    String password = FlutterConfig.get("GMAIL_PASSWORD");

    // ignore: deprecated_member_use
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, "Feedback mesajları")
      ..recipients.add("neoplis@outlook.com")
      ..subject = "Feedback"
      ..text = "$content \n \n \n ${DateTime.now()}";

    try {
      final sendReport = await send(message, smtpServer);
      print("Message sent: " + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
