import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uriel_chat/custom_widgets/custom.dart';
import 'package:uriel_chat/utils/utils.dart';

import '../../firebase/crud.dart';
import '../../providers/user_provider.dart';

class FeedbackBottomSheet extends ConsumerStatefulWidget {
  const FeedbackBottomSheet({super.key});

  @override
  ConsumerState<FeedbackBottomSheet> createState() =>
      _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends ConsumerState<FeedbackBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _topicController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStyledTextField(
                  controller: _topicController,
                  label: 'Topic',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a topic';
                    }
                    return null;
                  },
                  isTopic: true,
                ),
                const SizedBox(height: 20),
                _buildStyledTextField(
                  controller: _feedbackController,
                  label: 'Feedback',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CustomProgressBar())
                    : CustomButton(
                        icon: Strings.send,
                        label: 'Send Feedback',
                        color: Colors.blueGrey.shade900,
                        onPressed: () {
                          _sendFeedback(context);
                          CustomSnackBar.showSnackBar(
                            context,
                            'Feedback sent successfully!',
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool? isTopic = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: isTopic! ? 1 : 3,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        filled: true,
        fillColor: Colors.blueGrey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
    );
  }

  Future<void> _sendFeedback(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final user = ref.read(userProvider);
      if (user != null) {
        await CRUD().sendFeedback(
          userId: user.uid,
          topic: _topicController.text.trim(),
          feedback: _feedbackController.text.trim(),
        );
        if (context.mounted) {
          Navigator.pop(context);
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}
