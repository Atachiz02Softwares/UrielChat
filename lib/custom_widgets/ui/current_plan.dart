import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/plan_provider.dart';
import 'custom_text.dart';

class CurrentPlan extends ConsumerWidget {
  const CurrentPlan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlan = ref.watch(planProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: CustomText(
        text: '${currentPlan.toUpperCase()} PLAN',
        style: const TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
