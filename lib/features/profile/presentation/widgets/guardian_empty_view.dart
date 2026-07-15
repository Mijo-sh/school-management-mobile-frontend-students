// widgets/guardian_empty_view.dart
import 'package:flutter/material.dart';

class GuardianEmptyView extends StatelessWidget {
  const GuardianEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.child_care_rounded, size: 64, color: cs.onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'لا يوجد أبناء مسجّلين',
            style: TextStyle(fontSize: 16, color: cs.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}