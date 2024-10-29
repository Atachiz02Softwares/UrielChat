import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double? value;
  final double size;

  const CustomProgressBar({
    super.key,
    this.value,
    this.size = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: Colors.black87,
        backgroundColor: Colors.blueGrey,
        value: value,
        strokeWidth: 2.0,
      ),
    );
  }
}
