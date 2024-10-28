import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/utils.dart';
import '../custom.dart';

class InputBar extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final bool waiting;
  final VoidCallback onSendMessage;

  const InputBar({
    super.key,
    required this.controller,
    required this.waiting,
    required this.onSendMessage,
  });

  @override
  ConsumerState<InputBar> createState() => _InputBarState();
}

class _InputBarState extends ConsumerState<InputBar> {
  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.07;
    return GlassContainer(
      borderRadius: iconSize,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            MicButton(widget.controller),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: TextField(
                  controller: widget.controller,
                  minLines: 1,
                  // maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ),
            widget.waiting
                ? const TypingIndicator()
                : IconButton(
                    icon: SvgPicture.asset(
                      Strings.send,
                      colorFilter: const ColorFilter.mode(
                        Colors.blueGrey,
                        BlendMode.srcIn,
                      ),
                      width: iconSize,
                      height: iconSize,
                    ),
                    onPressed: () {
                      widget.controller;
                      widget.onSendMessage();
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
