import 'package:flutter/material.dart';

class OtpInputWidget extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onChanged;

  const OtpInputWidget({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        return SizedBox(
          width: 52,
          height: 60,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            onTap: () {
              // انتقل لأول مربع فارغ
              for (int i = 0; i < 5; i++) {
                if (controllers[i].text.isEmpty) {
                  focusNodes[i].requestFocus();
                  return;
                }
              }
              focusNodes[4].requestFocus();
            },
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < 4) focusNodes[index + 1].requestFocus();
              } else {
                if (index > 0) focusNodes[index - 1].requestFocus();
              }
              onChanged();
            },
          ),
        );
      }),
    );
  }
}