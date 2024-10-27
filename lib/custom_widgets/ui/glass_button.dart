import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../custom.dart';

class GlassButton extends StatelessWidget {
  final String icon, label;
  final Color color;
  final VoidCallback onPressed;

  const GlassButton({
    super.key,
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.09;
    return GlassContainer(
      borderRadius: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        onPressed: onPressed,
        icon: SvgPicture.asset(
          icon,
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
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
      ),
    );
  }
}
