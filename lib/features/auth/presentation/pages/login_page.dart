import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/assets_manager/images_manager.dart';
import '../manager/auth_bloc.dart';
import '../widgets/auth_widget.dart';
import '../widgets/verify_widget.dart';
import 'otp_dailog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  static const int _localDigits = 9;

  final _phoneController = TextEditingController();

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
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  String get _fullPhone => '0${_phoneController.text.trim()}';

  void _onSendPressed() {
    final raw = _phoneController.text.trim();
    if (raw.length != _localDigits) {
      _showSnack(context, 'رقم الهاتف يجب أن يكون $_localDigits أرقام');
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(SendOtpRequested(_fullPhone));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthBloc, AuthState>(
        // لا نتفاعل إلا والصفحة هي الظاهرة (نتفادى تكرار الإشعارات بعد الانتقال)
        listenWhen: (_, __) => ModalRoute.of(context)?.isCurrent ?? true,
        listener: (context, state) {
          if (state is OtpSentSuccess) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: VerificationPage(phoneNumber: _fullPhone),
                ),
              ),
            );
          } else if (state is AuthError) {
            _showSnack(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final valid = _phoneController.text.trim().length == _localDigits;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: AuthBackground(
              child: AuthScaffoldBody(
                fade: _fade,
                slide: _slide,
                children: [
                  const Spacer(flex: 1),
                   Image.asset(ImagesManager.logo),
                  const SizedBox(height: 20),
                  AuthHeaderText(
                    title: 'أهلاً بك',
                    subtitle: Text(
                      'أدخل رقم هاتفك وسنرسل لك رمز تحقق',
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
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text('رقم الهاتف', style: tt.titleMedium),
                        ),
                        const SizedBox(height: 12),
                        _PhoneField(controller: _phoneController),
                        const SizedBox(height: 28),
                        AuthPrimaryButton(
                          label: 'إرسال الرمز',
                          isLoading: isLoading,
                          enabled: valid,
                          trailingIcon: Icons.arrow_back_rounded,
                          onPressed: _onSendPressed,
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

/// Phone input with a fixed +963 prefix; collects the 9 local digits.
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        maxLength: 9,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          hintText: '9XX XXX XXX',
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_rounded, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  '+963',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 26, color: cs.outlineVariant),
              ],
            ),
          ),
          prefixIconConstraints:
          const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
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