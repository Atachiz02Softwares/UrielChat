import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/utils.dart';
import '../custom.dart';

class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSendMessage;

  const InputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.07;
    return GlassContainer(
      borderRadius: iconSize,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: SvgPicture.asset(
                Strings.mic,
                colorFilter: const ColorFilter.mode(
                  Colors.blueGrey,
                  BlendMode.srcIn,
                ),
                width: iconSize,
                height: iconSize,
              ),
              onPressed: () {
                CustomSnackBar.showSnackBar(context, Strings.chill);
              },
            ),
            IconButton(
              icon: SvgPicture.asset(
                Strings.camera,
                colorFilter: const ColorFilter.mode(
                  Colors.blueGrey,
                  BlendMode.srcIn,
                ),
                width: iconSize,
                height: iconSize,
              ),
              onPressed: () {
                CustomSnackBar.showSnackBar(context, Strings.chill);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
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
            isLoading
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
                      onSendMessage();
                      controller.clear();
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
