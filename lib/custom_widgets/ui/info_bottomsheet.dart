import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom.dart';

class InfoBottomSheet extends StatelessWidget {
  final String title;
  final String content;

  const InfoBottomSheet({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: MarkdownBody(
                  data: title,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.ubuntuMono(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    textAlign: WrapAlignment.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MarkdownBody(
                data: content,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.ubuntuMono(color: Colors.white, fontSize: 18),
                  textAlign: WrapAlignment.start,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
