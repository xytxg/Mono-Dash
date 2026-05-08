import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/frosted_dialog.dart';
import '../models/image_repo_state.dart';

part 'image_repo_provider.g.dart';

@Riverpod(dependencies: [containerRepository])
class ImageRepoController extends _$ImageRepoController {
  final _searchDebounce = Debouncer();

  @override
  FutureOr<ImageRepoState> build() async {
    final repo = await ref.watch(containerRepositoryProvider.future);
    final data = await repo.searchImageRepos();
    return ImageRepoState(items: data.items, total: data.total);
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    if (current == null) {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(containerRepositoryProvider.future);
      final data = await repo.searchImageRepos(
        info: state.valueOrNull?.searchQuery ?? '',
        page: 1,
        pageSize: state.valueOrNull?.pageSize ?? 20,
      );
      return (state.valueOrNull ?? const ImageRepoState()).copyWith(
        items: data.items,
        total: data.total,
        page: 1,
      );
    });
  }

  void search(String query) {
    _searchDebounce(() {
      final current = state.valueOrNull;
      if (current == null) return;

      state = AsyncValue.data(current.copyWith(searchQuery: query, page: 1));
      refresh();
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.isLoadingMore ||
        current.items.length >= current.total) {
      return;
    }

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      final data = await repo.searchImageRepos(
        info: current.searchQuery,
        page: current.page + 1,
        pageSize: current.pageSize,
      );

      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...data.items],
          page: current.page + 1,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteRepo(BuildContext context, int id) async {
    final deleteSuccessText = context.l10n.containers_deleteSuccess;
    final deleteFailedText = context.l10n.containers_deleteFailed;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: context.l10n.containers_deleteRepo,
      icon: TablerIcons.trash,
      content: context.l10n.containers_deleteRepoConfirm,
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.deleteImageRepo(id);
      showAppSuccessToast(deleteSuccessText);
      refresh();
    } catch (e) {
      showAppErrorToast(deleteFailedText, description: e.toString());
    }
  }

  Future<void> syncRepo(BuildContext context, int id) async {
    final syncSuccessText = context.l10n.containers_syncSuccess;
    final syncFailedText = context.l10n.containers_syncFailed;
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.syncImageRepo(id);
      showAppSuccessToast(syncSuccessText);
      refresh();
    } catch (e) {
      showAppErrorToast(syncFailedText, description: e.toString());
    }
  }
}
