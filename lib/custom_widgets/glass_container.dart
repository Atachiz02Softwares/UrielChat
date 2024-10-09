import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final double? width, height, borderRadius, opacity, blurX, blurY;
  final EdgeInsets? margin;
  final Widget child;
  final Color color;

  const GlassContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 0.0,
    this.opacity,
    this.blurX,
    this.blurY,
    this.margin,
    required this.child,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurX ?? 15, sigmaY: blurY ?? 15),
            child: Container(
              width: width,
              height: height,
              margin: margin,
              decoration: BoxDecoration(
                color: color.withOpacity(opacity ?? 0.3),
                borderRadius: BorderRadius.circular(borderRadius!),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
