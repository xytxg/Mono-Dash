import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/dto/website/website_resource_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../../common/components/app_picker.dart';
import '../providers/website_detail_provider.dart';
import '../providers/websites_provider.dart';
import 'website_modal_sheet.dart';

part 'website_resource_sheet.g.dart';

Future<void> showWebsiteResourceSheet(
  BuildContext context, {
  required int websiteId,
  required String title,
}) async {
  await showWebsiteModalSheet<void>(
    context: context,
    child: _WebsiteResourceSheet(websiteId: websiteId, title: title),
  );
}

class _WebsiteResourceSheet extends StatelessWidget {
  const _WebsiteResourceSheet({required this.websiteId, required this.title});

  final int websiteId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return WebsiteAsyncModalSheet<WebsiteDetailDto>(
      provider: websiteDetailProvider(websiteId),
      errorTitle: context.l10n.websites_loadWebsiteDetailsFailed,
      infoCardBuilder: (context, ref, detailAsync) => ActionSheetInfoCard(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: CupertinoColors.systemTeal
                .resolveFrom(context)
                .withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            TablerIcons.chart_bar,
            size: 22,
            color: CupertinoColors.systemTeal.resolveFrom(context),
          ),
        ),
        title: context.l10n.websites_resource,
        subtitle: title,
        trailing: const SizedBox.shrink(),
      ),
      dataBuilder: (context, detail) => _ResourceContent(detail: detail),
      onRetry: (ref) => ref.invalidate(websiteDetailProvider(websiteId)),
    );
  }
}

class _ResourceContent extends ConsumerStatefulWidget {
  const _ResourceContent({required this.detail});

  final WebsiteDetailDto detail;

  @override
  ConsumerState<_ResourceContent> createState() => _ResourceContentState();
}

class _ResourceContentState extends ConsumerState<_ResourceContent> {
  bool _saving = false;

