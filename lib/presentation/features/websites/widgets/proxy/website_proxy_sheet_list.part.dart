part of '../website_proxy_sheet.dart';

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onAdd});
  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CupertinoColors.systemPurple
                  .resolveFrom(context)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              TablerIcons.route,
              size: 22,
              color: CupertinoColors.systemPurple.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.websites_reverseProxy,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
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
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            onPressed: onAdd,
            child: Icon(
              TablerIcons.plus,
              size: 22,
              color: CupertinoColors.activeBlue.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProxyList extends StatelessWidget {
  const _ProxyList({
    required this.websiteId,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    required this.onViewSource,
  });

  final int websiteId;
  final List<WebsiteProxyDto> items;
  final VoidCallback onAdd;
  final ValueChanged<WebsiteProxyDto> onEdit;
  final ValueChanged<WebsiteProxyDto> onDelete;
  final ValueChanged<WebsiteProxyDto> onToggleStatus;
  final ValueChanged<WebsiteProxyDto> onViewSource;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(onAdd: onAdd);
    }
    return Column(
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (index > 0) const SizedBox(height: 10),
              _ProxyCard(
                item: item,
                onToggleStatus: () => onToggleStatus(item),
                onEdit: () => onEdit(item),
                onDelete: () => onDelete(item),
                onViewSource: () => onViewSource(item),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _ProxyCard extends StatelessWidget {
  const _ProxyCard({
    required this.item,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
    required this.onViewSource,
  });

  final WebsiteProxyDto item;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewSource;

  @override
  Widget build(BuildContext context) {
    final statusColor = item.enable
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemGrey.resolveFrom(context);
    final cacheParts = <String>[];
    cacheParts.add(
      context.l10n.websites_cacheValue(
        context.l10n.websites_serverCache,
        item.serverCacheTime > 0
            ? '${item.serverCacheTime}${item.serverCacheUnit}'
            : context.l10n.websites_disabled,
      ),
    );
    cacheParts.add(
      context.l10n.websites_cacheValue(
        context.l10n.websites_browserCache,
        item.cache
            ? '${item.cacheTime}${item.cacheUnit}'
            : context.l10n.websites_disabled,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.enable
                      ? context.l10n.websites_enable
                      : context.l10n.websites_disable,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _InfoLine(
            label: context.l10n.websites_frontendPath,
            value:
                '${item.modifier.isEmpty ? '' : '${item.modifier} '}${item.match}',
          ),
          const SizedBox(height: 4),
          _InfoLine(
            label: context.l10n.websites_backendAddress,
            value: item.proxyPass,
          ),
          const SizedBox(height: 4),
          _InfoLine(
            label: context.l10n.websites_cache,
            value: cacheParts.join(', '),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniActionButton(
                label: item.enable
                    ? context.l10n.websites_disable
                    : context.l10n.websites_enable,
                icon: item.enable
                    ? TablerIcons.player_pause
                    : TablerIcons.player_play,
                color: item.enable
                    ? CupertinoColors.systemOrange.resolveFrom(context)
                    : CupertinoColors.systemGreen.resolveFrom(context),
                onPressed: onToggleStatus,
              ),
              const SizedBox(width: 8),
              _MiniActionButton(
                label: context.l10n.websites_sourceContent,
                icon: TablerIcons.file_text,
                color: CupertinoColors.systemGrey.resolveFrom(context),
                onPressed: onViewSource,
              ),
              const SizedBox(width: 8),
              _MiniActionButton(
                label: context.l10n.common_edit,
                icon: TablerIcons.pencil,
                color: CupertinoColors.activeBlue.resolveFrom(context),
                onPressed: onEdit,
              ),
              const SizedBox(width: 8),
              _MiniActionButton(
                label: context.l10n.common_delete,
                icon: TablerIcons.trash,
                color: CupertinoColors.systemRed.resolveFrom(context),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: AppColors.label(context)),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: TablerIcons.route_off,
      title: context.l10n.websites_noReverseProxy,
      subtitle: context.l10n.websites_createReverseProxyHint,
      actionLabel: context.l10n.websites_createNow,
      onAction: onAdd,
    );
  }
}
