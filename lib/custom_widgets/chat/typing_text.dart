import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class TypingText extends StatefulWidget {
  final String text;
  final Duration duration;
  final VoidCallback onComplete;
  @override
  final GlobalKey<TypingTextState> key;

  const TypingText({
    required this.text,
    required this.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 5),
  }) : super(key: key);

  @override
  State<TypingText> createState() => TypingTextState();
}

class TypingTextState extends State<TypingText> {
  late Timer _timer;
  String _displayedText = '';
  int _currentIndex = 0;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    if (_isTyping) return;
    _isTyping = true;
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText = widget.text.substring(0, ++_currentIndex);
        });
      } else {
        _timer.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isTyping ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: MarkdownBody(
        data: _displayedText,
        styleSheet: MarkdownStyleSheet(
          p: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          textAlign: WrapAlignment.start,
        ),
      ),
    );
  }
}
