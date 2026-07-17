import 'package:flutter/material.dart';
import '../../../../core/injector/injector_container.dart'; // تأكدي من صحة المسار حسب مكان مجلد shared
import '../../../profile/domain/use_cases/get_cached_user_usecase.dart';

class UserHeaderCard extends StatefulWidget {
  final ColorScheme cs;

  final String? overrideName;

  const UserHeaderCard({
    super.key,
    required this.cs,
    this.overrideName,
  });

  @override
  State<UserHeaderCard> createState() => _UserHeaderCardState();
}

class _UserHeaderCardState extends State<UserHeaderCard> {
  late final Future<String> _nameFuture = _loadName();

  Future<String> _loadName() async {
    if (widget.overrideName != null) return widget.overrideName!;

    final result = await di<GetCachedUserUsecase>().call();
    return result.fold(
          (_) => '',
          (user) => user?.fullName ?? '',
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;

    return Container(
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        child: FutureBuilder<String>(
          future: _nameFuture,
          builder: (context, snapshot) {
            final name = snapshot.data ?? '';
            final initials = _initials(name);

            return Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.onPrimary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(
                        color: cs.onPrimary.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      snapshot.connectionState == ConnectionState.waiting ? '...' : name,
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Stack(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.onPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: cs.onPrimary,
                        size: 20,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: cs.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
    );
  }
}