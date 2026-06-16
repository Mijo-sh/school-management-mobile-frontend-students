import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/pages/nav.dart';
import '../manager/auth_bloc.dart';

class OtpDialog extends StatefulWidget {
  final String phone;

  const OtpDialog({super.key, required this.phone});

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final List<TextEditingController> _controllers =
  List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  int _secondsRemaining = 30;
  dynamic _timer;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(SendOtpRequested(widget.phone));
    _startTimer();

    for (int i = 0; i < 5; i++) {
      _focusNodes[i].addListener(() => _onFocusChange(i));
    }
  }

  void _onFocusChange(int i) {
    if (!_focusNodes[i].hasFocus) return;
    final firstEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
    if (firstEmpty != -1 && i > firstEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes[firstEmpty].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var n in _focusNodes) n.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 30);
    _timer = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _resend() {
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
    context.read<AuthBloc>().add(SendOtpRequested(widget.phone));
    _startTimer();
  }

  void _verify() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رمز التحقق كاملاً')),
      );
      return;
    }
    context.read<AuthBloc>().add(
      VerifyOtpRequested(phoneNumber: widget.phone, otpCode: otp),
    );
  }

  void _onChanged(int i, String val) {
    if (val.length == 1 && i < 4) {
      _focusNodes[i + 1].requestFocus();
    } else if (val.isEmpty && i > 0) {
      _focusNodes[i - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // اللون البنفسجي الأساسي المأخوذ من تصميمك
    const Color brandPurple = Color(0xFF6F3CC1);
    const Color bgGrey = Color(0xFFE5E3EA);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is VerifyOtpSuccess) {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
        if (state is VerifyOtpFailure || state is SendOtpFailure) {
          final msg = state is VerifyOtpFailure
              ? (state as VerifyOtpFailure).message
              : (state as SendOtpFailure).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        }
      },
// ... بداية الكود ...
      child: Dialog(
        insetAnimationDuration: Duration.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: 295, // عرض ملموم ومتناسق جداً
          child: Padding(
            // تقليل الـ padding العلوي والسفلي لضغط الارتفاع
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // يضمن كش الارتفاع على قد المحتوى
              children: [
                // ── Shield icon (تقليل المسافة تحت الأيقونة) ──
                const Icon(
                  Icons.shield,
                  color: brandPurple,
                  size: 48, // حجم أصغر ومناسب
                ),
                const SizedBox(height: 8),
                // تقليل المسافة

                // ── Title ────────────────────────
                const Text(
                  'Verification',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // تقليل المسافة
                Text(
                  'Enter the 5-digit verification code.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // تقليل المسافة قبل المربعات

                // ── OTP boxes ────────────────────
                // تم تعديل الـ Row ليكون متمركز بالمنتصف مع مسافات مخصصة ومحكومة بين المربعات
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                        (i) =>
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          // مسافة 4 بكسل فقط بين كل مربع ومربع
                          child: _OtpBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            onChanged: (val) => _onChanged(i, val),
                            activeColor: brandPurple,
                            fillColor: bgGrey,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                // تقليل المسافة بعد المربعات

                // ── Resend Code ──────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: _secondsRemaining == 0 ? _resend : null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _secondsRemaining == 0
                            ? 'Resend Code'
                            : 'Resend Code in ${_secondsRemaining}s',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // ── Actions ──────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFFD65353),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final bool isLoading = state is VerifyOtpLoading ||
                              state is SendOtpLoading;
                          return Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: brandPurple,
                              borderRadius: BorderRadius.circular(
                                  12),
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _verify,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                                  : const Text(
                                'Verify',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),);
  }
}

// ── Single OTP box ────────────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final Color activeColor;
  final Color fillColor;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.activeColor,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 60,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        autofocus: false,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            // حدود ناعمة رمادية خفيفة جداً
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: activeColor, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}