// guardian_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/widgets/home_drawer_widget.dart';
import '../../../shared/domain/entities/user_role.dart';
import '../../domain/entities/child_card.dart';
import '../manager/guardian_cubit.dart';
import '../widgets/child_card_tile.dart';
import '../widgets/curved_app_bar.dart';
import '../widgets/guardian_empty_view.dart';
import '../widgets/guardian_error_view.dart';

class GuardianPage extends StatelessWidget {
  const GuardianPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
        drawer: HomeDrawerWidget(
          isDark: Theme.of(context).brightness == Brightness.dark,
          role: UserRole.guardian,       // 👈 حسب الدور المناسب عندك
          showChildOptions: false,     // 👈 ما في ابن محدد، فما نعرض خياراته
        ),        body: BlocBuilder<GuardianCubit, GuardianState>(
          builder: (context, state) {
            if (state is GuardianLoading || state is GuardianInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GuardianError) {
              return GuardianErrorView(message: state.message);
            }

            final loaded = state as GuardianLoaded;
            if (loaded.children.isEmpty) {
              return const GuardianEmptyView();
            }

            return _ChildrenList(children: loaded.children);
          },
        ),
    );
  }
}

class _ChildrenList extends StatelessWidget {
  final List<ChildCard> children;
  const _ChildrenList({required this.children});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: CurvedAppBar(title: 'قائمة الأبناء')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 90),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => ChildCardTile(child: children[index]),
              childCount: children.length,
            ),
          ),
        ),
      ],
    );
  }
}