part of '../website_redirect_sheet.dart';

class _RedirectList extends StatelessWidget {
  const _RedirectList({
    required this.websiteId,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    required this.onViewSource,
  });

  final int websiteId;
  final List<WebsiteRedirectDto> items;
  final VoidCallback onAdd;
  final ValueChanged<WebsiteRedirectDto> onEdit;
  final ValueChanged<WebsiteRedirectDto> onDelete;
  final ValueChanged<WebsiteRedirectDto> onToggleStatus;
  final ValueChanged<WebsiteRedirectDto> onViewSource;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppEmptyState(
        icon: TablerIcons.arrow_forward_up,
        title: context.l10n.websites_noRedirectRules,
        subtitle: context.l10n.websites_addRedirectRuleHint,
        padding: const EdgeInsets.symmetric(vertical: 64),
        onAction: onAdd,
        actionLabel: context.l10n.websites_addNow,
      );
    }

    return Column(
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (index > 0) const SizedBox(height: 12),
              _RedirectCard(
                item: item,
                onEdit: () => onEdit(item),
                onDelete: () => onDelete(item),
                onToggleStatus: () => onToggleStatus(item),
                onViewSource: () => onViewSource(item),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _RedirectCard extends StatelessWidget {
  const _RedirectCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    required this.onViewSource,
  });

  final WebsiteRedirectDto item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;
  final VoidCallback onViewSource;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.label(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _Tag(
                            text: item.redirect == '301' ? '301' : '302',
                            color: item.redirect == '301'
                                ? CupertinoColors.systemOrange
                                : CupertinoColors.systemBlue,
                          ),
                          const SizedBox(width: 4),
                          _Tag(
                            text: item.type == 'domain'
                                ? context.l10n.websites_domain
                                : (item.type == 'path'
                                      ? context.l10n.websites_path
                                      : '404'),
                            color: AppColors.secondaryLabel(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        label: context.l10n.websites_targetAddress,
                        value: item.target,
                        isUrl: true,
                      ),
                      if (item.domains.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _InfoRow(
                          label: context.l10n.websites_scopeDomains,
                          value: item.domains.join(', '),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.separator(context).withValues(alpha: 0.1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: item.enable
                        ? TablerIcons.player_pause
                        : TablerIcons.player_play,
                    label: item.enable
                        ? context.l10n.websites_disable
                        : context.l10n.websites_enable,
                    color: item.enable
                        ? CupertinoColors.systemOrange
                        : CupertinoColors.activeGreen,
                    onPressed: onToggleStatus,
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: TablerIcons.edit,
                    label: context.l10n.common_edit,
                    onPressed: onEdit,
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: TablerIcons.code,
                    label: context.l10n.websites_sourceContent,
                    onPressed: onViewSource,
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: TablerIcons.trash,
                    label: context.l10n.common_delete,
                    color: CupertinoColors.destructiveRed,
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isUrl = false,
  });
  final String label;
  final String value;
  final bool isUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.tertiaryLabel(context),
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isUrl
                  ? CupertinoColors.activeBlue.resolveFrom(context)
                  : AppColors.label(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.secondaryLabel(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(36, 36),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: effectiveColor),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

class Divider extends StatelessWidget {
  const Divider({super.key, this.height, this.thickness, this.color});
  final double? height;
  final double? thickness;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Container(height: thickness, color: color),
      ),
    );
  }
}
