part of '../website_auth_sheet.dart';

class _GlobalAuthTab extends ConsumerWidget {
  const _GlobalAuthTab({required this.websiteId, required this.auth});

  final int websiteId;
  final WebsiteAuthDto auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = auth.items ?? [];

    if (items.isEmpty) {
      return _EmptyTabState(
        icon: TablerIcons.user,
        title: context.l10n.websites_noAuthAccounts,
        subtitle: context.l10n.websites_addGlobalAuthHint,
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
              _AuthAccountCard(
                username: item.username,
                remark: item.remark,
                onEdit: () => _openGlobalEditor(context, ref, item),
                onDelete: () => _deleteAccount(context, ref, item.username),
              ),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _openGlobalEditor(
    BuildContext context,
    WidgetRef ref,
    WebsiteAuthItemDto? item,
  ) async {
    await showWebsiteAuthFormSheet(
      context,
      websiteId: websiteId,
      scope: 'root',
      initialAccount: item,
    );
    ref.read(websiteAuthControllerProvider(websiteId).notifier).refresh();
  }

  Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    String username,
  ) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(context.l10n.websites_deleteAccount),
        content: Text(context.l10n.websites_deleteAuthAccountConfirm(username)),
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
            .read(websiteAuthControllerProvider(websiteId).notifier)
            .deleteAccount(username);
        if (context.mounted) {
          showAppSuccessToast(context.l10n.websites_accountDeleted);
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

class _AuthAccountCard extends StatelessWidget {
  const _AuthAccountCard({
    required this.username,
    required this.remark,
    required this.onEdit,
    required this.onDelete,
  });

  final String username;
  final String remark;
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
                  color: CupertinoColors.activeBlue
                      .resolveFrom(context)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  TablerIcons.user,
                  size: 16,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  username,
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
          if (remark.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background(context).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    TablerIcons.note,
                    size: 12,
                    color: AppColors.tertiaryLabel(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      remark,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallActionBtn extends StatelessWidget {
  const _SmallActionBtn({
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(
                  context,
                ).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.tertiaryLabel(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.label(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
