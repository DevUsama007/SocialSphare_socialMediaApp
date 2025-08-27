import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';

class Message {
  infoMessage(BuildContext context, String title, String content) {
    showPlatformDialog(
      context: context,
      builder: (context) => BasicDialogAlert(
        title: Text(
          title,
          style: TextStyle(
            color: Color.fromARGB(255, 249, 98, 46),
            fontFamily: "inter",
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: Color.fromARGB(255, 121, 121, 121),
            fontFamily: "inter",
          ),
        ),
        actions: <Widget>[
          BasicDialogAction(
            title: Text(
              "OK",
              style: TextStyle(
                color: Color.fromARGB(255, 249, 98, 46),
                fontFamily: "inter",
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
