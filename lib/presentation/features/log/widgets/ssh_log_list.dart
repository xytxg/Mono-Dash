import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_meta_chip.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/status_pill.dart';
import '../providers/ssh_log_provider.dart';

/// SSH 登录日志列表，可被独立页面或 Tab 嵌入复用。
///
/// 不含 `FrostedScaffold` 外壳，由调用方提供。
class SshLogList extends ConsumerStatefulWidget {
  const SshLogList({super.key, this.bottomPadding = 132});

  /// 列表底部内边距，用于避开 FloatingTabBar。
  final double bottomPadding;

  @override
  ConsumerState<SshLogList> createState() => _SshLogListState();
}

class _SshLogListState extends ConsumerState<SshLogList> {
  bool _handleListScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
      ref.read(sshLogControllerProvider.notifier).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stateAsync = ref.watch(sshLogControllerProvider);
    final notifier = ref.read(sshLogControllerProvider.notifier);

    return stateAsync.when(
      loading: () => ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: 8,
        padding: EdgeInsets.only(
          top: FrostedScaffold.contentTopPadding(context),
          bottom: widget.bottomPadding,
        ),
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: SkeletonItem(width: double.infinity, height: 92),
        ),
      ),
      error: (e, _) => ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(
          top: FrostedScaffold.contentTopPadding(context),
        ),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          AppEmptyState(
            icon: TablerIcons.alert_triangle,
            title: l10n.common_loadingFailed,
            subtitle: e.toString(),
            actionLabel: l10n.common_retry,
            onAction: notifier.refresh,
          ),
        ],
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.only(
              top: FrostedScaffold.contentTopPadding(context),
            ),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              AppEmptyState(
                icon: TablerIcons.login,
                title: l10n.log_noSshLoginLogs,
                subtitle: l10n.log_noSshLoginLogsSubtitle,
              ),
            ],
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: _handleListScroll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(onRefresh: notifier.refresh),
              SliverPadding(
                padding: EdgeInsets.only(
                  top: FrostedScaffold.contentTopPadding(context),
                  bottom: widget.bottomPadding,
                ),
                sliver: SliverList.builder(
                  itemCount: state.items.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.items.length) {
                      return state.isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                    final item = state.items[index];
                    return _SshLogRow(
                      address: item.address,
                      area: item.area,
                      user: item.user,
                      authMode: item.authMode,
                      port: item.port,
                      status: item.status,
                      time: item.date,
                      successLabel: l10n.log_success,
                      failedLabel: l10n.log_failed,
                      portLabel: l10n.log_port,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SshLogRow extends StatelessWidget {
  const _SshLogRow({
    required this.address,
    required this.area,
    required this.user,
    required this.authMode,
    required this.port,
    required this.status,
    required this.time,
    required this.successLabel,
    required this.failedLabel,
    required this.portLabel,
  });

  final String address;
  final String area;
  final String user;
  final String authMode;
  final String port;
  final String status;
  final DateTime time;
  final String successLabel;
  final String failedLabel;
  final String Function(String) portLabel;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'Success';
    final statusColor = isSuccess
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemRed.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态图标
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                isSuccess ? TablerIcons.circle_check : TablerIcons.circle_x,
                size: 18,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),

            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(
                        label: isSuccess ? successLabel : failedLabel,
                        active: isSuccess,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // 第一行元数据
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _MetaInfo(icon: TablerIcons.user, text: user),
                      if (area.isNotEmpty)
                        _MetaInfo(icon: TablerIcons.map_pin, text: area),
                      if (port.isNotEmpty)
                        _MetaInfo(
                          icon: TablerIcons.plug,
                          text: portLabel(port),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // 第二行元数据
                  Row(
                    children: [
                      _MetaInfo(
                        icon: TablerIcons.clock,
                        text: DateFormat('yyyy-MM-dd HH:mm:ss').format(time),
                      ),
                      const Spacer(),
                      if (authMode.isNotEmpty)
                        AppMetaChip(
                          label: authMode,
                          color: AppColors.secondaryLabel(context),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  const _MetaInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.tertiaryLabel(context)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
