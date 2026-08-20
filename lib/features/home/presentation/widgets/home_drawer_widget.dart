import '../../../../../../core/assets_manager/images_manager.dart';
import '../../../../../../core/localization/app_localization.dart';
import '../../../../../../core/routing/route_name.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/routing/selected_child_holder.dart';
import '../../../auth/presentation/manager/auth_bloc.dart';
import '../../../language/presentation/bloc/language_bloc.dart';
import '../../../shared/domain/entities/user_role.dart';
import '../../../theme/domain/enums/theme_type.dart';
import '../../../theme/presentation/bloc/theme_bloc.dart';
import 'drawer_log_out_dialog_widget.dart';
class HomeDrawerWidget extends StatelessWidget {
  final bool isDark;
  final UserRole role;
  final bool showChildOptions; // 👈 جديد

  const HomeDrawerWidget({
    super.key,
    required this.isDark,
    required this.role,
    this.showChildOptions = true, // افتراضي
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = di<SelectedChildHolder>().current;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          context.pop();
          context.go(RouteName.logIn);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: NavigationDrawer(
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DrawerHeader(
                        margin: EdgeInsets.zero,
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: Column(
                            children: [
                              Image.asset(
                                  ImagesManager.logo,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.contain
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "app_name".tr(context),
                                style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 25
                                ),
                              )
                            ]
                        )
                    ),
                    Positioned.fill(
                        child: Opacity(
                            opacity: 0.15,
                            child: Image.asset(
                                ImagesManager.patternBackground,
                                fit: BoxFit.fill,
                                color: AppColors.white,
                                colorBlendMode: BlendMode.srcIn
                            )
                        )
                    )
                  ]
              ),
            ),

            // 2. خيار تغيير الثيم
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                final isDarkTheme = state.type == ThemeType.dark;

                return _buildListTile(
                  context,
                  isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                  "",
                      () {
                    context.read<ThemeBloc>().add(ToggleThemeEvent());
                  },
                  titleWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("drawer_theme".tr(context)),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () {
                          context.read<ThemeBloc>().add(ToggleThemeEvent());
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 58,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDarkTheme ? theme.colorScheme.primary : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            alignment: isDarkTheme ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Icon(
                                  isDarkTheme ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                  size: 15,
                                  color: isDarkTheme ? theme.colorScheme.primary : Colors.amber.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // 3. خيار تغيير اللغة
            _buildListTile(context, Icons.language, "drawer_language".tr(context), () {
              context.pop();
              context.read<LanguageBloc>().add(ToggleLanguageEvent());
            }),


            // 5. خيار حول المدرسة
            _buildListTile(context, Icons.info, "drawer_Profile".tr(context), () {
              context.pop();
              context.push(RouteName.showprofile);
            }),

            // 6. خيار ساعدنا / الدعم الفني
            _buildListTile(context, Icons.help, "drawer_help_us".tr(context), () {
              context.pop();
              context.push(RouteName.helpUs);
            }),

            _buildListTile(context, Icons.rule, "school_rule".tr(context), () {
              context.pop();
              context.push(RouteName.schoolRules);
            }),

            if (showChildOptions && child != null)
              _buildListTile(context, Icons.report_problem, "complaint_name".tr(context), () {
                context.pop();
                context.push(ParentRouteName.childComplaints, extra: child.id);
              }),

            // 7. خيار تسجيل الخروج
            _buildListTile(
              context,
              Icons.logout,
              "drawer_log_out".tr(context),
                  () => showDialog(
                  context: context,
                  builder: (_) => const DrawerLogOutDialogWidget()
              ),
            )
          ]
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context,
      IconData icon,
      String text,
      VoidCallback onTapper,
      {Widget? trailing, Widget? titleWidget}
      ) {
    return ListTile(
      leading: Icon(
          icon,
          color: Theme.of(context).primaryColor
      ),
      title: titleWidget ?? Text(text),
      trailing: trailing,
      onTap: onTapper,
    );
  }
}