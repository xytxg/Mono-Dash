import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../providers/app_store_provider.dart';
import 'app_icon_view.dart';
import '../../../common/components/app_meta_chip.dart';
import '../../../common/components/skeleton_item.dart';
import 'app_store_action_sheet.dart';

class AppInstalledCard extends ConsumerWidget {
  const AppInstalledCard({super.key, this.app, this.loading = false});

  final AppInstalledDto? app;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loading) return _buildSkeleton(context);

    final app = this.app!;
    final statusColor = _statusColor(context, app.status);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => showAppStoreActionSheet(context, ref, app),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.16),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: AppIconBackground(
                iconName: app.name,
                inlineIcon: app.icon,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIconView(
                    iconName: app.name,
                    inlineIcon: app.icon,
                    size: 54,
                    borderRadius: 15,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                app.displayName,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.label(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            CupertinoButton(
                              padding: const EdgeInsets.all(4),
                              minimumSize: Size.zero,
                              onPressed: () => ref
                                  .read(appStoreControllerProvider.notifier)
                                  .toggleInstalledFavorite(app),
                              child: Icon(
                                app.favorite
                                    ? TablerIcons.star_filled
                                    : TablerIcons.star,
                                size: 18,
                                color: app.favorite
                                    ? CupertinoColors.systemYellow.resolveFrom(
                                        context,
                                      )
                                    : AppColors.tertiaryLabel(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          app.version,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryLabel(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            AppMetaChip(
                              icon: TablerIcons.circle_filled,
                              label: _statusLabel(context, app.status),
                              color: statusColor,
                            ),
                            AppMetaChip(
                              icon: TablerIcons.calendar,
                              label: _installedText(context, app.createdAt),
                              color: CupertinoColors.systemBlue.resolveFrom(
                                context,
                              ),
                            ),
                            AppMetaChip(
                              icon: TablerIcons.world,
                              label: _portText(context, 'HTTP', app.httpPort),
                              color: CupertinoColors.systemTeal.resolveFrom(
                                context,
                              ),
                            ),
                            AppMetaChip(
                              icon: TablerIcons.shield_lock,
                              label: _portText(context, 'HTTPS', app.httpsPort),
                              color: CupertinoColors.systemGreen.resolveFrom(
                                context,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonItem(width: 54, height: 54, borderRadius: 15),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SkeletonItem.text(width: 120, height: 18),
                      ),
                      SizedBox(width: 4),
                      SkeletonItem(width: 18, height: 18, borderRadius: 4),
                    ],
                  ),
                  SizedBox(height: 6),
                  SkeletonItem.text(width: 60, height: 12),
                  SizedBox(height: 11),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      SkeletonItem(width: 50, height: 22, borderRadius: 6),
                      SkeletonItem(width: 70, height: 22, borderRadius: 6),
                      SkeletonItem(width: 60, height: 22, borderRadius: 6),
                      SkeletonItem(width: 65, height: 22, borderRadius: 6),
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

  static Color _statusColor(BuildContext context, String status) {
    return switch (status.toLowerCase()) {
      'running' => CupertinoColors.systemGreen.resolveFrom(context),
      'rebuilding' => CupertinoColors.systemBlue.resolveFrom(context),
      'stopped' || 'error' => CupertinoColors.systemRed.resolveFrom(context),
      _ => CupertinoColors.systemOrange.resolveFrom(context),
    };
  }

  /// 卡片展示用状态文案（接口仍为英文 status）。
  static String _statusLabel(BuildContext context, String status) {
    if (status.isEmpty) return context.l10n.common_unknown;
    return switch (status.toLowerCase()) {
      'running' => context.l10n.appStore_statusRunning,
      'rebuilding' => context.l10n.appStore_statusRebuilding,
      'stopped' => context.l10n.appStore_statusStopped,
      'error' => context.l10n.appStore_statusError,
      _ => status,
    };
  }

  static String _portText(BuildContext context, String label, int port) {
    return port <= 0
        ? context.l10n.appStore_portNotConfigured(label)
        : '$label $port';
  }

  static String _installedText(BuildContext context, DateTime? createdAt) {
    if (createdAt == null) return context.l10n.appStore_installedUnknown;
    final local = createdAt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final days = today.difference(day).inDays;
    if (days <= 0) return context.l10n.appStore_installedToday;
    return context.l10n.appStore_installedDays(days);
  }
}
