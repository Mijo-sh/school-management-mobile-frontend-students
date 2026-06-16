import 'package:flutter/material.dart';

class LoginHeaderWidget extends StatelessWidget {
  final double height;

  const LoginHeaderWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // خلفية شبه شفافة
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/background_login.jpg',
                fit: BoxFit.cover,
                color: Colors.white,
                colorBlendMode: BlendMode.difference,
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset('assets/images/logo.png'),
              SizedBox(height: height * 0.05),
              const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: height * 0.2),
            ],
          ),
        ],
      ),
    );
  }
}