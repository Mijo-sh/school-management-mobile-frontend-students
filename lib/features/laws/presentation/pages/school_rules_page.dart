import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../manager/school_rules_cubit.dart';

class SchoolRulesPage extends StatelessWidget {
  const SchoolRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return  BlocProvider(
        create: (context) => di<SchoolRulesCubit>()..fetchSchoolRules(),
        child: Scaffold(
          backgroundColor: cs.surface,
          body: Column(
            children: [
              // 🌟 استخدام الهيدر المزخرف الموحد في التطبيق
              const CurvedHeaderBar(
                title: 'قوانين المدرسة والانضباط',
                backgroundImage: 'assets/images/background_login.jpg',
              ),
              Expanded(
                child: BlocBuilder<SchoolRulesCubit, SchoolRulesState>(
                  builder: (context, state) {
                    if (state is SchoolRulesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SchoolRulesError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: cs.error, fontSize: 16),
                        ),
                      );
                    } else if (state is SchoolRulesLoaded) {
                      final rules = state.rules;

                      if (rules.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد قوانين مضافة حالياً',
                            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                        itemCount: rules.length,
                        itemBuilder: (context, index) {
                          final rule = rules[index];
                          final uniformColor = cs.primary;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: uniformColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: uniformColor,
                                    width: 1.8,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // 🌟 استخدام الصورة المطلوبة rules.png داخل دوائر متناسقة مع التطبيق
                                        Container(
                                          width: 55,
                                          height: 55,
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: uniformColor.withOpacity(0.15),
                                          ),
                                          child: Image.asset(
                                            'assets/images/rules.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            rule.title,
                                            style: TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                              color: cs.onSurface,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (rule.description.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        rule.description,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: cs.onSurface.withOpacity(0.75),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}