import 'package:flutter/cupertino.dart';

class CupertinoNavUtils {
  static void push(BuildContext context, Widget page) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => page));
  }

  static void replace(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => page),
    );
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
