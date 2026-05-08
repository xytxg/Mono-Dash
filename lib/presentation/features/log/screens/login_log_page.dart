import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/app_meta_chip.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/status_pill.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/login_log_provider.dart';

/// 打开登录日志页面。
Future<void> openLoginLogPage(BuildContext context, int serverId) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(builder: (_) => LoginLogPage(serverId: serverId)),
  );
}

class LoginLogPage extends StatelessWidget {
  const LoginLogPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _LoginLogContent(),
    );
  }
}

class _LoginLogContent extends ConsumerStatefulWidget {
  const _LoginLogContent();

  @override
  ConsumerState<_LoginLogContent> createState() => _LoginLogContentState();
}

class _LoginLogContentState extends ConsumerState<_LoginLogContent> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _handleListScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
      ref.read(loginLogControllerProvider.notifier).loadMore();
    }
    return false;
  }

  Future<void> _confirmClean() async {
    final l10n = context.l10n;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: l10n.log_clearLoginTitle,
      icon: TablerIcons.trash,
      content: l10n.log_clearLoginContent,
    );
    if (confirmed == true) {
      await ref.read(loginLogControllerProvider.notifier).cleanLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stateAsync = ref.watch(loginLogControllerProvider);
    final notifier = ref.read(loginLogControllerProvider.notifier);

    return FrostedScaffold(
      title: _isSearching ? '' : l10n.log_loginLog,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: l10n.log_searchIpPlaceholder,
            onChanged: notifier.searchByIp,
            onClear: () => notifier.searchByIp(''),
            onCancel: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              notifier.searchByIp('');
            },
          );
        }
        return FrostedOverlayMenuButton(
          label: l10n.log_actions,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: l10n.common_search,
              icon: TablerIcons.search,
              action: () {
                setState(() => _isSearching = true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocusNode.requestFocus();
                });
              },
            ),
            FrostedMenuItem(
              text: l10n.common_refresh,
              icon: TablerIcons.refresh,
              action: notifier.refresh,
            ),
            FrostedMenuItem(
              text: l10n.log_clearLogs,
              icon: TablerIcons.trash,
              iconColor: CupertinoColors.systemRed,
              action: _confirmClean,
            ),
          ],
        );
      },
      body: stateAsync.when(
        loading: () => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: 8,
          padding: EdgeInsets.only(
            top: FrostedScaffold.contentTopPadding(context),
            bottom: 132,
          ),
          itemBuilder: (_, _) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: SkeletonItem(width: double.infinity, height: 96),
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
                  icon: TablerIcons.eye,
                  title: l10n.log_noLoginLogs,
                  subtitle: l10n.log_noLoginLogsSubtitle,
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
                    bottom: 132,
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
                      return _LoginLogRow(
                        ip: item.ip,
                        address: item.address,
                        agent: item.agent,
                        status: item.status,
                        message: item.message,
                        time: item.createdAt,
                        successLabel: l10n.log_success,
                        failedLabel: l10n.log_failed,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoginLogRow extends StatelessWidget {
  const _LoginLogRow({
    required this.ip,
    required this.address,
    required this.agent,
    required this.status,
    required this.message,
    required this.time,
    required this.successLabel,
    required this.failedLabel,
  });

  final String ip;
  final String address;
  final String agent;
  final String status;
  final String message;
  final DateTime time;
  final String successLabel;
  final String failedLabel;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'Success' || status == 'success';
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
                isSuccess ? TablerIcons.shield_check : TablerIcons.shield_x,
                size: 18,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),

            // 内容区
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ip,
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
                  // 位置与 UA
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (address.isNotEmpty)
                        _MetaInfo(icon: TablerIcons.map_pin, text: address),
                      if (agent.isNotEmpty)
                        _MetaInfo(
                          icon: TablerIcons.device_laptop,
                          text: _formatAgent(agent),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // 时间与消息
                  Row(
                    children: [
                      _MetaInfo(
                        icon: TablerIcons.clock,
                        text: DateFormat('yyyy-MM-dd HH:mm:ss').format(time),
                      ),
                      const Spacer(),
                      if (!isSuccess && message.isNotEmpty)
                        AppMetaChip(
                          label: message,
                          color: CupertinoColors.systemRed.resolveFrom(context),
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

  String _formatAgent(String agent) {
    if (agent.contains('Macintosh')) return 'macOS';
    if (agent.contains('Windows')) return 'Windows';
    if (agent.contains('iPhone')) return 'iPhone';
    if (agent.contains('Android')) return 'Android';
    if (agent.contains('Postman')) return 'Postman';
    return agent;
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
