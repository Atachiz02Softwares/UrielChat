import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_widgets/custom.dart';
import '../providers/providers.dart';

class AISettingScreen extends ConsumerWidget {
  const AISettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterOptions = ref.watch(filterOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: const CustomText(
          text: 'Customize Uriel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [CurrentPlan()],
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterOptions(
                  selectedTopic: filterOptions['topic']!,
                  selectedTone: filterOptions['tone']!,
                  selectedMode: filterOptions['mode']!,
                  onTopicChanged: (String? newValue) {
                    ref
                        .read(filterOptionsProvider.notifier)
                        .update(topic: newValue);
                  },
                  onToneChanged: (String? newValue) {
                    ref
                        .read(filterOptionsProvider.notifier)
                        .update(tone: newValue);
                  },
                  onModeChanged: (String? newValue) {
                    ref
                        .read(filterOptionsProvider.notifier)
                        .update(mode: newValue);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
