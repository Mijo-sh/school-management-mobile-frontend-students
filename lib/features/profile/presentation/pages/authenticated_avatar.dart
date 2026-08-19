import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/injector/injector_container.dart';
import '../../domain/use_cases/get_profile_photo_url_usecase.dart';

/// أفاتار لعرض صورة شخصية public (رابط مباشر)، مع كاش تلقائي.
class AuthenticatedAvatar extends StatefulWidget {
  final int? studentId;
  final double size;
  final Widget fallback;
  final BorderRadius borderRadius;

  /// رابط جاهز (اختياري). لو انبعت، منستخدمه مباشرة بدون نداء إضافي.
  final String? directUrl;

  const AuthenticatedAvatar({
    super.key,
    this.studentId,
    required this.size,
    required this.fallback,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.directUrl,
  });

  @override
  State<AuthenticatedAvatar> createState() => _AuthenticatedAvatarState();
}

class _AuthenticatedAvatarState extends State<AuthenticatedAvatar> {
  late Future<String?> _future = _load();

  Future<String?> _load() async {
    // لو في رابط جاهز، استخدمه مباشرة
    if (widget.directUrl != null && widget.directUrl!.isNotEmpty) {
      return widget.directUrl;
    }
    // غير هيك، جيب الرابط حسب studentId
    final urlResult =
    await di<GetProfilePhotoUrlUseCase>().call(studentId: widget.studentId);
    return urlResult.fold((_) => null, (u) => u);
  }

  @override
  void didUpdateWidget(covariant AuthenticatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentId != widget.studentId ||
        oldWidget.directUrl != widget.directUrl) {
      _future = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _future,
      builder: (context, snapshot) {
        final url = snapshot.data;
        final hasPhoto = url != null && url.isNotEmpty;

        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: hasPhoto
                ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => Center(
                child: SizedBox(
                  width: widget.size * 0.35,
                  height: widget.size * 0.35,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => widget.fallback,
            )
                : widget.fallback,
          ),
        );
      },
    );
  }
}