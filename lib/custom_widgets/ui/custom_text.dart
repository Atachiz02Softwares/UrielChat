import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? align;
  final TextOverflow? overflow;
  final int? maxLines;

  const CustomText({
    super.key,
    required this.text,
    this.style,
    this.align,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins().merge(style),
      textAlign: align,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
