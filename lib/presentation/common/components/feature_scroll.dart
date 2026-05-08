import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/l10n_x.dart';
import 'frosted_scaffold.dart';
import 'mini_button.dart';

class FeatureScroll extends StatelessWidget {
  const FeatureScroll({super.key, required this.children, this.onRefresh});

  final List<Widget> children;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: FrostedScaffold.contentTopPadding(context) + 8,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 132),
          sliver: SliverList.list(
            children: [
              if (onRefresh != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: MiniButton(
                    label: context.l10n.common_refresh,
                    icon: TablerIcons.refresh,
                    onTap: onRefresh!,
                  ),
                ),
              if (onRefresh != null) const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ],
    );
  }
}
