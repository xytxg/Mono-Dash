part of 'port_rules_tab.dart';

class _PortRuleActionSheet extends StatelessWidget {
  const _PortRuleActionSheet({
    required this.rule,
    required this.onEdit,
    required this.onToggleStrategy,
    required this.onDelete,
    this.onShowProcess,
  });

  final RuleInfoDto rule;
  final VoidCallback onEdit;
  final VoidCallback onToggleStrategy;
  final VoidCallback onDelete;
  final VoidCallback? onShowProcess;

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
                rule.isAccept ? TablerIcons.plug_connected : TablerIcons.plug_x,
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
                    context.l10n.firewall_portTitle(rule.port ?? '-'),
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
                    '${rule.displayProtocol} · ${rule.displayAddress}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                subtitle: Text(context.l10n.firewall_editPortRuleDescription),
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
                      ? context.l10n.firewall_denyThisPort
                      : context.l10n.firewall_allowThisPort,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onToggleStrategy();
                },
              ),
              if (onShowProcess != null)
                AppActionRow(
                  icon: TablerIcons.activity,
                  iconColor: CupertinoColors.systemTeal,
                  title: context.l10n.firewall_occupiedProcess,
                  subtitle: Text(
                    rule.usedStatus ?? context.l10n.firewall_processDetails,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onShowProcess!();
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
