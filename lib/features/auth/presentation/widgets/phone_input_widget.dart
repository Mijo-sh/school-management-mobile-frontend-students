import 'package:flutter/material.dart';

class PhoneInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendCode;

  const PhoneInputWidget({
    super.key,
    required this.controller,
    required this.onSendCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.02),
          child: const Text("رقم الهاتف", style: TextStyle(fontSize: 15)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          decoration: InputDecoration(
            labelText: '',
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                const Icon(Icons.phone),
                const SizedBox(width: 10),
                const Text("963+"),
                Text("|", style: TextStyle(fontSize: 40, color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onSendCode,
          icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary, size: 18),
          label: Text(
            'إرسال رمز التحقق',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}