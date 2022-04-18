import 'package:flutter/material.dart';

class Util {
  static void makeDialog(BuildContext context, String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(content: Text(text),);
        }
    );
  }
}