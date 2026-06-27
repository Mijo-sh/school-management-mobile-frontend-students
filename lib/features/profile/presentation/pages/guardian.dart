import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/child_card.dart';
import '../manager/guardian_cubit.dart';

class GuardianPage extends StatelessWidget {
  const GuardianPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocBuilder<GuardianCubit, GuardianState>(
        builder: (context, state) {
          if (state is GuardianLoading || state is GuardianInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GuardianError) {
            return _ErrorView(message: state.message);
          }

          final loaded = state as GuardianLoaded;
          if (loaded.children.isEmpty) {
            return const _EmptyView();
          }

          return _ChildrenList(children: loaded.children);
        },
      ),
    );
  }
}

// ── HEADER + LIST ────────────────────────
class _ChildrenList extends StatelessWidget {
  final List<ChildCard> children;
  const _ChildrenList({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Curved header
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(
              top: statusBarHeight + 24,
              bottom: 32,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بك',
                  style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أبناؤك',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${children.length} ${children.length == 1 ? "طالب" : "طلاب"}',
                  style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _ChildCardTile(child: children[index]),
              childCount: children.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── SINGLE CARD ──────────────────────────
class _ChildCardTile extends StatelessWidget {
  final ChildCard child;
  const _ChildCardTile({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : Colors.grey[850],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // الصورة
            _ChildAvatar(photoUrl: child.studentPhotoUrl, name: child.firstName),
            const SizedBox(width: 16),
            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _InfoChip(
                    icon: Icons.school_rounded,
                    label: child.gradeName,
                    color: cs.primary,
                  ),
                  const SizedBox(height: 6),
                  _InfoChip(
                    icon: Icons.groups_rounded,
                    label: child.classNumber,
                    color: cs.secondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: cs.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AVATAR (مع التعامل مع الصورة المكسورة) ──
class _ChildAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  const _ChildAvatar({required this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final String initial =
    name.trim().isNotEmpty ? name.trim().characters.first.toUpperCase() : '?';

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.2), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: (photoUrl != null && photoUrl!.isNotEmpty)
          ? Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        // 👇 لو الصورة مكسورة، نعرض أول حرف من الاسم
        errorBuilder: (_, __, ___) => _fallback(cs, initial),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
            ),
          );
        },
      )
          : _fallback(cs, initial),
    );
  }

  Widget _fallback(ColorScheme cs, String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: cs.onPrimaryContainer,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── INFO CHIP ────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── ERROR VIEW ───────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: cs.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: cs.onSurface),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.read<GuardianCubit>().loadChildren(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── EMPTY VIEW ───────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.child_care_rounded, size: 64, color: cs.onSurface.withOpacity(0.3)),
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