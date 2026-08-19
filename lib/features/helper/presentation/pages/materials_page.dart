import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/date_divider_chip.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../manager/materials_cubit.dart';
import '../widgets/material_card.dart';

class MaterialsPage extends StatelessWidget {
  final int? studentId;

  const MaterialsPage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<MaterialsCubit>()..loadMaterials(),
      child: const _MaterialsView(),
    );
  }
}

class _MaterialsView extends StatefulWidget {
  const _MaterialsView();

  @override
  State<_MaterialsView> createState() => _MaterialsViewState();
}

class _MaterialsViewState extends State<_MaterialsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MaterialsCubit>().loadNextPage();
    }
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return  Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            const CurvedHeaderBar(
              title: 'الملفات المساعدة',
              backgroundImage: 'assets/images/background_login.jpg',
            ),
            Expanded(
              child: BlocBuilder<MaterialsCubit, MaterialsState>(
                builder: (context, state) {
                  if (state is MaterialsLoading || state is MaterialsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MaterialsError) {
                    return UnifiedErrorView(
                      message: state.message,
                      onRetry: () =>
                          context.read<MaterialsCubit>().loadMaterials(),
                    );
                  }

                  final loaded = state as MaterialsLoaded;
                  final sorted = [...loaded.items]
                    ..sort((a, b) {
                      final timeCompare = a.createdAt.compareTo(b.createdAt);
                      if (timeCompare != 0) return timeCompare;
                      return a.id.compareTo(b.id);
                    });
                  final displayList = sorted.reversed.toList();

                  if (displayList.isEmpty) {
                    return const UnifiedEmptyView(
                      icon: Icons.folder_off_rounded,
                      message: 'ما في ملفات حاليًا',
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                    itemCount: displayList.length + (loaded.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayList.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final item = displayList[index];

                      final showDateLabel = index == displayList.length - 1 ||
                          _dateLabel(displayList[index + 1].createdAt) !=
                              _dateLabel(item.createdAt);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateLabel)
                            DateDividerChip(label: _dateLabel(item.createdAt)),
                          MaterialCard(material: item),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
