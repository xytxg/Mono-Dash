part of 'ip_rules_tab.dart';

class _IpRuleActionSheet extends StatelessWidget {
  const _IpRuleActionSheet({
    required this.rule,
    required this.onEdit,
    required this.onToggleStrategy,
    required this.onDelete,
  });

  final RuleInfoDto rule;
  final VoidCallback onEdit;
  final VoidCallback onToggleStrategy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final strategyColor = rule.isAccept
        ? CupertinoColors.systemGreen
        : CupertinoColors.systemRed;
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: strategyColor
                    .resolveFrom(context)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                rule.isAccept ? TablerIcons.shield_check : TablerIcons.shield_x,
                size: 19,
                color: strategyColor.resolveFrom(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.displayAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.label(context),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rule.isAccept
                        ? context.l10n.firewall_acceptLabel
                        : context.l10n.firewall_dropLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSectionHeader(
            title: context.l10n.firewall_ruleManagement,
            icon: TablerIcons.settings,
          ),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.edit,
                iconColor: CupertinoColors.systemBlue,
                title: context.l10n.firewall_editRule,
                subtitle: Text(context.l10n.firewall_editIpRuleDescription),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              AppActionRow(
                icon: rule.isAccept
                    ? TablerIcons.shield_x
                    : TablerIcons.shield_check,
                iconColor: rule.isAccept
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGreen,
                title: rule.isAccept
                    ? context.l10n.firewall_changeToDrop
                    : context.l10n.firewall_changeToAccept,
                subtitle: Text(
                  rule.isAccept
                      ? context.l10n.firewall_denyThisAddress
                      : context.l10n.firewall_allowThisAddress,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onToggleStrategy();
                },
              ),
            ],
          ),
          const SizedBox(height: 22),
          AppSectionHeader(
            title: context.l10n.runtime_dangerZone,
            icon: TablerIcons.alert_triangle,
          ),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.trash,
                iconColor: CupertinoColors.systemRed,
                title: context.l10n.firewall_deleteRule,
                subtitle: Text(context.l10n.firewall_removeThisRule),
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IpRuleCard extends StatelessWidget {
  const _IpRuleCard({required this.rule, required this.onTap});

  final RuleInfoDto rule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strategyColor = rule.isAccept
        ? CupertinoColors.systemGreen
        : CupertinoColors.systemRed;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      pressedOpacity: 0.9,
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.14),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: strategyColor
                        .resolveFrom(context)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    rule.isAccept
                        ? TablerIcons.shield_check
                        : TablerIcons.shield_x,
                    size: 18,
                    color: strategyColor.resolveFrom(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.displayAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label(context),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                  ),
                ),
                _StrategyChip(
                  label: rule.isAccept ? 'Accept' : 'Drop',
                  color: strategyColor,
                ),
                const SizedBox(width: 8),
                Icon(
                  TablerIcons.chevron_right,
                  size: 16,
                  color: AppColors.tertiaryLabel(context),
                ),
              ],
            ),
            if ((rule.description ?? '').isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  height: 0.5,
                  color: AppColors.separator(context).withValues(alpha: 0.1),
                ),
              ),
              Row(
                children: [
                  Icon(
                    TablerIcons.file_text,
                    size: 15,
                    color: AppColors.tertiaryLabel(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.common_description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryLabel(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rule.description!,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.label(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StrategyChip extends StatelessWidget {
  const _StrategyChip({required this.label, required this.color});

  final String label;
  final CupertinoDynamicColor color;

  @override
  Widget build(BuildContext context) {
    final resolved = color.resolveFrom(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: resolved.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: resolved,
        ),
      ),
    );
  }
}
