// widgets/child_card_tile.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_name.dart';
import '../../domain/entities/child_card.dart';
import 'child_avatar.dart';

class ChildCardTile extends StatelessWidget {
  final ChildCard child;
  const ChildCardTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () {
        context.go(
          ParentRouteName.childDashboard,
          extra: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.primary.withOpacity(0.8), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: cs.primaryContainer.withOpacity(0.18),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                child.fullName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _InfoLine(label: 'المدرسة', value: "الغد المشرق", size: 15),
                        const SizedBox(height: 15),
                        _InfoLine(label: 'الصف', value: child.gradeName, size: 15),
                        const SizedBox(height: 15),
                        _InfoLine(label: 'الشعبة', value: child.classNumber, size: 15),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  ChildAvatar(
                    photoUrl: child.studentPhotoUrl,
                    name: child.firstName,
                    gender: child.gender,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final double size;

  const _InfoLine({
    required this.label,
    required this.value,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final styleLabel = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: cs.onSurface,
    );
    final styleText = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: cs.onSurface,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: styleLabel),
        const SizedBox(width: 4),
        Text(':', style: styleLabel),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: styleText,
          ),
        ),
      ],
    );
  }
}