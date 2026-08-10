import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/unified_bubble_tile.dart';
import '../../domain/entities/study_material.dart';
import 'material_downloader.dart';
import 'material_file_service.dart';

class MaterialCard extends StatefulWidget {
  final StudyMaterial material;
  const MaterialCard({super.key, required this.material});

  @override
  State<MaterialCard> createState() => _MaterialCardState();
}

class _MaterialCardState extends State<MaterialCard> {
  bool _isOpening = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;

  String get _fileName {
    final m = widget.material;
    return '${m.title}.${m.fileExtension ?? 'file'}';
  }

  Future<void> _handleOpen() async {
    final m = widget.material;

    if (m.isLink) {
      if (m.linkUrl == null) return;
      final uri = Uri.parse(m.linkUrl!);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        _snack('تعذّر فتح الرابط');
      }
      return;
    }

    if (_isOpening) return;
    setState(() => _isOpening = true);
    final result = await di<MaterialFileService>().openFile(
      materialId: m.id,
      fileName: _fileName,
    );
    if (!mounted) return;
    setState(() => _isOpening = false);
    if (!result.success) _snack(result.error ?? 'تعذّر فتح الملف');
  }

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });
    final result = await di<MaterialDownloader>().download(
      materialId: widget.material.id,
      fileName: _fileName,
      onProgress: (p) {
        if (mounted) setState(() => _downloadProgress = p);
      },
    );
    if (!mounted) return;
    setState(() => _isDownloading = false);
    if (result.success) {
      _snack('تم تنزيل الملف في مجلد التنزيلات', success: true);
    } else {
      _snack(result.error ?? 'تعذّر التنزيل');
    }
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? const Color(0xFF0F9D55) : Colors.red,
      ),
    );
  }

  String _fileSizeLabel(int? kb) {
    if (kb == null) return '';
    if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(1)} MB';
    return '$kb KB';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m = widget.material;

    final leadingIcon = Container(
      width: 45,
      height: 45,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary.withOpacity(0.12),
      ),
      child: Image.asset(
        'assets/images/file.png',
        errorBuilder: (_, __, ___) => Icon(
          m.isLink ? Icons.link_rounded : Icons.description_rounded,
          color: cs.primary,
          size: 22,
        ),
      ),
    );

    final chips = <Widget>[
      if (m.isFile && m.fileExtension != null)
        _infoChip(cs, m.fileExtension!.toUpperCase()),
      if (m.isFile && m.fileSizeKb != null)
        _infoChip(cs, _fileSizeLabel(m.fileSizeKb)),
    ];

    // الأزرار — تظهر جوّا الفقاعة عبر bottomActions
    Widget? actions;
    if (m.isFile) {
      actions = Row(
        children: [
          Expanded(
            child: _actionButton(
              cs,
              icon: Icons.visibility_rounded,
              label: 'فتح',
              loading: _isOpening,
              onTap: _handleOpen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _actionButton(
              cs,
              icon: Icons.download_rounded,
              label: _isDownloading
                  ? 'جارٍ ${_downloadProgress.toInt()}%'
                  : 'تنزيل',
              loading: _isDownloading,
              onTap: _handleDownload,
            ),
          ),
        ],
      );
    } else if (m.isLink) {
      actions = Row(
        children: [
          Expanded(
            child: _actionButton(
              cs,
              icon: Icons.open_in_new_rounded,
              label: 'فتح الرابط',
              loading: false,
              onTap: _handleOpen,
            ),
          ),
          const Spacer(), // الزر بنص العرض
        ],
      );
    }

    String _timeLabel(DateTime date) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour < 12 ? 'ص' : 'م';
      return '$hour:$minute $period';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: UnifiedBubbleTile(
        title: m.title,
        description: m.description,
        timeLabel: _timeLabel(m.createdAt),   // ← بدل ''
        isUnread: !m.isRead,
        leadingIcon: leadingIcon,
        detailsChips: chips,
        bottomActions: actions,
      ),
    );
  }

  Widget _infoChip(ColorScheme cs, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          color: cs.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButton(
      ColorScheme cs, {
        required IconData icon,
        required String label,
        required bool loading,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            )
                : Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}