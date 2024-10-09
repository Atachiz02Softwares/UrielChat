import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_widgets/custom.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundContainer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: CustomText(
                text: 'Bookmarks Screen',
                style: GoogleFonts.poppins(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                align: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
