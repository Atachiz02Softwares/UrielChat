import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/utilities.dart';

final planProvider = StateNotifierProvider<PlanNotifier, String>((ref) {
  return PlanNotifier();
});

class PlanNotifier extends StateNotifier<String> {
  PlanNotifier() : super('Loading...');

  Future<void> fetchCurrentPlan(WidgetRef ref) async {
    final plan = await Utilities.fetchCurrentPlan(ref);
    state = plan;
  }
}
