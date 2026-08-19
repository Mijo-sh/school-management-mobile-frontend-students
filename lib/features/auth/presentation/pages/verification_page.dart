import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_name.dart';
import '../../../shared/domain/entities/user_role.dart';
import '../manager/auth_bloc.dart';
import '../widgets/auth_widget.dart';
import '../widgets/verify_widget.dart';
class VerificationPage extends StatefulWidget {
  final String phoneNumber;
  const VerificationPage({super.key, required this.phoneNumber});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with SingleTickerProviderStateMixin {
  // 👇 طول رمز التحقق (من Postman الرمز 5 خانات).
  static const int _codeLength = 5;
  static const int _resendSeconds = 30;

  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

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

  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _animController.forward();
    _startTimer();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
    _codeController.addListener(() {
      setState(() {});
      if (_codeController.text.length == _codeLength) {
        _verify();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _codeController.text.trim();
    if (code.length != _codeLength) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      LoginRequested(phoneNumber: widget.phoneNumber, otp: code),
    );
  }

  void _resend() {
    context.read<AuthBloc>().add(ResendOtpRequested(widget.phoneNumber));
    _codeController.clear();
    _startTimer();
  }

  void _goHome(UserRole role) {
    // بعد نجاح تسجيل الدخول لأول مرة، نوجّه المستخدم لصفحة إضافة
    // الصورة الشخصية (AddPicturePage) بدل ما نروح مباشرة للـ MainScreen.
    context.go(RouteName.homeShell);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            _goHome(state.user.primaryRole);
          } else if (state is AuthError) {
            _codeController.clear();
            _focusNode.requestFocus();
            _showSnack(context, state.message);
          } else if (state is OtpSentSuccess) {
            _showSnack(context, 'تم إرسال الرمز مجدداً');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final code = _codeController.text;

          return  AuthBackground(
              child: AuthScaffoldBody(
                fade: _fade,
                slide: _slide,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(Icons.arrow_forward_rounded,
                            color: cs.onPrimary),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  const AuthBadge(icon: Icons.sms_rounded),
                  const SizedBox(height: 20),
                  AuthHeaderText(
                    title: 'تحقق من رقمك',
                    subtitle: Text.rich(
                      TextSpan(
                        text: 'أرسلنا رمزاً إلى\n',
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onPrimary.withOpacity(0.85)),
                        children: [
                          TextSpan(
                            text: widget.phoneNumber,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 1),
                  AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _OtpField(
                          length: _codeLength,
                          controller: _codeController,
                          focusNode: _focusNode,
                          code: code,
                        ),
                        const SizedBox(height: 28),
                        AuthPrimaryButton(
                          label: 'تحقق',
                          isLoading: isLoading,
                          enabled: code.length == _codeLength,
                          onPressed: _verify,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: _secondsLeft > 0
                              ? Text(
                            'إعادة الإرسال بعد 00:${_secondsLeft.toString().padLeft(2, '0')}',
                            style: tt.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                          )
                              : TextButton(
                            onPressed: isLoading ? null : _resend,
                            child: const Text('إعادة إرسال الرمز'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
          );
        },
      ),
    );
  }
}

/// Underline-style OTP boxes over a single invisible text field.
class _OtpField extends StatelessWidget {
  final int length;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String code;

  const _OtpField({
    required this.length,
    required this.controller,
    required this.focusNode,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return  Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(length, (i) {
              final filled = i < code.length;
              final isCurrent = i == code.length && focusNode.hasFocus;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 7),
                width: 34,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Center(
                        child: Text(
                          filled ? code[i] : '',
                          style: tt.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: isCurrent ? 3.5 : 2.5,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? cs.primary
                            : filled
                            ? cs.primary.withOpacity(0.55)
                            : cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                maxLength: length,
                showCursor: false,
                enableSuggestions: false,
                autocorrect: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
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