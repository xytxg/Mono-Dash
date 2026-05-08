import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/snapshot/snapshot_dto.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/status_tag.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../../common/components/thin_divider.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../widgets/snapshot_create_sheet.dart';
import '../widgets/snapshot_import_sheet.dart';

class SnapshotPage extends StatelessWidget {
  const SnapshotPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _SnapshotContent(),
    );
  }
}

class _SnapshotContent extends ConsumerStatefulWidget {
  const _SnapshotContent();

  @override
  ConsumerState<_SnapshotContent> createState() => _SnapshotContentState();
}

class _SnapshotContentState extends ConsumerState<_SnapshotContent> {
  List<SnapshotInfo> _snapshots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = await ref.read(settingRepositoryProvider.future);
      final result = await repo.searchSnapshots(page: 1, pageSize: 100);
      if (!mounted) return;
      final data = result['data'];
      final payload = data is Map<String, dynamic> ? data : result;
      final items = payload['items'];
      setState(() {
        _snapshots = items is List
            ? items
                  .whereType<Map>()
                  .map(
                    (item) =>
                        SnapshotInfo.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList()
            : [];
        _loading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('SnapshotPage._load failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FrostedScaffold(
      title: context.l10n.panelSettings_snapshots,
      trailingBuilder: (isDark, isOverlapping) => FrostedOverlayMenuButton(
        isDark: isDark,
        isOverlapping: isOverlapping,
        items: [
          FrostedMenuItem(
            text: context.l10n.common_refresh,
            icon: TablerIcons.refresh,
            action: _load,
          ),
          FrostedMenuItem(
            text: context.l10n.panelSettings_createSnapshot,
            icon: TablerIcons.plus,
            action: () async {
              await navigateToSnapshotCreatePage(
                context,
                ref.read(activeServerIdProvider),
              );
              if (mounted) _load();
            },
          ),
          FrostedMenuItem(
            text: context.l10n.panelSettings_importSnapshot,
            icon: TablerIcons.download,
            action: () async {
              await showSnapshotImportSheet(context);
              if (mounted) _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : _snapshots.isEmpty
          ? _buildEmpty(context)
          : _buildList(context),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return AppEmptyState(
      icon: TablerIcons.camera_off,
      title: context.l10n.panelSettings_noSnapshots,
      onAction: () async {
        await navigateToSnapshotCreatePage(
          context,
          ref.read(activeServerIdProvider),
        );
        if (mounted) _load();
      },
      actionLabel: context.l10n.panelSettings_createSnapshot,
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        0,
        FrostedScaffold.contentTopPadding(context) + 12,
        0,
        40,
      ),
      itemCount: _snapshots.length,
      itemBuilder: (context, index) =>
          _buildSnapshotCard(context, _snapshots[index]),
    );
  }

  Widget _buildSnapshotCard(BuildContext context, SnapshotInfo snapshot) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      pressedOpacity: 0.9,
      onPressed: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(20),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _statusColor(snapshot.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    TablerIcons.camera,
                    size: 22,
                    color: _statusColor(snapshot.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.panelSettings_snapshotVersion(
                          snapshot.version,
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.tertiaryLabel(context),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusTag(
                  label: snapshot.status,
                  color: _statusColor(snapshot.status),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  borderRadius: 8,
                ),
              ],
            ),
            if (snapshot.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              const ThinDivider(),
              const SizedBox(height: 10),
              Text(
                snapshot.description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryLabel(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            const ThinDivider(),
            const SizedBox(height: 10),
            Row(
              children: [
                if (snapshot.createdAt.isNotEmpty)
                  Expanded(
                    child: Text(
                      formatTimeAgo(
                        DateTime.tryParse(snapshot.createdAt),
                        context.l10n,
                        prefix: '',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiaryLabel(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 8),
                if (snapshot.taskID.isNotEmpty && snapshot.taskID != '0') ...[
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    color: CupertinoColors.systemGrey
                        .resolveFrom(context)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () => _showLog(snapshot),
                    child: Text(
                      context.l10n.panelSettings_log,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  color: CupertinoColors.activeBlue
                      .resolveFrom(context)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () => _recoverSnapshot(snapshot),
                  child: Text(
                    context.l10n.panelSettings_restore,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.activeBlue.resolveFrom(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  color: CupertinoColors.systemRed
                      .resolveFrom(context)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () => _deleteSnapshot(snapshot),
                  child: Text(
                    context.l10n.common_delete,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemRed.resolveFrom(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLog(SnapshotInfo snapshot) async {
    final repo = await ref.read(appRepositoryProvider.future);
    if (!mounted) return;
    showTaskLogSheet(
      context,
      title: context.l10n.panelSettings_snapshotLogTitle(snapshot.name),
      taskID: snapshot.taskID,
      reader: repo.readTaskLog,
    );
  }

  Future<void> _recoverSnapshot(SnapshotInfo snapshot) async {
    final confirmed = await showActionSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AppConfirmSheet(
        title: context.l10n.panelSettings_restoreSnapshot,
        content: context.l10n.panelSettings_restoreSnapshotConfirm(
          snapshot.name,
        ),
        icon: TablerIcons.restore,
        iconColor: CupertinoColors.systemOrange,
        confirmText: context.l10n.panelSettings_restore,
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final repo = await ref.read(settingRepositoryProvider.future);
      await repo.recoverSnapshot(id: snapshot.id, isNew: true);
      if (mounted) {
        showAppSuccessToast(context.l10n.panelSettings_snapshotRestoreStarted);
        _load();
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.panelSettings_restoreFailed,
          description: e.toString(),
        );
      }
    }
  }

  Future<void> _deleteSnapshot(SnapshotInfo snapshot) async {
    final confirmed = await showActionSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AppConfirmSheet(
        title: context.l10n.panelSettings_deleteSnapshot,
        content: context.l10n.panelSettings_deleteSnapshotConfirm(
          snapshot.name,
        ),
        icon: TablerIcons.trash,
        iconColor: CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final repo = await ref.read(settingRepositoryProvider.future);
      await repo.deleteSnapshots(ids: [snapshot.id]);
      if (mounted) {
        showAppSuccessToast(context.l10n.panelSettings_deleted);
        _load();
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.panelSettings_deleteFailed,
          description: e.toString(),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Success':
        return CupertinoColors.systemGreen;
      case 'Failed':
        return CupertinoColors.systemRed;
      case 'Waiting':
        return CupertinoColors.systemOrange;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}
