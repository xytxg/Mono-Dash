import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/app/app_ignored_dto.dart';
import '../../../../data/dto/app/app_installed_search_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';

class AppIgnoredSheet extends ConsumerStatefulWidget {
  const AppIgnoredSheet({super.key});

  @override
  ConsumerState<AppIgnoredSheet> createState() => _AppIgnoredSheetState();
}

class _AppIgnoredSheetState extends ConsumerState<AppIgnoredSheet> {
  bool _loading = true;
  bool _didLoad = false;
  List<AppIgnoredDto> _ignoredApps = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _load();
  }

  Future<void> _load() async {
    final l10n = context.l10n;
    setState(() => _loading = true);
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      var list = await repo.getIgnoredApps();

      // Compatibility: 1Panel v2.0.0 returns empty 'name' in ignore list.
      // We need to fetch the app name from the installed apps list as fallback.
      if (list.any((e) => e.name.isEmpty)) {
        try {
          final installedRes = await repo.searchInstalledApps(
            const AppInstalledSearchReq(page: 1, pageSize: 1000),
          );
          final installedApps = installedRes.items;

          list = list.map((ignored) {
            if (ignored.name.isNotEmpty) return ignored;

            // Try to match by appDetailId (more specific) or appId
            final matched = installedApps.cast<dynamic>().firstWhere(
              (i) =>
                  i.appDetailId == ignored.appDetailId ||
                  i.appId == ignored.appId,
              orElse: () => null,
            );

            if (matched != null) {
              final name = matched.appName.isNotEmpty
                  ? matched.appName
                  : matched.name;
              return ignored.copyWith(name: name);
            }
            return ignored;
          }).toList();
        } catch (e) {
          // Silent fail for name lookup, keep original list
        }
      }

      if (mounted) {
        setState(() {
          _ignoredApps = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAppErrorToast(l10n.appStore_loadIgnoredFailed('$e'));
      }
    }
  }

  Future<void> _handleCancelIgnore(AppIgnoredDto app) async {
    final l10n = context.l10n;
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      await repo.cancelIgnore(app.id);
      showAppSuccessToast(l10n.appStore_cancelIgnored, description: app.name);
      _load();
    } catch (e) {
      showAppErrorToast(l10n.appStore_cancelIgnoreFailed('$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _ignoredApps.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.tertiaryLabel(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
      child: Row(
        children: [
          Icon(
            TablerIcons.bell_off,
            size: 22,
            color: CupertinoColors.systemOrange.resolveFrom(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.appStore_ignoredApps,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.label(context),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(TablerIcons.x, color: AppColors.tertiaryLabel(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.bell,
            size: 48,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.appStore_noIgnoredApps,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.paddingOf(context).bottom + 20,
      ),
      itemCount: _ignoredApps.length,
      itemBuilder: (context, index) {
        final app = _ignoredApps[index];
        return _buildIgnoredCard(app);
      },
    );
  }

  Widget _buildIgnoredCard(AppIgnoredDto app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app.scope == 'all'
                      ? context.l10n.appStore_ignoredAllVersions
                      : context.l10n.appStore_ignoredVersion(app.version),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: CupertinoColors.systemGrey5.resolveFrom(context),
            borderRadius: BorderRadius.circular(8),
            onPressed: () => _handleCancelIgnore(app),
            child: Text(
              context.l10n.appStore_cancelIgnore,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showAppIgnoredSheet(BuildContext context) {
  showActionSheet(
    context: context,
    builder: (context) => const AppIgnoredSheet(),
  );
}
