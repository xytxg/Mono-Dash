import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import '../../../common/components/app_notice_sheet.dart';
import '../../../../core/network/network_exceptions.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/file/file_share_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../utils/file_icon_utils.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../servers/providers/servers_provider.dart';
import '../providers/file_shares_provider.dart';
import 'file_share_sheet.dart';
import '../../../../data/dto/file/file_item_dto.dart';

class FileShareListSheet extends ConsumerStatefulWidget {
  const FileShareListSheet({super.key, required this.serverId});

  final int serverId;

  static Future<void> show(
    BuildContext context, {
    ProviderContainer? providerContainer,
  }) {
    final container = providerContainer ?? ProviderScope.containerOf(context);
    final serverId = container.read(activeServerIdProvider);
    return showActionSheet(
      context: context,
      providerContainer: container,
      builder: (context) => FileShareListSheet(serverId: serverId),
    );
  }

  @override
  ConsumerState<FileShareListSheet> createState() => _FileShareListSheetState();
}

class _FileShareListSheetState extends ConsumerState<FileShareListSheet> {
  String? _confirmingPath;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(widget.serverId)],
      child: Consumer(
        builder: (context, ref, child) {
          void handleDelete(String path) {
            if (_confirmingPath == path) {
              ref.read(fileSharesControllerProvider.notifier).deleteShare(path);
              setState(() => _confirmingPath = null);
            } else {
              setState(() => _confirmingPath = path);
            }
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_confirmingPath != null) {
                setState(() => _confirmingPath = null);
              }
            },
            child: _FileShareListContent(
              confirmingPath: _confirmingPath,
              onDeleteTap: handleDelete,
            ),
          );
        },
      ),
    );
  }
}

class _FileShareListContent extends ConsumerWidget {
  const _FileShareListContent({this.confirmingPath, required this.onDeleteTap});

  final String? confirmingPath;
  final Function(String) onDeleteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharesAsync = ref.watch(fileSharesControllerProvider);

    return sharesAsync.when(
      data: (shares) => NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              ref.read(fileSharesControllerProvider.notifier).loadMore();
            }
          }
          return false;
        },
        child: ActionSheetScaffold(
          isAdaptive: true,
          showHandle: false,
          panelHeader: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                const Icon(
                  TablerIcons.table_share,
                  size: 24,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.files_actionManageShare,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.label(context),
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () =>
                      ref.read(fileSharesControllerProvider.notifier).refresh(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.label(context).withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      TablerIcons.refresh,
                      size: 18,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: shares.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: [
                    ...shares.map(
                      (share) => _FileShareItem(
                        share: share,
                        isLast: share == shares.last,
                        isConfirming: confirmingPath == share.path,
                        onDeleteTap: onDeleteTap,
                      ),
                    ),
                    if (ref
                        .watch(fileSharesControllerProvider.notifier)
                        .isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CupertinoActivityIndicator(),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
        ),
      ),
      loading: () => ActionSheetScaffold(
        isAdaptive: true,
        showHandle: false,
        child: const SizedBox(
          height: 200,
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ),
      error: (err, stack) {
        if (err is AppNetworkException && err.statusCode == 404) {
          return AppNoticeSheet(
            title: context.l10n.files_shareUnsupportedTitle,
            content: context.l10n.files_shareListUnsupportedContent,
            icon: TablerIcons.puzzle_off,
            iconColor: CupertinoColors.systemBlue,
          );
        }
        return AppNoticeSheet(
          title: context.l10n.common_loadingFailed,
          content: err.toString(),
          icon: TablerIcons.alert_triangle,
          iconColor: CupertinoColors.systemRed,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            TablerIcons.share_off,
            size: 64,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.files_shareListEmpty,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileShareItem extends ConsumerWidget {
  const _FileShareItem({
    required this.share,
    required this.isLast,
    required this.isConfirming,
    required this.onDeleteTap,
  });

  final FileShareDto share;
  final bool isLast;
  final bool isConfirming;
  final Function(String) onDeleteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiresAt = share.expiresAt;
    final isPermanent = share.permanent || expiresAt == 0;

    String expireText;
    if (isPermanent) {
      expireText = context.l10n.files_shareExpirePermanent;
    } else {
      final date = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      expireText = context.l10n.files_shareExpireUntil(
        DateFormat('yyyy/MM/dd HH:mm').format(date),
      );
    }

    return GestureDetector(
      onTap: () {
        // 构建一个极简的 FileItemDto 传递给详情页
        final item = FileItemDto(
          path: share.path,
          name: share.fileName,
          user: '',
          group: '',
          uid: '',
          gid: '',
          extension: share.fileName.contains('.')
              ? share.fileName.substring(share.fileName.lastIndexOf('.'))
              : '',
          content: '',
          size: 0,
          isDir: false, // 假设为文件
          isSymlink: false,
          isHidden: false,
          linkPath: '',
          type: 'file',
          mode: '',
          mimeType: '',
          modTime: '',
          items: [],
          itemTotal: 0,
          favoriteID: 0,
          isDetail: false,
          shareCode: share.code,
        );
        FileShareSheet.show(context, item);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConfirming
                ? CupertinoColors.systemRed.withValues(alpha: 0.3)
                : AppColors.separator(context).withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // 文件图标
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.label(context).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Builder(
                builder: (context) {
                  final extIndex = share.fileName.lastIndexOf('.');
                  final ext = extIndex != -1
                      ? share.fileName.substring(extIndex)
                      : '';
                  final (icon, color) = FileIconUtils.getFileIconInfo(
                    context,
                    ext,
                    share.fileName,
                  );
                  return Icon(
                    icon,
                    color: isConfirming ? CupertinoColors.systemRed : color,
                    size: 24,
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            // 信息区
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    share.fileName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isConfirming
                          ? CupertinoColors.systemRed
                          : AppColors.label(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (share.hasPassword) ...[
                        const Icon(
                          TablerIcons.lock,
                          size: 12,
                          color: CupertinoColors.systemOrange,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          isConfirming
                              ? context.l10n.files_shareCancelConfirmHint
                              : '$expireText  •  ${share.path}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isConfirming
                                ? CupertinoColors.systemRed.withValues(
                                    alpha: 0.7,
                                  )
                                : AppColors.secondaryLabel(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: () => onDeleteTap(share.path),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isConfirming
                      ? CupertinoColors.systemRed.withValues(alpha: 0.1)
                      : AppColors.label(context).withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isConfirming ? TablerIcons.share_off : TablerIcons.x,
                  size: 18,
                  color: isConfirming
                      ? CupertinoColors.systemRed
                      : AppColors.secondaryLabel(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLink(BuildContext context, WidgetRef ref) {
    final serverId = ref.read(activeServerIdProvider);
    final servers = ref.read(serversNotifierProvider).valueOrNull ?? [];
    final server = servers.where((s) => s.id == serverId).firstOrNull;

    if (server != null) {
      final baseUrl = server.baseUrl.toString();
      final link = "$baseUrl/s/${share.code}";
      Clipboard.setData(ClipboardData(text: link));
      showAppSuccessToast(context.l10n.files_shareLinkCopied);
    }
  }
}
