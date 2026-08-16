// lib/features/complaint/presentation/pages/add_complaint_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../domain/entities/complaint_entities.dart';
import '../manager/complaint_bloc.dart';
import 'complaints_page.dart' show severityLabel, severityColor;

class AddComplaintPage extends StatefulWidget {
  final int studentId;
  final ComplaintBloc complaintBloc;

  const AddComplaintPage({
    super.key,
    required this.studentId,
    required this.complaintBloc,
  });

  @override
  State<AddComplaintPage> createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  ComplaintCategory? _selectedCategory;
  ComplaintType? _selectedType; // يبقى نوع الشكوى فارغاً تماماً

  @override
  void initState() {
    super.initState();
    final state = widget.complaintBloc.state;
    if (state.optionsStatus != ComplaintStatus.success) {
      widget.complaintBloc.add(const GetComplaintOptionsEvent());
    } else {
      _initDefaultCategory(state.categories);
    }
  }

  void _initDefaultCategory(List<ComplaintCategory> categories) {
    if (categories.isNotEmpty && _selectedCategory == null) {
      setState(() {
        _selectedCategory = categories.first;
        // _selectedType يبقى فارغاً كما طلبت
      });
    }
  }

  void _submit() {
    if (_selectedType == null) return;
    widget.complaintBloc.add(
      CreateComplaintEvent(
        studentId: widget.studentId,
        complaintTypeId: _selectedType!.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: widget.complaintBloc,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: cs.surface,
          body: BlocConsumer<ComplaintBloc, ComplaintState>(
            listenWhen: (p, c) =>
            p.submissionStatus != c.submissionStatus ||
                p.optionsStatus != c.optionsStatus,
            listener: (context, state) {
              if (state.optionsStatus == ComplaintStatus.success) {
                _initDefaultCategory(state.categories);
              }
              if (state.submissionStatus == ComplaintStatus.success) {
                context.pop();
              }
            },
            builder: (context, state) {
              if (state.optionsStatus == ComplaintStatus.success &&
                  _selectedCategory == null &&
                  state.categories.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _initDefaultCategory(state.categories);
                });
              }

              return Column(
                children: [
                  const CurvedHeaderBar(
                    title: 'إضافة شكوى جديدة',
                    backgroundImage: 'assets/images/background_login.jpg',
                  ),
                  Expanded(
                    child: (state.optionsStatus == ComplaintStatus.loading ||
                        state.optionsStatus == ComplaintStatus.initial)
                        ? const Center(child: CircularProgressIndicator())
                        : state.optionsStatus == ComplaintStatus.failure
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.message ?? 'تعذّر تحميل الخيارات',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => context
                                  .read<ComplaintBloc>()
                                  .add(const GetComplaintOptionsEvent()),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    )
                        : ListView(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                      children: [
                        // 1) اختيار التصنيف (يختار الأول افتراضياً)
                        Text(
                          'التصنيف',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _CategoryDropdown(
                          categories: state.categories,
                          selected: _selectedCategory,
                          onChanged: (cat) {
                            setState(() {
                              _selectedCategory = cat;
                              _selectedType = null; // إعادة تعيين النوع ليصبح فارغاً عند تغيير التصنيف
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // 2) اختيار النوع (يبدأ فارغاً ولا يتم اختيار أي خيار تلقائياً)
                        if (_selectedCategory != null) ...[
                          Text(
                            'نوع الشكوى',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._selectedCategory!.types.map((type) {
                            final selected =
                                _selectedType?.id == type.id;
                            final sevColor =
                            severityColor(type.severity, cs);
                            return GestureDetector(
                              onTap: () => setState(
                                      () => _selectedType = type),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cs.primary.withOpacity(0.06),
                                  borderRadius:
                                  BorderRadius.circular(22),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerLowest,
                                    borderRadius:
                                    BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selected
                                          ? cs.primary
                                          : cs.primary.withOpacity(0.2),
                                      width: selected ? 1.6 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        size: 20,
                                        color: selected
                                            ? cs.primary
                                            : cs.onSurface
                                            .withOpacity(0.4),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          type.title,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight:
                                            FontWeight.w600,
                                            color: cs.onSurface,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 10,
                                            vertical: 4),
                                        decoration: BoxDecoration(
                                          color: sevColor
                                              .withOpacity(0.12),
                                          borderRadius:
                                          BorderRadius.circular(
                                              10),
                                        ),
                                        child: Text(
                                          severityLabel(type.severity),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight:
                                            FontWeight.w700,
                                            color: sevColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 20),

                        // زر الإرسال
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: (_selectedType == null ||
                                state.submissionStatus ==
                                    ComplaintStatus.loading)
                                ? null
                                : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.primary,
                              disabledBackgroundColor:
                              cs.onSurface.withOpacity(0.12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                            child: state.submissionStatus ==
                                ComplaintStatus.loading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                                : const Text(
                              'إرسال الشكوى',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ══════════ دروبداون التصنيف ══════════
class _CategoryDropdown extends StatelessWidget {
  final List<ComplaintCategory> categories;
  final ComplaintCategory? selected;
  final ValueChanged<ComplaintCategory?> onChanged;

  const _CategoryDropdown({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = cs.primary;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor, width: 1.6),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ComplaintCategory>(
            value: selected,
            isExpanded: true,
            hint: const Text('اختر التصنيف'),
            items: categories.map((cat) {
              return DropdownMenuItem<ComplaintCategory>(
                value: cat,
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}