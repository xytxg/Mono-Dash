import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../models/system_log_state.dart';
import '../providers/system_log_provider.dart';

/// 打开系统日志页面。
Future<void> openSystemLogPage(BuildContext context, int serverId) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(builder: (_) => SystemLogPage(serverId: serverId)),
  );
}

class SystemLogPage extends StatelessWidget {
  const SystemLogPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _SystemLogContent(),
    );
  }
}

class _SystemLogContent extends ConsumerWidget {
  const _SystemLogContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stateAsync = ref.watch(systemLogControllerProvider);
    final notifier = ref.read(systemLogControllerProvider.notifier);

    return FrostedScaffold(
      title: l10n.log_systemLog,
      trailingBuilder: (isDark, isOverlapping) {
        return FrostedOverlayMenuButton(
          label: l10n.log_actions,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: l10n.common_refresh,
              icon: TablerIcons.refresh,
              action: notifier.refresh,
            ),
          ],
        );
      },
      body: stateAsync.when(
        loading: () => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: 5,
          padding: EdgeInsets.only(
            top: FrostedScaffold.contentTopPadding(context),
            bottom: 132,
          ),
          itemBuilder: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: SkeletonItem(
              width: MediaQuery.of(context).size.width - 20,
              height: 184,
            ),
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
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: FrostedScaffold.contentTopPadding(context) + 8,
                ),
              ),
              // Agent/Core toggle + File selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                  child: Column(
                    children: [
                      // Agent / Core toggle
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBackground(
                            context,
                          ).withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.separator(
                              context,
                            ).withValues(alpha: 0.12),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    notifier.toggleAgentCore(isAgent: true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: state.isAgent
                                        ? CupertinoColors.activeBlue
                                        : const Color(0x00000000),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Agent',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: state.isAgent
                                            ? CupertinoColors.white
                                            : CupertinoColors.secondaryLabel
                                                  .resolveFrom(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    notifier.toggleAgentCore(isAgent: false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !state.isAgent
                                        ? CupertinoColors.activeBlue
                                        : const Color(0x00000000),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Core',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: !state.isAgent
                                            ? CupertinoColors.white
                                            : CupertinoColors.secondaryLabel
                                                  .resolveFrom(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // File selector
                      if (state.files.isNotEmpty)
                        GestureDetector(
                          onTap: () => _showFilePicker(context, ref, state),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryBackground(
                                context,
                              ).withValues(alpha: 0.58),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.separator(
                                  context,
                                ).withValues(alpha: 0.12),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  TablerIcons.file_text,
                                  size: 18,
                                  color: CupertinoColors.secondaryLabel
                                      .resolveFrom(context),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.selectedFile,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.label.resolveFrom(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  TablerIcons.chevron_down,
                                  size: 16,
                                  color: CupertinoColors.tertiaryLabel
                                      .resolveFrom(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Log content
              if (state.isLoadingContent)
                const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else if (state.content.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: AppEmptyState(
                      icon: TablerIcons.file_text,
                      title: l10n.log_noSystemLogContent,
                      subtitle: l10n.log_noSystemLogContentSubtitle,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 132),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 400),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground(
                          context,
                        ).withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.separator(
                            context,
                          ).withValues(alpha: 0.12),
                          width: 0.5,
                        ),
                      ),
                      child: SelectableText(
                        state.content,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Menlo',
                          height: 1.5,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showFilePicker(
    BuildContext context,
    WidgetRef ref,
    SystemLogState state,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(context.l10n.log_selectLogFile),
        actions: state.files
            .map(
              (file) => CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  ref
                      .read(systemLogControllerProvider.notifier)
                      .selectFile(file);
                },
                child: Text(file),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.common_cancel),
        ),
      ),
    );
  }
}
