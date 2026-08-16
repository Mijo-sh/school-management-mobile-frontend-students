// lib/features/complaint/presentation/pages/complaints_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../domain/entities/complaint_entities.dart';
import '../manager/complaint_bloc.dart';
import 'add_complaint_sheet.dart'; // تم تعديل الاستيراد ليوجه للصفحة الكاملة الجديدة

// ══════════ ترجمة/ألوان الخطورة ══════════
String severityLabel(String s) {
  switch (s) {
    case 'high':
      return 'عالية';
    case 'medium':
      return 'متوسطة';
    case 'low':
      return 'منخفضة';
    default:
      return s;
  }
}

Color severityColor(String s, ColorScheme cs) {
  switch (s) {
    case 'high':
      return const Color(0xFFD64545); // أحمر
    case 'medium':
      return const Color(0xFFE08A2C); // برتقالي
    case 'low':
      return const Color(0xFF0F9D55); // أخضر
    default:
      return cs.primary;
  }
}

class ComplaintsPage extends StatelessWidget {
  /// معرّف الطالب (الابن) — يجي من السياق (SelectedChildHolder) عند فتح الصفحة.
  final int studentId;

  const ComplaintsPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<ComplaintBloc>()..add(GetComplaintsEvent(studentId)),
      child: _ComplaintsView(studentId: studentId),
    );
  }
}

class _ComplaintsView extends StatelessWidget {
  final int studentId;
  const _ComplaintsView({required this.studentId});

  // التعديل هنا: فتح صفحة إضافة الشكوى الكاملة بدلاً من الـ BottomSheet
  void _openAddPage(BuildContext context) {
    final bloc = context.read<ComplaintBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddComplaintPage(
          studentId: studentId,
          complaintBloc: bloc,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          const CurvedHeaderBar(
            title: 'الشكاوى',
            backgroundImage: 'assets/images/background_login.jpg',
          ),
          Expanded(
            child: BlocConsumer<ComplaintBloc, ComplaintState>(
              listenWhen: (p, c) =>
              p.submissionStatus != c.submissionStatus ||
                  (c.listStatus == ComplaintStatus.failure &&
                      p.listStatus != c.listStatus),
              listener: (context, state) {
                if (state.submissionStatus == ComplaintStatus.success &&
                    state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message!)),
                  );
                }
                if ((state.submissionStatus == ComplaintStatus.failure ||
                    state.listStatus == ComplaintStatus.failure) &&
                    state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              buildWhen: (p, c) =>
              p.listStatus != c.listStatus || p.complaints != c.complaints,
              builder: (context, state) {
                if (state.listStatus == ComplaintStatus.loading ||
                    state.listStatus == ComplaintStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.listStatus == ComplaintStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 52, color: cs.error),
                          const SizedBox(height: 14),
                          Text(state.message ?? 'حدث خطأ',
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context
                                .read<ComplaintBloc>()
                                .add(GetComplaintsEvent(studentId)),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.complaints.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد شكاوى مقدَّمة',
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.5), fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                  itemCount: state.complaints.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ComplaintCard(complaint: state.complaints[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPage(context), // استدعاء الدالة الصحيحة هنا
        backgroundColor: cs.primary,
        icon: Icon(Icons.add_rounded, color: cs.onPrimary),
        label: Text(
          'إضافة شكوى',
          style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ══════════ كارت الشكوى ══════════
class _ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  const _ComplaintCard({required this.complaint});

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return DateFormat('yyyy/MM/dd').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color accentColor = cs.primary;
    final Color sevColor = severityColor(complaint.type.severity, cs);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor, width: 1.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة + التصنيف العام + شارة الخطورة في الأعلى
            Row(
              children: [
                // صورة الـ Avatar بجانب العنوان العام
                CircleAvatar(
                  radius: 20,
                  backgroundColor: accentColor.withOpacity(0.1),
                  backgroundImage: const AssetImage('assets/images/complaint.png'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    complaint.categoryName,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sevColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    severityLabel(complaint.type.severity),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: sevColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // عنوان الشكوى التفصيلي
            Text(
              complaint.type.title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 10),
            Divider(height: 1, color: accentColor.withOpacity(0.15)),
            const SizedBox(height: 8),

            // التاريخ
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14, color: cs.onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  _formatDate(complaint.createdAt),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}