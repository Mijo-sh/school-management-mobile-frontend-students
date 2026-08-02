import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../app_intro/domain/use_cases/get_app_session_use_case.dart';
import '../../domain/use_cases/get_profile_photo_url_usecase.dart';

/// أفاتار موحّد لعرض الصورة الشخصية (للمستخدم نفسو أو لابن معيّن)،
/// مع تخزين البايتات محليًا تلقائيًا عبر [CachedNetworkImage].
///
/// ⚠️ StatefulWidget عمدًا (مش Stateless) — الـ Future بتتخزن مرة
/// وحدة بس بحقل الحالة (State)، حتى ما نعيد طلب رابط الصورة من جديد
/// كل ما الـ widget يعيد البناء (زي أثناء السكرول جوا SliverAppBar،
/// أو أي rebuild عادي للشجرة فوقها).
class AuthenticatedAvatar extends StatefulWidget {
  final int? studentId;
  final double size;
  final Widget fallback;
  final BorderRadius borderRadius;

  const AuthenticatedAvatar({
    super.key,
    this.studentId,
    required this.size,
    required this.fallback,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<AuthenticatedAvatar> createState() => _AuthenticatedAvatarState();
}

class _AuthenticatedAvatarState extends State<AuthenticatedAvatar> {
  // 👇 السطر الحاسم — late (مش داخل build) يعني بينحسب مرة وحدة بس
  // أول ما الـ State تتخلق، وبيضل نفس الـ Future المخزّنة طول عمر
  // الـ widget، بغض النظر كم مرة build() تنعاد.
  late Future<({String? url, String? token})> _future = _load();

  Future<({String? url, String? token})> _load() async {
    final sessionResult = await di<GetAppSessionUseCase>()();
    final token = sessionResult.fold((_) => null, (session) => session.token);

    final urlResult = await di<GetProfilePhotoUrlUseCase>().call(studentId: widget.studentId);
    final url = urlResult.fold((_) => null, (u) => u);

    return (url: url, token: token);
  }

  @override
  void didUpdateWidget(covariant AuthenticatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو تغيّر studentId فعليًا (نادر)، أو تغيّر الـ key من برا (سحب
    // للتحديث)، فلاتر بينشئ State جديدة أصلًا فبيعيد initState —
    // هاد هون احتياط إضافي بس لتغيّر studentId بدون تغيير key.
    if (oldWidget.studentId != widget.studentId) {
      _future = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future, // 👈 نفس الـ Future المخزّنة، مش نداء جديد كل build
      builder: (context, snapshot) {
        final data = snapshot.data;
        final hasPhoto = data != null && data.url != null && data.token != null;

        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: hasPhoto
                ? CachedNetworkImage(
              imageUrl: data.url!,
              httpHeaders: {'Authorization': 'Bearer ${data.token}'},
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