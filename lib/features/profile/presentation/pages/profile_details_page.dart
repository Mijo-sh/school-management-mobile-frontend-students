import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_management_mobile_frontend_students/features/shared/domain/entities/user_entity.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/DecorativeHeaderBackground.dart';
import '../../domain/use_cases/get_cached_user_usecase.dart';
import 'authenticated_avatar.dart';

class ProfileDetailsPage extends StatefulWidget {
  final int? studentId;

  const ProfileDetailsPage({super.key, this.studentId});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  File? _pickedImage;
  int _avatarRefreshTick = 0;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  late final Future<UserEntity?> _userFuture = _loadUser();

  Future<UserEntity?> _loadUser() async {
    final result = await di<GetCachedUserUsecase>().call();
    return result.fold((_) => null, (user) => user);
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: cs.surface,
        body: FutureBuilder<UserEntity?>(
          future: _userFuture,
          builder: (context, snapshot) {
            final user = snapshot.data;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 250,
                  toolbarHeight: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: cs.primary,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 👇 هون بالضبط مكانها — طبقة خلفية وحدة،
                          // ثابتة (بدون collapseRatio لأنو هالصفحة
                          // بدون أنيميشن سحب/تصغير).
                          const DecorativeHeaderBackground(),
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                children: [
                                  // ── شريط علوي: رجوع + عنوان ──
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward_rounded, color: cs.onPrimary, size: 26),
                                        onPressed: () => Navigator.of(context).maybePop(),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'الملف الشخصي',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: cs.onPrimary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 48), // موازنة بصرية لزر الرجوع
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // ── الصورة + زر الكاميرا العائم ──
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 112,
                                        height: 112,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.15),
                                              blurRadius: 12,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: _pickedImage != null
                                              ? Image.file(
                                            _pickedImage!,
                                            key: ValueKey('picked_$_avatarRefreshTick'),
                                            fit: BoxFit.cover,
                                            width: 112,
                                            height: 112,
                                          )
                                              : AuthenticatedAvatar(
                                            key: ValueKey('avatar_$_avatarRefreshTick'),
                                            studentId: widget.studentId,
                                            size: 112,
                                            borderRadius: BorderRadius.circular(56),
                                            fallback: Icon(
                                              Icons.person_rounded,
                                              size: 56,
                                              color: cs.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // طبقة تحميل شفافة أثناء الرفع الفعلي
                                      if (_isUploading)
                                        Positioned.fill(
                                          child: ClipOval(
                                            child: Container(
                                              color: Colors.black.withOpacity(0.45),
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // زر الكاميرا — بالـ RTL، أسفل يسار الدائرة
                                      // بصريًا هو أقرب لبداية القراءة، شكل مألوف
                                      // لزر "تعديل".
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: GestureDetector(

                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: cs.secondary,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: cs.primary, width: 2.5),
                                            ),
                                            child: Icon(
                                              Icons.camera_alt_rounded,
                                              color: cs.onSecondary,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // اسم كامل: الاسم الأول + اسم الأب + اسم العائلة
                                  // (نفس العرف المتبع بباقي بيانات المستخدمين
                                  // بالتطبيق).
                                  Text(
                                    user != null
                                        ? '${user.firstName} ${user.fatherName} ${user.lastName}'
                                        : '...',
                                    style: TextStyle(
                                      color: cs.onPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Text(
                                  //   user != null ? _roleLabel(user.roles) : '',
                                  //   style: TextStyle(
                                  //     color: cs.onPrimary.withOpacity(0.75),
                                  //     fontSize: 13,
                                  //   ),
                                  // ),
                                  // const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── قائمة معلومات إضافية (كارد جوا كارد، نفس نمط التطبيق) ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      user == null
                          ? [const Center(child: CircularProgressIndicator())]
                          : _buildInfoCards(user),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }

  /// كل حقول [User] ما عدا id وaccount_status، بترتيب منطقي، مع
  /// تسميات وترجمات عربية.
  List<Widget> _buildInfoCards(UserEntity user) {
    final rows = <_InfoCard>[
      _InfoCard(icon: Icons.person_outline_rounded, label: 'الاسم الأول', value: user.firstName),
      _InfoCard(icon: Icons.person_outline_rounded, label: 'اسم الأب', value: user.fatherName),
      _InfoCard(icon: Icons.person_outline_rounded, label: 'اسم الأم', value: user.motherName),
      _InfoCard(icon: Icons.person_outline_rounded, label: 'اسم العائلة', value: user.lastName),
      _InfoCard(icon: Icons.phone_outlined, label: 'رقم الهاتف', value: user.phoneNumber),
      _InfoCard(icon: Icons.cake_outlined, label: 'تاريخ الميلاد', value: user.birthDate),
      _InfoCard(icon: Icons.location_city_outlined, label: 'مكان الميلاد', value: user.birthPlace),
      _InfoCard(icon: Icons.home_outlined, label: 'العنوان', value: user.address),
      _InfoCard(icon: Icons.flag_outlined, label: 'الجنسية', value: user.nationality),
      _InfoCard(icon: Icons.wc_rounded, label: 'الجنس', value: _genderLabel(user.gender)),
      _InfoCard(icon: Icons.verified_user_outlined, label: 'حالة السجل', value: _recordStatusLabel(user.recordStatus)),
      //_InfoCard(icon: Icons.badge_outlined, label: 'الدور', value: _roleLabel(user.roles)),
    ];

    return [
      for (int i = 0; i < rows.length; i++) ...[
        rows[i],
        if (i != rows.length - 1) const SizedBox(height: 12),
      ],
    ];
  }

  String _genderLabel(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'ذكر';
      case 'female':
        return 'أنثى';
      default:
        return gender;
    }
  }

  String _recordStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'inactive':
        return 'غير نشط';
      default:
        return status;
    }
  }

  String _roleLabel(List<String> roles) {
    final translated = roles.map((r) {
      switch (r.toLowerCase()) {
        case 'student':
          return 'طالب';
        case 'guardian':
          return 'ولي أمر';
        default:
          return r;
      }
    });
    return translated.join('، ');
  }
}

/// نفس نمط "كارد جوا كارد" المستخدم بكل مكان تاني بالتطبيق (كارد
/// الأبناء، فقاعات التنبيهات...).
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: cs.primary.withOpacity(0.15), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: cs.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.55)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: cs.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}