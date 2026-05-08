import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/frosted_filter_bar.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../containers/widgets/container_log_sheet.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/runtime_provider.dart';
import '../widgets/runtime_card.dart';
import '../widgets/runtime_action_sheet.dart';
import '../widgets/runtime_base_sheet.dart';

class RuntimePage extends StatelessWidget {
  const RuntimePage({
    super.key,
    required this.serverId,
    required this.onOpenFilesPath,
  });

  final int serverId;
  final ValueChanged<String> onOpenFilesPath;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: _RuntimeContent(onOpenFilesPath: onOpenFilesPath),
    );
  }
}

const _typeLabels = {
  'php': 'PHP',
  'java': 'Java',
  'node': 'Node.js',
  'go': 'Go',
  'python': 'Python',
  'dotnet': '.NET',
};

const _typeIcons = {
  'php': TablerIcons.brand_php,
  'java': TablerIcons.coffee,
  'node': TablerIcons.brand_nodejs,
  'go': TablerIcons.brand_golang,
  'python': TablerIcons.brand_python,
  'dotnet': TablerIcons.brand_c_sharp,
};

class _RuntimeContent extends ConsumerStatefulWidget {
  const _RuntimeContent({required this.onOpenFilesPath});

  final ValueChanged<String> onOpenFilesPath;

  @override
  ConsumerState<_RuntimeContent> createState() => _RuntimeContentState();
}

