import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/router/sheet_dismiss_refresh_mixin.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/floating_tab_bar.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/app_catalog_provider.dart';
import '../providers/app_store_provider.dart';
import '../widgets/all_apps_tab.dart';
import '../widgets/installed_apps_tab.dart';
import '../widgets/updates_tab.dart';
import '../widgets/app_ignored_sheet.dart';
import '../widgets/app_settings_tab.dart';

enum AppStoreTab { installed, all, updates, settings }

class AppStorePage extends StatelessWidget {
  const AppStorePage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: _AppStoreContent(serverId: serverId),
    );
  }
}

class _AppStoreContent extends ConsumerStatefulWidget {
  const _AppStoreContent({required this.serverId});

  final int serverId;

  @override
  ConsumerState<_AppStoreContent> createState() => _AppStorePageState();
}

class _AppStorePageState extends ConsumerState<_AppStoreContent>
    with SheetDismissRefreshMixin {
  Timer? _searchDebounce;

  final _scrollController = ScrollController();
  final _catalogScrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  AppStoreTab _selectedTab = AppStoreTab.installed;
  bool _isSearching = false;

  @override
  void onAllSheetsClosed() {
    ref.read(appStoreControllerProvider.notifier).refresh();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _catalogScrollController.addListener(_onCatalogScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _catalogScrollController.removeListener(_onCatalogScroll);
    _scrollController.dispose();
    _catalogScrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_selectedTab != AppStoreTab.installed) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(appStoreControllerProvider.notifier).loadMore();
    }
  }

  void _onCatalogScroll() {
    if (_selectedTab != AppStoreTab.all) return;
    if (_catalogScrollController.position.pixels >=
        _catalogScrollController.position.maxScrollExtent - 260) {
      ref.read(appCatalogControllerProvider.notifier).loadMore();
    }
  }

  void _onSearch(String value, {bool debounce = true}) {
    _searchDebounce?.cancel();
    if (!debounce || value.isEmpty) {
      _triggerSearch(value);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _triggerSearch(value);
    });
  }

  void _triggerSearch(String value) {
    switch (_selectedTab) {
      case AppStoreTab.installed:
        ref.read(appStoreControllerProvider.notifier).search(value);
      case AppStoreTab.updates:
        ref.read(updateSearchQueryProvider.notifier).state = value;
      case AppStoreTab.all:
      case AppStoreTab.settings:
        ref.read(appCatalogControllerProvider.notifier).search(value);
    }
  }

  void _showSyncLog(String title, String taskID) {
    showTaskLogSheet(
      context,
      title: title,
      taskID: taskID,
      reader: (id) =>
          ref.read(appRepositoryProvider.future).then((r) => r.readTaskLog(id)),
    );
  }

  Future<void> _syncRemote() async {
    final uuid = const Uuid().v4();
    final l10n = context.l10n;
    try {
      await ref.read(appStoreControllerProvider.notifier).syncRemoteApps(uuid);
      if (mounted) _showSyncLog(l10n.appStore_syncRemoteApps, uuid);
    } catch (error) {
      _showSyncError(error, l10n.appStore_syncRemoteAppsFailed);
    }
  }

  Future<void> _syncLocal() async {
    final uuid = const Uuid().v4();
    final l10n = context.l10n;
    try {
      await ref.read(appStoreControllerProvider.notifier).syncLocalApps(uuid);
      if (mounted) _showSyncLog(l10n.appStore_syncLocalApps, uuid);
    } catch (error) {
      _showSyncError(error, l10n.appStore_syncLocalAppsFailed);
    }
  }

  void _showSyncError(Object error, String fallback) {
    final message = switch (error) {
      AppNetworkException(:final message) => message,
      _ => fallback,
    };
    showAppErrorToast(message);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(appStoreControllerProvider);

    return FrostedScaffold(
      title: _isSearching ? '' : context.l10n.appStore_title,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: context.l10n.appStore_searchPlaceholder,
            onChanged: (v) => _onSearch(v, debounce: true),
            onSubmitted: (v) => _onSearch(v, debounce: false),
            onClear: () => _onSearch('', debounce: false),
            onCancel: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              _onSearch('', debounce: false);
            },
          );
        }

        if (_selectedTab == AppStoreTab.settings) {
          return const SizedBox.shrink();
        }

        return FrostedOverlayMenuButton(
          label: context.l10n.common_menu,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: context.l10n.appStore_searchApps,
              icon: TablerIcons.search,
              action: () {
                setState(() {
                  _isSearching = true;
                  if (_selectedTab == AppStoreTab.settings) {
                    _selectedTab = AppStoreTab.all;
                  }
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocusNode.requestFocus();
                });
              },
            ),
            FrostedMenuItem(
              text: context.l10n.appStore_syncRemoteApps,
              icon: TablerIcons.cloud_download,
              action: _syncRemote,
            ),
            FrostedMenuItem(
              text: context.l10n.appStore_syncLocalApps,
              icon: TablerIcons.refresh,
              action: _syncLocal,
            ),
            if (_selectedTab == AppStoreTab.updates)
              FrostedMenuItem(
                text: context.l10n.appStore_viewIgnoredApps,
                icon: TablerIcons.bell_off,
                action: () => showAppIgnoredSheet(context),
              ),
          ],
        );
      },
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedTab.index,
            children: [
              InstalledAppsTab(
                scrollController: _scrollController,
                serverId: widget.serverId,
              ),
              AllAppsTab(
                scrollController: _catalogScrollController,
                serverId: widget.serverId,
              ),
              UpdatesTab(serverId: widget.serverId),
              const AppSettingsTab(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingTabBar(
              items: [
                FloatingTabItemData(
                  icon: TablerIcons.download,
                  activeIcon: TablerIcons.download,
                  label: context.l10n.nav_installed,
                  nativeSymbol: 'arrow.down.circle.fill',
                ),
                FloatingTabItemData(
                  icon: TablerIcons.apps,
                  activeIcon: TablerIcons.apps_filled,
                  label: context.l10n.nav_all,
                  nativeSymbol: 'square.grid.2x2.fill',
                ),
                FloatingTabItemData(
                  icon: TablerIcons.arrow_up,
                  activeIcon: TablerIcons.arrow_up,
                  label: context.l10n.nav_updates,
                  nativeSymbol: 'arrow.up.circle.fill',
                  showDot: asyncState.valueOrNull?.hasUpdates ?? false,
                ),
                FloatingTabItemData(
                  icon: TablerIcons.settings,
                  activeIcon: TablerIcons.settings_filled,
                  label: context.l10n.nav_settings,
                  nativeSymbol: 'gearshape.fill',
                ),
              ],
              selectedIndex: _selectedTab.index,
              onTabSelected: (index) {
                setState(() => _selectedTab = AppStoreTab.values[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
