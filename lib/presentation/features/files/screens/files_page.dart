import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/frosted_header.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../server_detail/widgets/menus/files_overlay_menu.dart';
import '../models/files_view_state.dart';
import '../providers/files_provider.dart';
import '../widgets/file_list_item.dart';
import '../widgets/file_path_bar.dart';
import '../widgets/file_multi_select_bar.dart';

class StandaloneFilesPage extends ConsumerStatefulWidget {
  const StandaloneFilesPage({super.key, required this.initialPath});

  final String initialPath;

  @override
  ConsumerState<StandaloneFilesPage> createState() =>
      _StandaloneFilesPageState();
}

class _StandaloneFilesPageState extends ConsumerState<StandaloneFilesPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  bool _isSearchMode = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _searchFilesDebounced(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref.read(filesControllerProvider.notifier).search(value);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    ref.read(filesControllerProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      child: Stack(
        children: [
          FilesPage(tabBarVisible: false, initialPath: widget.initialPath),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FrostedHeader(
              title: _isSearchMode ? '' : context.l10n.files_title,
              onBack: _isSearchMode
                  ? null
                  : () => Navigator.of(context).maybePop(),
              trailingBuilder: _buildTrailing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(bool isDark, bool isOverlapping) {
    if (_isSearchMode) {
      return AppHeaderSearchField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        placeholder: context.l10n.files_searchPlaceholder,
        onChanged: _searchFilesDebounced,
        onClear: () {
          _searchDebounce?.cancel();
          ref.read(filesControllerProvider.notifier).search('');
        },
        onCancel: () {
          setState(() => _isSearchMode = false);
          _clearSearch();
        },
      );
    }

    return FilesOverlayMenu(
      isDark: isDark,
      isOverlapping: isOverlapping,
      onSearchModeEnter: () {
        setState(() => _isSearchMode = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _searchFocusNode.requestFocus();
        });
      },
    );
  }
}

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key, required this.tabBarVisible, this.initialPath});

  final bool tabBarVisible;
  final String? initialPath;

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isOverlapping = false;
  bool _initialNavigationDone = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FilesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPath != widget.initialPath) {
      _initialNavigationDone = false;
    }
  }

  void _maybeNavigateToInitialPath(FilesViewState? state) {
    final targetPath = widget.initialPath?.trim();
    if (_initialNavigationDone || targetPath == null || targetPath.isEmpty) {
      return;
    }
    if (state == null || state.isLoading) return;

    _initialNavigationDone = true;
    if (state.currentPath == targetPath) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(filesControllerProvider.notifier).navigateTo(targetPath);
    });
  }

  void _onScroll() {
    final overlapping =
        _scrollController.hasClients && _scrollController.offset > 10;
    if (overlapping != _isOverlapping) {
      setState(() => _isOverlapping = overlapping);
    }

    // 触底加载更多
    final state = ref.read(filesControllerProvider).valueOrNull;
    if (state == null || state.isLoading) return;

    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (currentScroll >= maxScroll - 200) {
        ref.read(filesControllerProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(filesControllerProvider);
    final topPadding = FrostedScaffold.contentTopPadding(context);

    ref.listen(filesControllerProvider, (previous, next) {
      final prevState = previous?.valueOrNull;
      final nextState = next.valueOrNull;

      _maybeNavigateToInitialPath(nextState);

      if (nextState == null || !_scrollController.hasClients) return;

      final pathChanged = prevState?.currentPath != nextState.currentPath;
      final loadingFinished =
          (prevState?.isLoading ?? false) && !nextState.isLoading;

      if (pathChanged || loadingFinished) {
        final targetOffset =
            nextState.scrollOffsets[nextState.currentPath] ?? 0.0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(targetOffset);
          }
        });
      }
    });

    _maybeNavigateToInitialPath(asyncState.valueOrNull);

    final isSelectionMode = asyncState.valueOrNull?.isSelectionMode ?? false;
    final bottomPadding = isSelectionMode
        ? (widget.tabBarVisible ? 200.0 : 140.0)
        : 100.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: PrimaryScrollController(
        controller: _scrollController,
        child: Stack(
          children: [
            // 1. 内容层 (列表)
            CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () =>
                      ref.read(filesControllerProvider.notifier).refresh(),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: topPadding + 58, // 导航栏 + 路径栏高度
                  ),
                ),
                asyncState.when(
                  data: (state) {
                    if (state.isLoading) {
                      return _buildFilesSkeleton(bottomPadding, state.viewMode);
                    }
                    if (state.items.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }

                    if (state.viewMode == FileViewMode.icon) {
                      return _buildIconGrid(state, bottomPadding);
                    }

                    return _buildList(state, bottomPadding);
                  },
                  loading: () => _buildFilesSkeleton(
                    bottomPadding,
                    asyncState.valueOrNull?.viewMode ?? FileViewMode.list,
                  ),
                  error: (err, _) =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
              ],
            ),

            // 2. 空状态/加载/错误 覆盖层 (固定在中心)
            asyncState.when(
              data: (state) {
                if (state.items.isNotEmpty || state.isLoading) {
                  return const SizedBox.shrink();
                }
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: topPadding + 58),
                    child: AppEmptyState(
                      icon: CupertinoIcons.folder_badge_minus,
                      title: state.searchText.isEmpty
                          ? context.l10n.files_directoryEmptyTitle
                          : context.l10n.files_noSearchResultsTitle,
                      subtitle: state.searchText.isEmpty
                          ? context.l10n.files_directoryEmptySubtitle
                          : context.l10n.files_noSearchResultsSubtitle,
                      useCardStyle: false,
                      padding: const EdgeInsets.only(bottom: 40),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, _) => Center(
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding + 58),
                  child: AppErrorState(
                    title: context.l10n.files_loadFailed,
                    error: err,
                    onRetry: () =>
                        ref.read(filesControllerProvider.notifier).refresh(),
                  ),
                ),
              ),
            ),

            // 3. 粘性路径导航栏
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              child: FilePathBar(overlaps: _isOverlapping),
            ),

            // 4. 多选操作悬浮条 (根据 TabBar 状态动态调整位置)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              left: 0,
              right: 0,
              bottom: widget.tabBarVisible ? 104 : 32,
              child: const FileMultiSelectBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(FilesViewState state, double bottomPadding) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(0, 4, 0, bottomPadding),
      sliver: SliverList.builder(
        itemCount: state.items.length + (state.isLoadingMore ? 3 : 0),
        itemBuilder: (context, index) {
          if (index < state.items.length) {
            return FileListItem(item: state.items[index]);
          }
          return _buildSingleSkeletonItem(context, index - state.items.length);
        },
      ),
    );
  }

  Widget _buildIconGrid(FilesViewState state, double bottomPadding) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 126,
          mainAxisExtent: 142,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 6 : 0),
        itemBuilder: (context, index) {
          if (index < state.items.length) {
            return FileListItem(
              item: state.items[index],
              viewMode: FileViewMode.icon,
            );
          }
          return _buildIconSkeletonItem(context, index - state.items.length);
        },
      ),
    );
  }

  Widget _buildFilesSkeleton(double bottomPadding, FileViewMode viewMode) {
    if (viewMode == FileViewMode.icon) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 126,
            mainAxisExtent: 142,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 18,
          itemBuilder: _buildIconSkeletonItem,
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(0, 4, 0, bottomPadding),
      sliver: SliverList.builder(
        itemCount: 12,
        itemBuilder: _buildSingleSkeletonItem,
      ),
    );
  }

  Widget _buildIconSkeletonItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      child: Column(
        children: [
          const SkeletonItem(width: 44, height: 44, borderRadius: 10),
          const SizedBox(height: 10),
          SkeletonItem(
            width: 76 + (index % 3) * 10.0,
            height: 12,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          const SkeletonItem(width: 64, height: 10, borderRadius: 3),
          const SizedBox(height: 5),
          const SkeletonItem(width: 54, height: 10, borderRadius: 3),
        ],
      ),
    );
  }

  Widget _buildSingleSkeletonItem(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.separator(context).withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const SkeletonItem(width: 32, height: 32, borderRadius: 8),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonItem(
                  width: 120 + (index % 3) * 40.0,
                  height: 14,
                  borderRadius: 4,
                ),
                const SizedBox(height: 6),
                const SkeletonItem(width: 180, height: 10, borderRadius: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
