import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers/plan_provider.dart';
import '../../providers/speech_service_provider.dart';
import '../../utils/utils.dart';

class MicButton extends ConsumerWidget {
  final TextEditingController searchController;

  const MicButton(this.searchController, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlan = ref.watch(planProvider);
    final speechService = ref.watch(speechServiceProvider);

    return StreamBuilder<bool>(
      stream: speechService.isListeningStream,
      initialData: false,
      builder: (context, snapshot) {
        final isListening = snapshot.data ?? false;
        return IconButton(
          icon: AvatarGlow(
            animate: isListening,
            glowColor: isListening ? Colors.blueGrey : Colors.transparent,
            duration: Duration(seconds: 1),
            repeat: isListening,
            curve: Curves.easeInOut,
            child: SvgPicture.asset(
              Strings.mic,
              colorFilter: const ColorFilter.mode(
                Colors.blueGrey,
                BlendMode.srcIn,
              ),
              width: 30,
              height: 30,
            ),
          ),
          onPressed: () async {
            if (currentPlan == 'premium' || currentPlan == 'platinum') {
              if (isListening) {
                speechService.stop();
              } else {
                await speechService.listen(context, (recognizedWords) {
                  searchController.text = recognizedWords;
                });
              }
            } else {
              Utilities.promptUpgrade(context);
            }
          },
        );
      },
    );
  }
}
