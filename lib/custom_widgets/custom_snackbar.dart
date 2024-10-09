import 'package:flutter/material.dart';

import 'custom_text.dart';

class CustomSnackBar {
  static void showSnackBar(BuildContext context, String text,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? Colors.red
            : Theme.of(context).brightness == Brightness.dark
                ? Colors.blueGrey.shade900
                : Colors.white,
        content: CustomText(
          text: text,
          style: TextStyle(
            color: isError
                ? Colors.white
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.blueGrey.shade900,
          ),
        ),
      ),
    );
  }
}