  bool get _canChangeDatabase {
    final type = widget.detail.website.type;
    return type == 'static' || type == 'runtime';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resourcesAsync = ref.watch(
      _websiteResourcesProvider(widget.detail.website.id),
    );
    final databasesAsync = ref.watch(_websiteDatabasesProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resource list
        AppSectionHeader(
          title: l10n.websites_associatedResources,
          icon: TablerIcons.link,
        ),
        resourcesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CupertinoActivityIndicator()),
          ),
          error: (error, _) => _ErrorState(
            error: error,
            onRetry: () => ref.invalidate(
              _websiteResourcesProvider(widget.detail.website.id),
            ),
          ),
          data: (resources) => resources.isEmpty
              ? const _EmptyState()
              : AppActionGroup(
                  children: resources
                      .map((resource) => _ResourceItem(resource: resource))
                      .toList(),
                ),
        ),

        // Database changes are only available for static/runtime websites.
        if (_canChangeDatabase) ...[
          const SizedBox(height: 24),
          AppSectionHeader(
            title: l10n.websites_databaseSettings,
            icon: TablerIcons.database,
          ),
          databasesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (error, _) => const SizedBox.shrink(),
            data: (databases) => _DatabaseSelector(
              detail: widget.detail,
              databases: databases,
              saving: _saving,
              onChanged: _onDatabaseChanged,
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _onDatabaseChanged(
    int databaseId,
    String databaseType,
    String databaseName,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showActionSheet<bool>(
      context: context,
      builder: (context) => AppConfirmSheet(
        title: l10n.websites_changeDatabase,
        content: databaseId == 0
            ? l10n.websites_unlinkDatabaseConfirm
            : l10n.websites_changeDatabaseConfirm(databaseName),
        confirmText: l10n.websites_confirmChange,
        icon: TablerIcons.database_edit,
        iconColor: CupertinoColors.systemOrange.resolveFrom(context),
      ),
    );

    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final req = WebsiteChangeDatabaseReq(
        websiteID: widget.detail.website.id,
        databaseID: databaseId,
        databaseType: databaseType,
      );
      await repo.changeWebsiteDatabase(req);

      if (!mounted) return;

      // Refresh related data.
      ref.invalidate(websiteDetailProvider(widget.detail.website.id));
      ref.invalidate(_websiteResourcesProvider(widget.detail.website.id));
      ref.invalidate(websitesControllerProvider);

      showAppSuccessToast(l10n.websites_databaseAssociationUpdated);
    } catch (error) {
      if (!mounted) return;
      final message = error is AppNetworkException
          ? error.message
          : error.toString();
      showAppErrorToast(l10n.websites_updateFailed, description: message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ResourceItem extends StatelessWidget {
  const _ResourceItem({required this.resource});

  final WebsiteResourceDto resource;

  @override
  Widget build(BuildContext context) {
    final visual = _typeVisual(context, resource.type);

    return AppActionRow(
      icon: visual.icon,
      iconColor: visual.color,
      title: resource.name,
      subtitle: Text(_typeLabel(context, resource.type)),
      trailing: const SizedBox.shrink(),
    );
  }

  static String _typeLabel(BuildContext context, String type) {
    final l10n = context.l10n;
    switch (type) {
      case 'runtime':
        return l10n.websites_runtimeEnvironment;
      case 'app':
        return l10n.websites_application;
      case 'database':
        return l10n.websites_database;
      default:
        return type;
    }
  }

  static ({IconData icon, Color color}) _typeVisual(
    BuildContext context,
    String type,
  ) {
    switch (type) {
      case 'runtime':
        return (
          icon: TablerIcons.server,
          color: CupertinoColors.systemPurple.resolveFrom(context),
        );
      case 'app':
        return (
          icon: TablerIcons.apps,
          color: CupertinoColors.systemBlue.resolveFrom(context),
        );
      case 'database':
        return (
          icon: TablerIcons.database,
          color: CupertinoColors.systemOrange.resolveFrom(context),
        );
      default:
        return (
          icon: TablerIcons.box,
          color: CupertinoColors.systemGrey.resolveFrom(context),
        );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            TablerIcons.link_off,
            size: 32,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.websites_noAssociatedResources,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatabaseSelector extends StatelessWidget {
  const _DatabaseSelector({
    required this.detail,
    required this.databases,
    required this.saving,
    required this.onChanged,
  });

  final WebsiteDetailDto detail;
  final List<WebsiteDatabaseDto> databases;
  final bool saving;
  final void Function(int databaseId, String databaseType, String databaseName)
  onChanged;

  @override
  Widget build(BuildContext context) {
    final website = detail.website;

    // The first option means the website is not associated with a database.
    final options = <AppPickerOption<String>>[
      AppPickerOption<String>(
        value: '0',
        label: context.l10n.websites_noDatabaseAssociation,
        icon: TablerIcons.database_off,
      ),
      ...databases.map(
        (db) => AppPickerOption<String>(
          value: '${db.id}_${db.type}_${db.name}',
          label: '${db.name} (${db.type})',
          icon: TablerIcons.database,
        ),
      ),
    ];

    // Resolve the current selected value.
    String selectedValue = '0';
    if (website.dbID > 0 && website.dbType.isNotEmpty) {
      final matchKeyPrefix = '${website.dbID}_${website.dbType}_';
      try {
        final match = databases.firstWhere(
          (db) => '${db.id}_${db.type}_${db.name}'.startsWith(matchKeyPrefix),
        );
        selectedValue = '${match.id}_${match.type}_${match.name}';
      } catch (_) {}
    }

    return AppActionGroup(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.websites_selectAssociatedDatabase,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
              const SizedBox(height: 12),
              AppInlinePicker<String>(
                options: options,
                value: selectedValue,
                onChanged: (value) {
                  if (value == '0') {
                    onChanged(
                      0,
                      '',
                      context.l10n.websites_noDatabaseAssociation,
                    );
                  } else {
                    final parts = value.split('_');
                    if (parts.length >= 3) {
                      final id = int.tryParse(parts[0]) ?? 0;
                      final type = parts[1];
                      final name = parts.sublist(2).join('_');
                      onChanged(id, type, name);
                    }
                  }
                },
                enabled: !saving,
                selectedColor: CupertinoColors.systemOrange.resolveFrom(
                  context,
                ),
              ),
              if (saving) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CupertinoActivityIndicator(radius: 8),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.websites_updating,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            TablerIcons.alert_triangle,
            size: 32,
            color: CupertinoColors.systemOrange.resolveFrom(context),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.websites_loadResourcesFailed,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: CupertinoColors.systemBlue.resolveFrom(context),
            borderRadius: BorderRadius.circular(10),
            onPressed: onRetry,
            child: Text(
              context.l10n.common_retry,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 网站资源列表 Provider
@Riverpod(dependencies: [websiteRepository])
Future<List<WebsiteResourceDto>> _websiteResources(
  _WebsiteResourcesRef ref,
  int websiteId,
) async {
  final repo = await ref.watch(websiteRepositoryProvider.future);
  return repo.getWebsiteResources(websiteId);
}

/// 可关联数据库列表 Provider
@Riverpod(dependencies: [websiteRepository])
Future<List<WebsiteDatabaseDto>> _websiteDatabases(
  _WebsiteDatabasesRef ref,
) async {
  final repo = await ref.watch(websiteRepositoryProvider.future);
  return repo.getWebsiteDatabases();
}
