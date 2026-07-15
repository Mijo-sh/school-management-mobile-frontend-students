import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/routing/route_name.dart';
import '../../../auth/presentation/widgets/auth_widget.dart';
import '../../../auth/presentation/widgets/verify_widget.dart';
import '../manager/profile_picture_bloc.dart';
import '../manager/profile_picture_event.dart';
import '../manager/profile_picture_state.dart';

/// شاشة تُعرض بعد تسجيل الدخول لأول مرة، وظيفتها اختيار/التقاط صورة
/// شخصية وحفظها محليًا (مجلد التطبيق + SharedPreferences) عبر
/// [ProfilePictureBloc].
///
/// تُستدعى من GoRouter بدون parameters:
///   GoRoute(path: RouteName.addPic, builder: (_, __) => const AddPicturePage())
class AddPicturePage extends StatelessWidget {
  const AddPicturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<ProfilePictureBloc>(),
      child: const _AddPictureView(),
    );
  }
}

class _AddPictureView extends StatefulWidget {
  const _AddPictureView();

  @override
  State<_AddPictureView> createState() => _AddPictureViewState();
}

class _AddPictureViewState extends State<_AddPictureView>
    with SingleTickerProviderStateMixin {
  File? _pickedImage;

  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _fade =
  CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (xFile != null) {
        setState(() => _pickedImage = File(xFile.path));
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        context,
        'تعذّر فتح ${source == ImageSource.camera ? 'الكاميرا' : 'المعرض'}',
      );
    }
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_pickedImage != null)
                ListTile(
                  leading:
                  const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('إزالة الصورة',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _pickedImage = null);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<ProfilePictureBloc, ProfilePictureState>(
        listener: (context, state) {
          if (state is ProfilePictureSaved) {
            if (!state.uploadedToServer) {
              _showSnack(
                context,
                'تم حفظ الصورة على جهازك، بس ما قدرنا نرفعها للسيرفر حاليًا',
              );
            }
            context.go(RouteName.homeShell);
          } else if (state is ProfilePictureSkipped) {
            context.go(RouteName.homeShell);
          } else if (state is ProfilePictureError) {
            _showSnack(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfilePictureLoading;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: AuthBackground(
              child: AuthScaffoldBody(
                fade: _fade,
                slide: _slide,
                children: [
                  const Spacer(flex: 1),
                  const AuthBadge(icon: Icons.person_rounded),
                  const SizedBox(height: 20),
                  AuthHeaderText(
                    title: 'أضف صورتك الشخصية',
                    subtitle: Text(
                      'ساعد أصدقاءك على التعرف عليك بسهولة',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onPrimary.withOpacity(0.85)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 1),
                  AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _showPickerSheet,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 128,
                                  width: 128,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cs.primary.withOpacity(0.08),
                                    border: Border.all(
                                      color: cs.outlineVariant,
                                      width: 1.5,
                                    ),
                                    image: _pickedImage != null
                                        ? DecorationImage(
                                      image: FileImage(_pickedImage!),
                                      fit: BoxFit.cover,
                                    )
                                        : null,
                                  ),
                                  child: _pickedImage == null
                                      ? Icon(
                                    Icons.person_rounded,
                                    size: 64,
                                    color: cs.primary.withOpacity(0.4),
                                  )
                                      : null,
                                ),
                                Positioned(
                                  bottom: -2,
                                  left: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cs.primary,
                                      border: Border.all(
                                        color: cs.surface,
                                        width: 3,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      size: 18,
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: _showPickerSheet,
                            child: Text(
                              _pickedImage == null ? 'اختيار صورة' : 'تغيير الصورة',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthPrimaryButton(
                          label: 'متابعة',
                          isLoading: isLoading,
                          enabled: _pickedImage != null,
                          trailingIcon: Icons.arrow_back_rounded,
                          onPressed: () {
                            if (_pickedImage == null) return;
                            context.read<ProfilePictureBloc>().add(
                              SaveProfilePictureRequested(_pickedImage!),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.read<ProfilePictureBloc>().add(
                              const SkipProfilePictureRequested(),
                            ),
                            child: Text(
                              'تخطي الآن',
                              style: tt.bodyMedium
                                  ?.copyWith(color: cs.onSurface.withOpacity(0.6)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}