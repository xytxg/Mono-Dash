import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../server_detail/widgets/menus/image_overlay_menu.dart';
import '../providers/image_list_provider.dart';
import '../widgets/image_action_sheet.dart';
import '../widgets/image_card.dart';

class ImagesPage extends StatelessWidget {
  const ImagesPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _ImagesContent(),
    );
  }
}

class _ImagesContent extends ConsumerStatefulWidget {
  const _ImagesContent();

  @override
  ConsumerState<_ImagesContent> createState() => _ImagesPageState();
}

class _ImagesPageState extends ConsumerState<_ImagesContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isOverlapping = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onScroll() {
    final overlapping =
        _scrollController.hasClients && _scrollController.offset > 10;
    if (overlapping != _isOverlapping) {
      setState(() => _isOverlapping = overlapping);
    }

    final state = ref.read(imageListControllerProvider).valueOrNull;
    if (state == null || state.isLoadingMore) return;

    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (currentScroll >= maxScroll - 200) {
        ref.read(imageListControllerProvider.notifier).loadMore();
      }
    }
  }

  void _requestSearchFocus() {
    if (!mounted) return;
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(imageListControllerProvider);
    final notifier = ref.read(imageListControllerProvider.notifier);
    final topPadding = FrostedScaffold.contentTopPadding(context);

    final state = asyncState.valueOrNull;
    final isSearching = state?.isSearching ?? false;

    return FrostedScaffold(
      title: isSearching ? '' : context.l10n.containers_images,
      showBackButton: !isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocus,
            placeholder: context.l10n.containers_searchImages,
            onChanged: notifier.search,
            onClear: () => notifier.search(''),
            onCancel: () {
              _searchController.clear();
              _searchFocus.unfocus();
              notifier.toggleSearchMode();
            },
          );
        }

        return ImageOverlayMenu(
          isDark: isDark,
          isOverlapping: isOverlapping,
          onSearchModeEnter: () {
            notifier.toggleSearchMode();
            Future.delayed(
              const Duration(milliseconds: 100),
              _requestSearchFocus,
            );
          },
        );
      },
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(onRefresh: notifier.refresh),
              asyncState.when(
                data: (state) {
                  if (state.images.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(0, topPadding, 0, 100),
                    sliver: SliverList.builder(
                      itemCount:
                          state.images.length + (state.isLoadingMore ? 3 : 0),
                      itemBuilder: (context, index) {
                        if (index < state.images.length) {
                          final image = state.images[index];
                          return ImageCard(
                            image: image,
                            onTap: () =>
                                showImageActionSheet(context, ref, image),
                          );
                        }
                        return _buildSingleSkeletonItem(
                          context,
                          index - state.images.length,
                        );
                      },
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: EdgeInsets.fromLTRB(0, topPadding, 0, 100),
                  sliver: SliverList.builder(
                    itemCount: 8,
                    itemBuilder: _buildSingleSkeletonItem,
                  ),
                ),
                error: (err, _) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            ],
          ),

          asyncState.when(
            data: (state) {
              if (state.images.isNotEmpty || state.isLoadingMore) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: AppEmptyState(
                    icon: CupertinoIcons.photo,
                    title: state.searchQuery.isEmpty
                        ? context.l10n.containers_noImages
                        : context.l10n.containers_noMatchingImages,
                    subtitle: state.searchQuery.isEmpty
                        ? context.l10n.containers_imagesEmptySubtitle
                        : context.l10n.containers_trySearchKeyword,
                    useCardStyle: false,
                    padding: const EdgeInsets.only(bottom: 40),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, _) => Center(
              child: Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: AppErrorState(
                  title: context.l10n.containers_loadImagesFailed,
                  error: err,
                  onRetry: () =>
                      ref.read(imageListControllerProvider.notifier).refresh(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSkeletonItem(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonItem(width: 42, height: 42, borderRadius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonItem(
                      width: 120 + (index % 3) * 40.0,
                      height: 16,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 6),
                    const SkeletonItem(width: 80, height: 12, borderRadius: 3),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              SkeletonItem(width: 40, height: 14, borderRadius: 4),
              Spacer(),
              SkeletonItem(width: 100, height: 12, borderRadius: 3),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonItem(
            width: double.infinity,
            height: 1,
            borderRadius: 0,
          ),
          const SizedBox(height: 12),
          const SkeletonItem(width: 100, height: 16, borderRadius: 4),
        ],
      ),
    );
  }
}
