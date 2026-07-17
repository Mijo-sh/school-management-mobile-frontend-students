import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../app_intro/domain/use_cases/get_app_session_use_case.dart';
import '../../domain/use_cases/get_profile_photo_url_usecase.dart';

/// أفاتار موحّد لعرض الصورة الشخصية (للمستخدم نفسو أو لابن معيّن)،
/// مع تخزين البايتات محليًا تلقائيًا عبر [CachedNetworkImage].
///
/// بما إنو رابط الصورة نفسو محمي بتوكن (لازم Authorization header
/// حتى لصورة الملف نفسها، مش بس لجلب الرابط)، منجيب التوكن من
/// [GetAppSessionUseCase] (نفس الجلسة المستخدمة بكل التطبيق) ونحطو
/// كـ header يدوي.
///
/// الاستخدام:
/// ```dart
/// AuthenticatedAvatar(size: 42, fallback: Icon(Icons.person))               // المستخدم نفسو
/// AuthenticatedAvatar(studentId: child.id, size: 56, fallback: ...)         // ابن معيّن
/// ```
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
  // تخزين الـ Future هنا يمنعه من إعادة التشغيل عند كل build
  late Future<({String? url, String? token})> _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = _load();
  }

  Future<({String? url, String? token})> _load() async {
    final sessionResult = await di<GetAppSessionUseCase>()();
    final token = sessionResult.fold((_) => null, (session) => session.token);

    final urlResult = await di<GetProfilePhotoUrlUseCase>().call(studentId: widget.studentId);
    final url = urlResult.fold((_) => null, (u) => u);

    return (url: url, token: token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _avatarFuture, // نستخدم المتغير المخزن
      builder: (context, snapshot) {
        // إذا كان الـ Future لا يزال في حالة التحميل، نعرض الـ fallback مؤقتاً
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
              width: widget.size, height: widget.size, child: widget.fallback);
        }

        final data = snapshot.data;
        final hasPhoto = data != null && data.url != null &&
            data.url!.isNotEmpty && data.token != null;

        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: hasPhoto
                ? CachedNetworkImage(
              imageUrl: data!.url!,
              httpHeaders: {'Authorization': 'Bearer ${data.token}'},
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Center(
                    child: SizedBox(
                      width: widget.size * 0.35,
                      height: widget.size * 0.35,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              // هنا التعديل الأهم: إذا فشل التحميل، نعرض صورة student_boy.png
              errorWidget: (_, __, ___) =>
                  Image.asset(
                      'assets/images/student_boy.png', fit: BoxFit.cover),
            )
                : Image.asset('assets/images/student_boy.png',
                fit: BoxFit.cover), // في حال كانت البيانات null
          ),
        );
      },
    );
  }
}
