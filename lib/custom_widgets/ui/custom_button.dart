import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../custom.dart';

class CustomButton extends StatelessWidget {
  final String icon, label;
  final Color buttonColor;
  final bool? iconColor;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.icon,
    required this.label,
    required this.buttonColor,
    this.iconColor = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.09;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 5),
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      onPressed: onPressed,
      icon: iconColor! ? SvgPicture.asset(
        icon,
        colorFilter: ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        width: iconSize,
        height: iconSize,
      ) : SvgPicture.asset(
        icon,
        width: iconSize,
        height: iconSize,
      ),
      label: CustomText(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
