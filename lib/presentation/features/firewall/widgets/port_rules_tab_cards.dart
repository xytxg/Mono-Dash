part of 'port_rules_tab.dart';

class _PortRuleCard extends StatelessWidget {
  const _PortRuleCard({
    required this.rule,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onSelect,
    required this.onProcessTap,
  });

  final RuleInfoDto rule;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final VoidCallback? onProcessTap;

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
            color: selected
                ? CupertinoColors.activeBlue
                      .resolveFrom(context)
                      .withValues(alpha: 0.45)
                : AppColors.separator(context).withValues(alpha: 0.14),
            width: selected ? 1 : 0.5,
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
                        ? TablerIcons.plug_connected
                        : TablerIcons.plug_x,
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
                        rule.port ?? '-',
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
                if (selectionMode) ...[
                  const SizedBox(width: 10),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: onSelect,
                    child: Icon(
                      selected
                          ? TablerIcons.circle_check_filled
                          : TablerIcons.circle,
                      size: 23,
                      color: selected
                          ? CupertinoColors.activeBlue.resolveFrom(context)
                          : AppColors.tertiaryLabel(context),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Icon(
                    TablerIcons.dots_vertical,
                    size: 18,
                    color: AppColors.tertiaryLabel(context),
                  ),
                ],
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                height: 0.5,
                color: AppColors.separator(context).withValues(alpha: 0.1),
              ),
            ),
            _RuleInfoLine(
              icon: TablerIcons.protocol,
              label: context.l10n.firewall_protocolLabel,
              value: rule.displayProtocol,
            ),
            const SizedBox(height: 8),
            _RuleInfoLine(
              icon: TablerIcons.world,
              label: context.l10n.firewall_sourceLabel,
              value: rule.displayAddress,
            ),
            if ((rule.usedStatus ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              _RuleInfoLine(
                icon: TablerIcons.activity,
                label: context.l10n.firewall_occupiedLabel,
                value: rule.usedStatus!,
                valueColor: CupertinoColors.systemGreen.resolveFrom(context),
                onTap: onProcessTap,
              ),
            ],
            if ((rule.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              _RuleInfoLine(
                icon: TablerIcons.file_text,
                label: context.l10n.firewall_descriptionLabel,
                value: rule.description!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RuleInfoLine extends StatelessWidget {
  const _RuleInfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(icon, size: 15, color: AppColors.tertiaryLabel(context)),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.secondaryLabel(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.label(context),
            ),
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 6),
          Icon(
            TablerIcons.chevron_right,
            size: 14,
            color: AppColors.tertiaryLabel(context),
          ),
        ],
      ],
    );

    if (onTap == null) return content;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: content,
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
