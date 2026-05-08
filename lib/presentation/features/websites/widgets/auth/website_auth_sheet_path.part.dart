part of '../website_auth_sheet.dart';

class _PathAuthTab extends ConsumerWidget {
  const _PathAuthTab({required this.websiteId, required this.items});

  final int websiteId;
  final List<WebsitePathAuthItemDto> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return _EmptyTabState(
        icon: TablerIcons.folder,
        title: context.l10n.websites_noPathAccessLimits,
        subtitle: context.l10n.websites_addPathAccessHint,
      );
    }

    return Column(
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (index > 0) const SizedBox(height: 10),
              _PathAuthCard(
                item: item,
                onEdit: () => _openPathEditor(context, ref, item),
                onDelete: () => _deletePathAuth(context, ref, item),
              ),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _openPathEditor(
    BuildContext context,
    WidgetRef ref,
    WebsitePathAuthItemDto? item,
  ) async {
    await showWebsiteAuthFormSheet(
      context,
      websiteId: websiteId,
      scope: 'path',
      initialPathAccount: item,
    );
    ref.read(websitePathAuthControllerProvider(websiteId).notifier).refresh();
  }

  Future<void> _deletePathAuth(
    BuildContext context,
    WidgetRef ref,
    WebsitePathAuthItemDto item,
  ) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(context.l10n.websites_deletePathAccess),
        content: Text(context.l10n.websites_deletePathAccessConfirm(item.path)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.common_cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(websitePathAuthControllerProvider(websiteId).notifier)
            .deletePathAuth(
              path: item.path,
              name: item.name,
              username: item.username,
              remark: item.remark,
            );
        if (context.mounted) {
          showAppSuccessToast(context.l10n.websites_pathAccessDeleted);
        }
      } catch (e) {
        if (context.mounted) {
          showAppErrorToast(
            context.l10n.websites_deleteFailed,
            description: '$e',
          );
        }
      }
    }
  }
}

class _PathAuthCard extends StatelessWidget {
  const _PathAuthCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final WebsitePathAuthItemDto item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemPurple
                      .resolveFrom(context)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  TablerIcons.lock,
                  size: 16,
                  color: CupertinoColors.systemPurple.resolveFrom(context),
                ),
              ),
              const SizedBox(width: 10),
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
              _SmallActionBtn(
                icon: TablerIcons.pencil,
                color: CupertinoColors.activeBlue.resolveFrom(context),
                onPressed: onEdit,
              ),
              const SizedBox(width: 8),
              _SmallActionBtn(
                icon: TablerIcons.trash,
                color: CupertinoColors.systemRed.resolveFrom(context),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RefinedInfoLine(
            icon: TablerIcons.route,
            label: context.l10n.websites_protectedPath,
            value: item.path,
            valueColor: CupertinoColors.activeBlue.resolveFrom(context),
          ),
          const SizedBox(height: 8),
          _RefinedInfoLine(
            icon: TablerIcons.user,
            label: context.l10n.websites_authorizedAccount,
            value: item.username,
          ),
          if (item.remark.isNotEmpty) ...[
            const SizedBox(height: 8),
            _RefinedInfoLine(
              icon: TablerIcons.note,
              label: context.l10n.websites_remarkDescription,
              value: item.remark,
            ),
          ],
        ],
      ),
    );
  }
}

class _RefinedInfoLine extends StatelessWidget {
  const _RefinedInfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppColors.tertiaryLabel(context)),
        const SizedBox(width: 8),
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.label(context),
            ),
          ),
        ),
      ],
    );
  }
}
