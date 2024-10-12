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
          const SizedBox(height: 20),
          _buildFilterDropdown(
            'Select Tone',
            selectedTone,
            Strings.tones,
            onToneChanged,
          ),
          const SizedBox(height: 20),
          _buildFilterDropdown(
            'Select Mode',
            selectedMode,
            Strings.modes,
            onModeChanged,
          ),
          const SizedBox(height: 50),
          CustomButton(
            icon: Strings.filter,
            label: 'Apply Filters',
            color: Colors.blueGrey.shade900,
            onPressed: () {
              ref
                  .read(filterOptionsProvider.notifier)
                  .update(topic: selectedTopic);
              ref
                  .read(filterOptionsProvider.notifier)
                  .update(tone: selectedTone);
              ref
                  .read(filterOptionsProvider.notifier)
                  .update(mode: selectedMode);
              Navigator.of(context).pop();
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
    return StatefulBuilder(
      builder: (context, setState) {
        bool isExpanded = false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: label,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isExpanded ? 300 : 56,
                // Adjust height for expanded view
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: selectedValue,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  dropdownColor: Colors.black,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  isExpanded: true,
                  items: options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: CustomText(
                        text: option,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    onChanged(value);
                    setState(() {
                      isExpanded = false; // Close dropdown after selection
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
