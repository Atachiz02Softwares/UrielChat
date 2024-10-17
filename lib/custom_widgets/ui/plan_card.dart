import 'package:flutter/material.dart';

import '../../utils/strings.dart';
import '../custom.dart';

class PlanCard extends StatelessWidget {
  final String title, buttonText;
  final double price;
  final Color buttonColor;
  final VoidCallback onPressed;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: 30,
      color: Colors.blueGrey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomText(
              text: title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CustomText(
              text: 'NGN $price',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              icon: Strings.dollar,
              label: buttonText,
              buttonColor: buttonColor,
              onPressed: onPressed,
              iconColor: false,
            ),
          ],
        ),
      ),
    );
  }
}
