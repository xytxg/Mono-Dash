import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/app_theme.dart';
import 'frosted_scaffold.dart';

/// 可复用的子菜单页面组件。
///
/// 用于展示分组菜单列表，每组包含若干可点击的菜单项。
class SubMenuPage extends StatelessWidget {
  const SubMenuPage({super.key, required this.title, required this.sections});

  final String title;
  final List<SubMenuSection> sections;

  @override
  Widget build(BuildContext context) {
    return FrostedScaffold(
      title: title,
      body: CustomScrollView(
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
                ...sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  return Column(
                    children: [
                      SubMenuCard(
                        title: section.title ?? '',
                        children: section.items.map((item) {
                          return SubMenuRow(
                            icon: item.icon,
                            iconColor: item.iconColor ?? CupertinoColors.activeBlue,
                            title: item.title,
                            subtitle: item.subtitle ?? '',
                            onTap: item.onTap ?? () {},
                          );
                        }).toList(),
                      ),
                      if (index < sections.length - 1)
                        const SizedBox(height: 12),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 子菜单分组。
class SubMenuSection {
  const SubMenuSection({this.title, required this.items});
  final String? title;
  final List<SubMenuItem> items;
}

/// 子菜单项。
class SubMenuItem {
  const SubMenuItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
}

/// 分组卡片容器。
class SubMenuCard extends StatelessWidget {
  const SubMenuCard({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.separator(context).withValues(alpha: 0.16),
              width: 0.5,
            ),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              if (index == children.length - 1) return child;
              return Column(
                children: [
                  child,
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Container(
                      height: 0.5,
                      color: AppColors.separator(
                        context,
                      ).withValues(alpha: 0.24),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// 菜单行组件。
class SubMenuRow extends StatelessWidget {
  const SubMenuRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(iconColor, context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label(context),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLabel(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              TablerIcons.chevron_right,
              size: 15,
              color: AppColors.tertiaryLabel(context),
            ),
          ],
        ),
      ),
    );
  }
}
