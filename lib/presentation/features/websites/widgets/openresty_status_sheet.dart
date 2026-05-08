import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/website/openresty_status_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/app_action_components.dart';
import 'website_modal_sheet.dart';

/// OpenResty runtime status provider.
final openRestyStatusProvider = FutureProvider.autoDispose<OpenRestyStatusDto>((
  ref,
) async {
  final repo = await ref.watch(websiteRepositoryProvider.future);
  return repo.getOpenRestyStatus();
}, dependencies: [websiteRepositoryProvider]);

/// Shows the OpenResty runtime status sheet.
Future<void> showOpenRestyStatusSheet(BuildContext context) async {
  await showWebsiteModalSheet<void>(
    context: context,
    child: const _OpenRestyStatusSheet(),
  );
}

class _OpenRestyStatusSheet extends ConsumerWidget {
  const _OpenRestyStatusSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WebsiteAsyncModalSheet<OpenRestyStatusDto>(
      provider: openRestyStatusProvider,
      errorTitle: context.l10n.websites_getRuntimeStatusFailed,
      infoCardBuilder: (context, ref, async) => ActionSheetInfoCard(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen
                .resolveFrom(context)
                .withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            TablerIcons.activity,
            size: 22,
            color: CupertinoColors.systemGreen.resolveFrom(context),
          ),
        ),
        title: context.l10n.websites_runtimeStatus,
        subtitle: context.l10n.websites_openRestyRealtimeMetrics,
        trailing: const SizedBox.shrink(),
      ),
      dataBuilder: (context, status) => _StatusContent(status: status),
      onRetry: (ref) => ref.invalidate(openRestyStatusProvider),
    );
  }
}

class _StatusContent extends StatelessWidget {
  const _StatusContent({required this.status});

  final OpenRestyStatusDto status;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: context.l10n.websites_activityMetrics,
          icon: TablerIcons.chart_dots,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.plug_connected,
              iconColor: CupertinoColors.activeGreen.resolveFrom(context),
              title: context.l10n.websites_activeConnections,
              subtitle: Text(
                context.l10n.websites_currentActiveClientConnections,
              ),
              trailing: Text(
                '${status.active}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.activeGreen.resolveFrom(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppSectionHeader(
          title: context.l10n.websites_requestStats,
          icon: TablerIcons.history,
        ),
        AppActionGroup(
          children: [
            _StatRow(
              label: context.l10n.websites_totalConnections,
              value: '${status.accepts}',
              icon: TablerIcons.arrows_join,
            ),
            _StatRow(
              label: context.l10n.websites_totalHandshakes,
              value: '${status.handled}',
              icon: TablerIcons.checkup_list,
            ),
            _StatRow(
              label: context.l10n.websites_totalRequests,
              value: '${status.requests}',
              icon: TablerIcons.world,
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppSectionHeader(
          title: context.l10n.websites_connectionDetails,
          icon: TablerIcons.list_details,
        ),
        AppActionGroup(
          children: [
            _StatRow(
              label: 'Reading',
              value: '${status.reading}',
              subtitle: context.l10n.websites_readingClientRequestHeaders,
            ),
            _StatRow(
              label: 'Writing',
              value: '${status.writing}',
              subtitle: context.l10n.websites_writingResponseToClient,
            ),
            _StatRow(
              label: 'Waiting',
              value: '${status.waiting}',
              subtitle: context.l10n.websites_idleWaitingState,
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.icon,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppActionRow(
      icon: icon,
      iconColor: icon != null ? AppColors.secondaryLabel(context) : null,
      title: label,
      subtitle: Text(subtitle ?? context.l10n.websites_realtimeMetric),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.label(context),
        ),
      ),
    );
  }
}
