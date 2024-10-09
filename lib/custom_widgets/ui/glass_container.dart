import 'dart:ui';

import 'package:flutter/material.dart';

enum BorderType { user, ai, none }

class GlassContainer extends StatelessWidget {
  final double? width, height, borderRadius, opacity, blurX, blurY;
  final EdgeInsets? margin;
  final Widget child;
  final Color color;
  final BorderType borderType;

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
    this.borderType = BorderType.none,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: getBorderRadius(),
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
                borderRadius: getBorderRadius(),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  BorderRadiusGeometry getBorderRadius() {
    switch (borderType) {
      case BorderType.user:
        return BorderRadius.only(
          topLeft: Radius.circular(borderRadius!),
          topRight: Radius.circular(borderRadius!),
          bottomLeft: Radius.circular(borderRadius!),
          bottomRight: Radius.circular(0),
        );
      case BorderType.ai:
        return BorderRadius.only(
          topLeft: Radius.circular(borderRadius!),
          topRight: Radius.circular(borderRadius!),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(borderRadius!),
        );
      case BorderType.none:
      default:
        return BorderRadius.circular(borderRadius!);
    }
  }
}
