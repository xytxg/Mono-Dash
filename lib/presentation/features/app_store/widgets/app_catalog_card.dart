import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/app/app_catalog_dto.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/app_toast.dart';
import 'app_detail_sheet.dart';
import 'app_icon_view.dart';
import '../../../common/components/app_meta_chip.dart';
import '../../../common/components/skeleton_item.dart';
import 'app_version_picker_dialog.dart';

class AppCatalogCard extends ConsumerWidget {
  const AppCatalogCard({
    super.key,
    this.app,
    this.serverId,
    this.loading = false,
  });

  final AppCatalogDto? app;
  final int? serverId;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loading) return _buildSkeleton(context);

    final app = this.app!;
    final serverId = this.serverId!;
    return GestureDetector(
      onTap: () => showAppDetailSheet(
        context,
        serverId,
        app.key,
        installed: app.installed,
        limit: app.limit,
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.16),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconView(
              iconName: app.key,
              // Compatibility: 1Panel v2.0.0 returns a base64 icon directly
              inlineIcon: app.icon,
              size: 46,
              borderRadius: 13,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          app.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _InstallState(installed: app.installed),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.description.isEmpty
                        ? context.l10n.appStore_noDescription
                        : app.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final tag in app.tags.take(3))
                              AppMetaChip(
                                label: tag,
                                color: CupertinoColors.systemTeal.resolveFrom(
                                  context,
                                ),
                                height: 21,
                              ),
                            if (app.type.isNotEmpty)
                              AppMetaChip(
                                label: app.type,
                                color: CupertinoColors.systemTeal.resolveFrom(
                                  context,
                                ),
                                height: 21,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) {
                          final bool isLimitOneAndInstalled =
                              app.limit == 1 && app.installed;
                          return CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            onPressed: isLimitOneAndInstalled
                                ? null
                                : () async {
                                    // 如果已经有版本信息，直接显示选择器
                                    if (app.versions.isNotEmpty) {
                                      showAppVersionPickerDialog(
                                        context: context,
                                        serverId: serverId,
                                        appId: app.id,
                                        appKey: app.key,
                                        appName: app.name,
                                        versions: app.versions,
                                      );
                                      return;
                                    }

                                    // 否则先静默获取详情（包含版本信息）
                                    final l10n = context.l10n;
                                    try {
                                      final repo = await ref.read(
                                        appRepositoryProvider.future,
                                      );
                                      final detail = await repo.getAppDetail(
                                        app.key,
                                      );
                                      if (context.mounted) {
                                        showAppVersionPickerDialog(
                                          context: context,
                                          serverId: serverId,
                                          appId: app.id,
                                          appKey: app.key,
                                          appName: app.name,
                                          versions: detail.versions,
                                        );
                                      }
                                    } catch (e) {
                                      showAppErrorToast(
                                        l10n.appStore_fetchVersionInfoFailed,
                                        description: '$e',
                                      );
                                    }
                                  },
                            child: Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: CupertinoColors.activeBlue
                                    .resolveFrom(context)
                                    .withValues(
                                      alpha: isLimitOneAndInstalled
                                          ? 0.06
                                          : 0.12,
                                    ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                context.l10n.appStore_install,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: CupertinoColors.activeBlue
                                      .resolveFrom(context)
                                      .withValues(
                                        alpha: isLimitOneAndInstalled
                                            ? 0.45
                                            : 1,
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
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

  Widget _buildSkeleton(BuildContext context) {
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
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonItem(width: 46, height: 46, borderRadius: 13),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: SkeletonItem.text(width: 100, height: 16)),
                    SizedBox(width: 8),
                    SkeletonItem.text(width: 40, height: 12),
                  ],
                ),
                SizedBox(height: 5),
                SkeletonItem.text(width: double.infinity, height: 12),
                SizedBox(height: 4),
                SkeletonItem.text(width: 150, height: 12),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          SkeletonItem(width: 50, height: 21, borderRadius: 6),
                          SkeletonItem(width: 40, height: 21, borderRadius: 6),
                          SkeletonItem(width: 45, height: 21, borderRadius: 6),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    SkeletonItem(width: 54, height: 30, borderRadius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstallState extends StatelessWidget {
  const _InstallState({required this.installed});

  final bool installed;

  @override
  Widget build(BuildContext context) {
    final color = installed
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : AppColors.tertiaryLabel(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          installed ? TablerIcons.circle_check_filled : TablerIcons.circle,
          size: 13,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          installed
              ? context.l10n.appStore_installed
              : context.l10n.appStore_notInstalled,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
