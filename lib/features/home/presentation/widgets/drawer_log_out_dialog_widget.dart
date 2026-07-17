import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/localization/app_localization.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../auth/presentation/manager/auth_bloc.dart';

class DrawerLogOutDialogWidget extends StatelessWidget {
  const DrawerLogOutDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: CircleAvatar(
      radius: 30,
      backgroundColor: Colors.red.withOpacity(0.1),
        child: const Icon(
          Icons.logout_rounded,
          color: AppColors.red300,
          size: 30
        )
      ),
      title: Text("log_out_title".tr(context)),
      content: Text(
        "log_out_content".tr(context),
        textAlign: TextAlign.center
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () => context.pop(),
          child: Text("button_cancel".tr(context))
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red300,
                foregroundColor: AppColors.white
            ),
            onPressed: () {
              // إرسال حدث تسجيل الخروج للـ Bloc
              context.read<AuthBloc>().add(const LogoutRequested());

              // إغلاق الـ Dialog
              context.pop();
            },
            child: Text("log_out_confirm".tr(context))
        )
      ]
    );
  }
}