import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double? value;
  final double strokeWidth;

  const CustomProgressBar({super.key, this.value, this.strokeWidth = 4.0});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: Colors.black87,
      backgroundColor: Colors.blueGrey,
      value: value,
      strokeWidth: strokeWidth,
    );
  }
}
