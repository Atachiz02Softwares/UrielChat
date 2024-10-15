import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uriel_chat/utils/utils.dart';

import '../../custom_widgets/custom.dart';

class RootedDeviceScreen extends StatelessWidget {
  const RootedDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.5;

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            const BackgroundContainer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      SvgPicture.asset(
                        Strings.shield,
                        colorFilter: ColorFilter.mode(
                          Colors.red.shade900,
                          BlendMode.srcIn,
                        ),
                        width: iconSize,
                        height: iconSize,
                      ),
                      const SizedBox(height: 10),
                      MarkdownBody(
                        data: '**THIS DEVICE IS ROOTED/JAILBROKEN!**',
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.ubuntuMono(
                            color: Colors.red,
                            fontSize: 24,
                          ),
                          textAlign: WrapAlignment.center,
                        ),
                      ),
                      const SizedBox(height: 50),
                      MarkdownBody(
                        data: Strings.rootedDeviceMessage,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.ubuntuMono(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: WrapAlignment.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
