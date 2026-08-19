import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_name.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';

class ReportCardHubPage extends StatelessWidget {
  /// null للطالب نفسه، أو id الابن عند ولي الأمر.
  final int? studentId;

  /// معرّفات الجلاء لكل فصل — بتجيبن من الباك وبتمرّرن هون.
  final int firstTermId;
  final int secondTermId;

  const ReportCardHubPage({
    super.key,
    this.studentId,
    this.firstTermId = 1,
    this.secondTermId = 2,
  });

  void _openReportCard(BuildContext context, int reportCardId) {
    context.push(
      RouteName.reportCard,
      extra: {
        'studentId': studentId,
        'reportCardId': reportCardId,
      },
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
            title: 'الجلاء',
            backgroundImage: 'assets/images/background_login.jpg',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                children: [
                  // 1. كارد الفصل الأول
                  _TermCard(
                    title: 'الفصل الأول',
                    subtitle: 'نتائج وعلامات الفصل الدراسي الأول',
                    imagePath: 'assets/images/semester1.png',        // 👈 بدّلها
                    gradient: const [Color(0xFF5B8DB8), Color(0xFF89C4E1)],
                    onTap: () => _openReportCard(context, firstTermId),
                  ),
                  const SizedBox(height: 14),

                  // 2. كارد الفصل الثاني
                  _TermCard(
                    title: 'الفصل الثاني',
                    subtitle: 'نتائج وعلامات الفصل الدراسي الثاني',
                    imagePath: 'assets/images/semester2.png',        // 👈 بدّلها
                    gradient: const [Color(0xFF8A9E7A), Color(0xFFBDD4AD)],
                    onTap: () => _openReportCard(context, secondTermId),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _TermCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    required this.imagePath,
  });

  @override
  State<_TermCard> createState() => _TermCardState();
}

class _TermCardState extends State<_TermCard> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;
    setState(() => _isLoading = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleTap,
      child: Container(
        width: double.infinity,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.first.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    'assets/images/background_login.jpg',
                    fit: BoxFit.cover,
                    color: Colors.white,
                    colorBlendMode: BlendMode.difference,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          widget.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.85),
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}