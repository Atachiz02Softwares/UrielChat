import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/strings.dart';

final filterOptionsProvider =
    StateNotifierProvider<FilterOptionsNotifier, Map<String, String>>(
  (ref) => FilterOptionsNotifier(),
);

class FilterOptionsNotifier extends StateNotifier<Map<String, String>> {
  FilterOptionsNotifier()
      : super({
          'topic': Strings.userDefined,
          'tone': Strings.userDefined,
          'mode': Strings.userDefined,
        });

  void update(String topic, String tone, String mode) {
    state = {
      'topic': topic,
      'tone': tone,
      'mode': mode,
    };
  }
}
