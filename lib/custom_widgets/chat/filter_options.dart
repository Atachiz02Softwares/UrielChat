import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/filter_options_provider.dart';
import '../../utils/utils.dart';
import '../custom.dart';

class FilterOptions extends ConsumerWidget {
  final String selectedTopic;
  final String selectedTone;
  final String selectedMode;
  final ValueChanged<String?> onTopicChanged;
  final ValueChanged<String?> onToneChanged;
  final ValueChanged<String?> onModeChanged;

  const FilterOptions({
    super.key,
    required this.selectedTopic,
    required this.selectedTone,
    required this.selectedMode,
    required this.onTopicChanged,
    required this.onToneChanged,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterDropdown(
            'Select Topic',
            selectedTopic,
            Strings.topics,
            onTopicChanged,
          ),
          const SizedBox(height: 10),
          _buildFilterDropdown(
            'Select Tone',
            selectedTone,
            Strings.tones,
            onToneChanged,
          ),
          const SizedBox(height: 10),
          _buildFilterDropdown(
            'Select Mode',
            selectedMode,
            Strings.modes,
            onModeChanged,
          ),
          const SizedBox(height: 20),
          CustomButton(
            icon: Strings.settings,
            label: 'Apply Filters',
            color: Colors.blueGrey.shade900,
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(filterOptionsProvider.notifier).update(
                    selectedTopic,
                    selectedTone,
                    selectedMode,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        DropdownButton<String>(
          value: selectedValue,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 30,
          ),
          dropdownColor: Colors.black,
          isExpanded: true,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: CustomText(
                text: option,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
