import 'package:flutter/material.dart';

/// Circular glass badge with an icon — the header emblem on both pages.
class AuthBadge extends StatelessWidget {
  final IconData icon;
  const AuthBadge({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(

      height: 96,
      width: 96,
      decoration: BoxDecoration(
        color: cs.onPrimary.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: cs.onPrimary.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Icon(icon, size: 46, color: cs.onPrimary),
    );
  }
}

/// White rounded card that holds the form content on both pages.
class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Tall primary button that swaps its label for a spinner while loading.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;
  final IconData? trailingIcon;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: (!enabled || isLoading) ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
            key: ValueKey('loader'),
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          )
              : Row(
            key: const ValueKey('label'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// White title + subtitle block shown above the card on both pages.
class AuthHeaderText extends StatelessWidget {
  final String title;
  final Widget subtitle;
  const AuthHeaderText({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: tt.headlineMedium?.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: subtitle,
        ),
      ],
    );
  }
}

/// Shared scrollable scaffold body that keeps content centered, survives the
/// keyboard, and applies the entrance fade+slide. Pass the column [children].
class AuthScaffoldBody extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final List<Widget> children;

  const AuthScaffoldBody({
    super.key,
    required this.fade,
    required this.slide,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints:
              BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: FadeTransition(
                  opacity: fade,
                  child: SlideTransition(
                    position: slide,
                    child: Column(children: children),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}