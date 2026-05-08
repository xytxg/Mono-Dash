import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/dto/app/app_update_version_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_picker.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/components/skeleton_item.dart';
import '../providers/app_store_provider.dart';
import 'app_icon_view.dart';
import 'app_upgrade_sheet.dart';

class AppUpdateCard extends ConsumerWidget {
  const AppUpdateCard({super.key, this.app, this.loading = false});

  final AppInstalledDto? app;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loading) return _buildSkeleton(context);

    final app = this.app!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconView(
                  iconName: app.name,
                  inlineIcon: app.icon,
                  size: 48,
                  borderRadius: 12,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.displayName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.appStore_currentVersion(app.version),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.appStore_newVersionFound,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGreen.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: AppColors.tertiaryBackground(context),
                    borderRadius: BorderRadius.circular(10),
                    onPressed: () => _handleIgnore(context, ref),
                    child: Text(
                      context.l10n.appStore_ignore,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.label(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(10),
                    onPressed: () => showAppUpgradeSheet(context, app),
                    child: Text(
                      context.l10n.appStore_update,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonItem(width: 48, height: 48, borderRadius: 12),
                SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonItem.text(width: 120, height: 18),
                      SizedBox(height: 5),
                      SkeletonItem.text(width: 80, height: 12),
                      SizedBox(height: 3),
                      SkeletonItem.text(width: 60, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SkeletonItem(
                    width: double.infinity,
                    height: 36,
                    borderRadius: 10,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SkeletonItem(
                    width: double.infinity,
                    height: 36,
                    borderRadius: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleIgnore(BuildContext context, WidgetRef ref) async {
    String scope = 'all';
    int? selectedDetailId;
    List<AppUpdateVersionDto>? versions;
    bool loading = false;

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => FrostedDialog(
          title: context.l10n.appStore_ignoreUpdate,
          subtitle: context.l10n.appStore_ignoreUpdateSubtitle,
          icon: TablerIcons.bell_off,
          confirmText: context.l10n.appStore_confirmIgnore,
          confirmEnabled: scope == 'all' || selectedDetailId != null,
          onCancel: () => Navigator.pop(context, false),
          onConfirm: () => Navigator.pop(context, true),
          child: Column(
            children: [
              AppInlinePicker<String>(
                options: [
                  AppPickerOption(
                    label: context.l10n.appStore_ignoreAllVersions,
                    value: 'all',
                  ),
                  AppPickerOption(
                    label: context.l10n.appStore_ignoreSpecificVersion,
                    value: 'version',
                  ),
                ],
                value: scope,
                onChanged: (v) async {
                  setDialogState(() => scope = v);
                  if (v == 'version' && versions == null && !loading) {
                    setDialogState(() => loading = true);
                    try {
                      final repo = await ref.read(appRepositoryProvider.future);
                      final list = await repo.getUpdateVersions(app!.id);
                      if (context.mounted) {
                        setDialogState(() {
                          versions = list;
                          loading = false;
                          if (list.isNotEmpty) {
                            selectedDetailId = list.first.detailId;
                          }
                        });
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setDialogState(() => loading = false);
                        showAppErrorToast(
                          context.l10n.appStore_fetchVersionsFailed('$e'),
                        );
                      }
                    }
                  }
                },
              ),
              if (scope == 'version') ...[
                const SizedBox(height: 12),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CupertinoActivityIndicator(),
                  )
                else if (versions != null)
                  AppInlinePicker<int>(
                    options: versions!
                        .map<AppPickerOption<int>>(
                          (v) => AppPickerOption(
                            label: v.version,
                            value: v.detailId,
                          ),
                        )
                        .toList(),
                    value: selectedDetailId ?? 0,
                    onChanged: (v) =>
                        setDialogState(() => selectedDetailId = v),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await _submitIgnore(
        context,
        ref,
        scope: scope,
        detailId: scope == 'all' ? app!.appDetailId : selectedDetailId!,
      );
    }
  }

  Future<void> _submitIgnore(
    BuildContext context,
    WidgetRef ref, {
    required String scope,
    required int detailId,
  }) async {
    final l10n = context.l10n;
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      await repo.ignoreUpdate(
        appId: app!.appId,
        appDetailId: detailId,
        scope: scope,
      );
      showAppSuccessToast(l10n.appStore_updateIgnored);
      // 刷新列表
      ref.read(appStoreControllerProvider.notifier).refresh();
    } catch (e) {
      showAppErrorToast(l10n.appStore_operationFailedWithError('$e'));
    }
  }
}
