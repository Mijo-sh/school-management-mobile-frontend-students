// presentation/shared/widgets/unified_empty_view.dart
import 'package:flutter/material.dart';

class UnifiedEmptyView extends StatelessWidget {
  final IconData icon;
  final String message;

  const UnifiedEmptyView({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: cs.onSurface.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}