import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import 'port_rules_tab.dart';

class FirewallPortMultiSelectBar extends StatelessWidget {
  const FirewallPortMultiSelectBar({
    super.key,
    required this.controller,
    this.isSheetHeader = false,
  });

  final PortRulesTabController controller;
  final bool isSheetHeader;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final selectedCount = controller.selectedCount;
        if (!isSheetHeader &&
            (!controller.selectionMode || selectedCount == 0)) {
          return const SizedBox.shrink();
        }

        final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
        final borderRadius = BorderRadius.circular(24);
        final bar = ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.secondaryBackground(
                        context,
                      ).withValues(alpha: 0.7)
                    : CupertinoColors.white.withValues(alpha: 0.8),
                borderRadius: borderRadius,
                border: Border.all(
                  color: isDark
                      ? CupertinoColors.white.withValues(alpha: 0.1)
                      : CupertinoColors.black.withValues(alpha: 0.05),
                  width: 0.5,
                ),
                boxShadow: isSheetHeader
                    ? null
                    : [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(
                            alpha: isDark ? 0.4 : 0.08,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  const Icon(
                    TablerIcons.checkbox,
                    color: CupertinoColors.activeBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.firewall_selectedRules(selectedCount),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          isSheetHeader
                              ? context.l10n.firewall_chooseAction
                              : context.l10n.firewall_expandActionMenu,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryLabel(
                              context,
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: controller.totalCount == 0
                            ? null
                            : () {
                                if (selectedCount == controller.totalCount) {
                                  controller.clearSelection();
                                } else {
                                  controller.selectAll();
                                }
                              },
                        child: Text(
                          selectedCount == controller.totalCount
                              ? context.l10n.firewall_clearSelectAll
                              : context.l10n.firewall_selectAll,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: () {
                          if (isSheetHeader) Navigator.of(context).pop();
                          controller.clearSelection();
                        },
                        child: Text(
                          context.l10n.common_cancel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        if (isSheetHeader) return bar;

        return Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 40 * (1 - value)),
                  child: Opacity(opacity: value.clamp(0, 1), child: child),
                );
              },
              child: GestureDetector(
                onTap: () => _showMultiActions(context),
                child: bar,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMultiActions(BuildContext context) {
    showActionSheet<void>(
      context: context,
      builder: (context) => ActionSheetScaffold(
        isAdaptive: true,
        showHandle: false,
        isFloating: false,
        header: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: FirewallPortMultiSelectBar(
            controller: controller,
            isSheetHeader: true,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _ActionItem(
                icon: TablerIcons.file_export,
                label: controller.exporting
                    ? context.l10n.firewall_exporting
                    : context.l10n.firewall_export,
                enabled: !controller.exporting,
                onTap: controller.exportSelected,
              ),
              _divider(context),
              _ActionItem(
                icon: TablerIcons.trash,
                label: context.l10n.common_delete,
                isDestructive: true,
                onTap: controller.deleteSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 54),
      child: Container(
        height: 0.5,
        color: AppColors.separator(context).withValues(alpha: 0.1),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? CupertinoColors.systemRed
        : AppColors.label(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: enabled
          ? () {
              Navigator.pop(context);
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      (isDestructive
                              ? CupertinoColors.systemRed
                              : CupertinoColors.activeBlue)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isDestructive
                      ? CupertinoColors.systemRed
                      : CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: AppColors.tertiaryLabel(context).withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
