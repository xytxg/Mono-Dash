import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/firewall/rule_info_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/skeleton_item.dart';
import '../providers/firewall_provider.dart';
import 'ip_rule_form_sheet.dart';

part 'ip_rules_tab_widgets.dart';

class IpRulesTab extends ConsumerWidget {
  const IpRulesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(firewallIpRulesControllerProvider);

    return state.when(
      loading: () => _buildLoading(context),
      error: (e, _) => _buildError(context, ref, e),
      data: (data) {
        if (data.rules.isEmpty) {
          return _buildEmpty(context, ref);
        }
        return _buildList(context, ref, data.rules);
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.separator(context).withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const SkeletonItem.text(
                      width: 30,
                      height: 30,
                      borderRadius: 9,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonItem.text(
                            width: 142 + (i % 2) * 28,
                            height: 18,
                          ),
                          const SizedBox(height: 7),
                          SkeletonItem.text(
                            width: 96 + (i % 3) * 22,
                            height: 11,
                          ),
                        ],
                      ),
                    ),
                    const SkeletonItem.text(
                      width: 54,
                      height: 22,
                      borderRadius: 8,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    height: 0.5,
                    color: AppColors.separator(context).withValues(alpha: 0.1),
                  ),
                ),
                const SkeletonItem.text(width: double.infinity, height: 12),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: AppEmptyState(
        icon: TablerIcons.alert_circle,
        title: context.l10n.common_loadingFailed,
        subtitle: error.toString(),
        actionLabel: context.l10n.common_retry,
        onAction: () => ref.invalidate(firewallIpRulesControllerProvider),
        useCardStyle: false,
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: AppEmptyState(
        icon: TablerIcons.shield_off,
        title: context.l10n.firewall_noIpRules,
        subtitle: context.l10n.firewall_noIpRulesSubtitle,
        actionLabel: context.l10n.common_refresh,
        onAction: () => ref.invalidate(firewallIpRulesControllerProvider),
        useCardStyle: false,
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<RuleInfoDto> rules,
  ) {
    return Column(
      children: rules.map((rule) {
        return _IpRuleCard(
          rule: rule,
          onTap: () => _showRuleActions(context, ref, rule),
        );
      }).toList(),
    );
  }

  void _showRuleActions(BuildContext context, WidgetRef ref, RuleInfoDto rule) {
    showActionSheet<void>(
      context: context,
      builder: (_) => _IpRuleActionSheet(
        rule: rule,
        onEdit: () => _editRule(context, ref, rule),
        onToggleStrategy: () => _toggleStrategy(context, ref, rule),
        onDelete: () => _deleteRule(context, ref, rule),
      ),
    );
  }

  Future<void> _editRule(
    BuildContext context,
    WidgetRef ref,
    RuleInfoDto rule,
  ) async {
    await showIpRuleFormSheet(context, existingRule: rule);
  }

  Future<void> _toggleStrategy(
    BuildContext context,
    WidgetRef ref,
    RuleInfoDto rule,
  ) async {
    final l10n = context.l10n;
    final next = rule.isAccept ? 'drop' : 'accept';
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: l10n.firewall_switchStrategyTitle,
        content: l10n.firewall_switchIpStrategyContent(
          rule.displayAddress,
          next.toUpperCase(),
        ),
        confirmText: l10n.firewall_switchAction,
        confirmColor: next == 'accept'
            ? CupertinoColors.systemGreen
            : CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(firewallIpRulesControllerProvider.notifier)
          .updateRule(
            oldRule: {
              'operation': 'remove',
              'address': rule.address,
              'strategy': rule.strategy,
              'description': rule.description ?? '',
            },
            newRule: {
              'operation': 'add',
              'address': rule.address,
              'strategy': next,
              'description': rule.description ?? '',
            },
          );
      showAppSuccessToast(l10n.firewall_strategyUpdated);
    } catch (e) {
      showAppErrorToast(l10n.firewall_strategyUpdateFailed, description: '$e');
    }
  }

  Future<void> _deleteRule(
    BuildContext context,
    WidgetRef ref,
    RuleInfoDto rule,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: l10n.firewall_deleteIpRule,
        content: l10n.firewall_deleteIpRuleContent(rule.displayAddress),
        confirmText: l10n.common_delete,
        confirmColor: CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(firewallIpRulesControllerProvider.notifier).removeRule({
        'operation': 'remove',
        'address': rule.address,
        'strategy': rule.strategy,
        'description': rule.description ?? '',
      });
      showAppSuccessToast(l10n.firewall_ruleDeleted);
    } catch (e) {
      showAppErrorToast(l10n.firewall_deleteFailed, description: '$e');
    }
  }
}
