import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget? child;

  const BackgroundContainer({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.blueGrey.shade900,
          ],
        ),
      ),
      child: child,
    );
  }
}