class _RuntimeContentState extends ConsumerState<_RuntimeContent> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _selectedType = '';
  bool _filterOverlaps = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(RuntimeCreateReq req) async {
    final repo = await ref.read(runtimeRepositoryProvider.future);
    if (req.id != null) {
      await repo.updateRuntime(req);
    } else {
      await repo.createRuntime(req);
    }
    ref.read(runtimeControllerProvider.notifier).refresh();
  }

  void _openCreateSheet(String type) {
    showRuntimeSheet(context, type: type, onSubmit: _onSubmit);
  }

  void _openActionSheet(RuntimeDto item) {
    showRuntimeActionSheet(
      context,
      item: item,
      onOperate: (id, operate) async {
        await ref
            .read(runtimeControllerProvider.notifier)
            .operate(context, id, operate);
      },
      onDelete: (id, name) async {
        await ref.read(runtimeControllerProvider.notifier).delete(id);
      },
      onEdit: () async {
        final repo = await ref.read(runtimeRepositoryProvider.future);
        final detail = await repo.getRuntime(item.id);
        if (!mounted) return;
        showRuntimeSheet(
          context,
          type: item.type,
          editItem: detail,
          onSubmit: _onSubmit,
        );
      },
      onShowLog: () {
        final containerName = _runtimeContainerName(item);
        if (containerName.isEmpty) {
          showAppWarningToast(context.l10n.runtime_containerNameMissing);
          return;
        }
        showContainerLogSheet(
          context,
          containerName: containerName,
          displayName: item.name.isEmpty ? containerName : item.name,
          initialFollow: true,
        );
      },
      onShowBuildLog: () {
        showTaskLogSheet(
          context,
          title: context.l10n.runtime_buildLogTitle(item.name),
          taskID: '${item.id}',
          reader: (_) async {
            final repo = await ref.read(runtimeRepositoryProvider.future);
            return repo.readRuntimeLog(id: item.id, type: item.type);
          },
        );
      },
    );
  }

  String _runtimeContainerName(RuntimeDto item) {
    final fromParams = item.params?['CONTAINER_NAME']?.toString().trim() ?? '';
    if (fromParams.isNotEmpty) return fromParams;
    return item.containerName.trim();
  }

  List<FrostedMenuItem> _buildCreateMenuItems() {
    return runtimeTypes
        .map(
          (type) => FrostedMenuItem(
            text: _typeLabels[type] ?? type,
            icon: _typeIcons[type] ?? TablerIcons.server_2,
            action: () => _openCreateSheet(type),
          ),
        )
        .toList();
  }

  void _selectType(String type) {
    if (_selectedType == type) return;
    setState(() {
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
        ref.read(runtimeControllerProvider.notifier).search('');
      }
      _selectedType = type;
      _filterOverlaps = false;
    });
    if (type.isNotEmpty) {
      ref.read(runtimeControllerProvider.notifier).loadType(type);
    }
  }

  bool _handleListScroll(ScrollNotification notification) {
    final overlaps = notification.metrics.pixels > 12;
    if (overlaps != _filterOverlaps) {
      setState(() => _filterOverlaps = overlaps);
    }

    if (notification is ScrollEndNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
      ref
          .read(runtimeControllerProvider.notifier)
          .loadMore(type: _selectedType.isEmpty ? null : _selectedType);
    }
    return false;
  }

  Widget _buildFilterBar(double topPadding) {
    if (_isSearching) return const SizedBox.shrink();
    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: FrostedFilterBar(
        items: [
          FilterItem(
            label: context.l10n.runtime_all,
            value: '',
            icon: TablerIcons.layout_grid,
          ),
          const FilterItem(
            label: 'PHP',
            value: 'php',
            icon: TablerIcons.brand_php,
          ),
          const FilterItem(
            label: 'Java',
            value: 'java',
            icon: TablerIcons.coffee,
          ),
          const FilterItem(
            label: 'Node.js',
            value: 'node',
            icon: TablerIcons.brand_nodejs,
          ),
          const FilterItem(
            label: 'Go',
            value: 'go',
            icon: TablerIcons.brand_golang,
          ),
          const FilterItem(
            label: 'Python',
            value: 'python',
            icon: TablerIcons.brand_python,
          ),
          const FilterItem(
            label: '.NET',
            value: 'dotnet',
            icon: TablerIcons.brand_c_sharp,
          ),
        ],
        selectedValue: _selectedType,
        overlaps: _filterOverlaps,
        onSelected: _selectType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(runtimeControllerProvider);
    final notifier = ref.read(runtimeControllerProvider.notifier);

    return FrostedScaffold(
      title: _isSearching ? '' : context.l10n.runtime_title,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: context.l10n.runtime_searchPlaceholder,
            onChanged: notifier.search,
            onClear: () => notifier.search(''),
            onCancel: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              notifier.search('');
            },
          );
        }

        return FrostedOverlayMenuButton(
          label: context.l10n.runtime_action,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: context.l10n.runtime_new,
              icon: TablerIcons.plus,
              iconColor: CupertinoColors.systemGreen,
              action: () {},
              children: _buildCreateMenuItems(),
            ),
            FrostedMenuItem(
              text: context.l10n.common_search,
              icon: TablerIcons.search,
              action: () {
                setState(() {
                  _isSearching = true;
                  _selectedType = '';
                  _filterOverlaps = false;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocusNode.requestFocus();
                });
              },
            ),
            FrostedMenuItem(
              text: context.l10n.common_refresh,
              icon: TablerIcons.refresh,
              action: notifier.refresh,
            ),
          ],
        );
      },
      body: stateAsync.when(
        loading: () {
          final topPadding = FrostedScaffold.contentTopPadding(context);
          final topPad = topPadding + (_isSearching ? 12 : 62);
          return Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.only(top: topPad, bottom: 40),
                itemCount: 5,
                itemBuilder: (_, _) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SkeletonItem(width: double.infinity, height: 80),
                ),
              ),
              _buildFilterBar(topPadding),
            ],
          );
        },
        error: (e, _) {
          final topPadding = FrostedScaffold.contentTopPadding(context);
          final topPad = topPadding + (_isSearching ? 12 : 58);
          return Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: topPad),
                  child: AppEmptyState(
                    icon: TablerIcons.alert_triangle,
                    title: context.l10n.common_loadingFailed,
                    subtitle: e.toString(),
                  ),
                ),
              ),
              _buildFilterBar(topPadding),
            ],
          );
        },
        data: (state) {
          final topPadding = FrostedScaffold.contentTopPadding(context);
          final topPad = topPadding + (_isSearching ? 12 : 62);
          final items = _selectedType.isEmpty
              ? state.items
              : state.typeStates[_selectedType]?.items ?? const <RuntimeDto>[];
          final isLoadingMore = _selectedType.isEmpty
              ? state.isLoadingMore
              : state.typeStates[_selectedType]?.isLoadingMore ?? false;
          final isFirstLoading =
              _selectedType.isNotEmpty &&
              (state.typeStates[_selectedType]?.isLoading ?? false);
          final selectedLabel = _typeLabels[_selectedType] ?? '';

          if (isFirstLoading) {
            return Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(top: topPad, bottom: 40),
                  itemCount: 5,
                  itemBuilder: (_, _) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SkeletonItem(width: double.infinity, height: 80),
                  ),
                ),
                _buildFilterBar(topPadding),
              ],
            );
          }

          if (items.isEmpty) {
            return Stack(
              children: [
                CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () async => ref
                          .read(runtimeControllerProvider.notifier)
                          .refresh(),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: topPad)),
                    SliverFillRemaining(
                      child: AppEmptyState(
                        icon: _selectedType.isEmpty
                            ? TablerIcons.server_2
                            : _typeIcons[_selectedType] ?? TablerIcons.server_2,
                        title: _selectedType.isEmpty
                            ? state.searchQuery.isEmpty
                                  ? context.l10n.runtime_emptyTitle
                                  : context.l10n.runtime_noSearchResults
                            : context.l10n.runtime_emptyTypeTitle(
                                selectedLabel,
                              ),
                        subtitle: _selectedType.isEmpty
                            ? state.searchQuery.isEmpty
                                  ? context.l10n.runtime_emptySubtitle
                                  : context.l10n.runtime_noSearchResultsSubtitle
                            : context.l10n.runtime_emptyTypeSubtitle(
                                selectedLabel,
                              ),
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        useCardStyle: false,
                      ),
                    ),
                  ],
                ),
                _buildFilterBar(topPadding),
              ],
            );
          }

          return Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: _handleListScroll,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () async => ref
                          .read(runtimeControllerProvider.notifier)
                          .refresh(),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(top: topPad, bottom: 40),
                      sliver: SliverList.builder(
                        itemCount: items.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == items.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          }
                          final item = items[index];
                          return RuntimeCard(
                            item: item,
                            onTap: () => _openActionSheet(item),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildFilterBar(topPadding),
            ],
          );
        },
      ),
    );
  }
}
