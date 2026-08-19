import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// أفاتار يعرض صورة public من رابط مباشر، مع كاش تلقائي.
class TopStudentAvatar extends StatelessWidget {
  final String photoUrl;
  final double size;
  final Widget fallback;

  const TopStudentAvatar({
    super.key,
    required this.photoUrl,
    required this.size,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isEmpty) return fallback;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Center(
            child: SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}