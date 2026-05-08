import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../../common/components/file_browser_picker_sheet.dart';
import '../models/image_list_state.dart';
import '../widgets/image_prune_sheet.dart';

final imageListControllerProvider =
    StateNotifierProvider.autoDispose<
      ImageListController,
      AsyncValue<ImageListState>
    >((ref) {
      return ImageListController(ref);
    }, dependencies: [containerRepositoryProvider]);

class ImageListController extends StateNotifier<AsyncValue<ImageListState>> {
  ImageListController(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;
  final _searchDebounce = Debouncer();

  Future<void> _init() async {
    final nextState = await AsyncValue.guard(() async {
      final repo = await ref.read(containerRepositoryProvider.future);
      if (!mounted) return const ImageListState();

      final searchResult = await repo.searchImages(
        const PageImageReq(page: 1, pageSize: 20),
      );

      return ImageListState(
        images: searchResult.items,
        total: searchResult.total,
      );
    });

    if (!mounted) return;
    state = nextState;
  }

  @override
  void dispose() {
    _searchDebounce.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return _init();
    }

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      if (!mounted) return;

      final searchResult = await repo.searchImages(
        PageImageReq(
          page: 1,
          pageSize: currentState.pageSize,
          name: currentState.searchQuery,
        ),
      );

      if (!mounted) return;

      state = AsyncValue.data(
        currentState.copyWith(
          images: searchResult.items,
          total: searchResult.total,
          page: 1,
        ),
      );
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.images.length >= currentState.total) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      if (!mounted) return;

      final searchResult = await repo.searchImages(
        PageImageReq(
          page: currentState.page + 1,
          pageSize: currentState.pageSize,
          name: currentState.searchQuery,
        ),
      );

      if (!mounted) return;

      state = AsyncValue.data(
        currentState.copyWith(
          images: [...currentState.images, ...searchResult.items],
          page: currentState.page + 1,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  void search(String query) {
    _searchDebounce(() {
      final currentState = state.valueOrNull;
      if (currentState == null) return;

      state = AsyncValue.data(
        currentState.copyWith(searchQuery: query, page: 1),
      );

      _triggerFetch();
    });
  }

  void toggleSearchMode() {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final isSearching = !currentState.isSearching;
    state = AsyncValue.data(currentState.copyWith(isSearching: isSearching));

    if (!isSearching && currentState.searchQuery.isNotEmpty) {
      search(''); // Reset search if exiting search mode
    }
  }

  Future<void> _triggerFetch() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      if (!mounted) return;

      final searchResult = await repo.searchImages(
        PageImageReq(
          page: 1,
          pageSize: currentState.pageSize,
          name: currentState.searchQuery,
        ),
      );

      if (!mounted) return;

      state = AsyncValue.data(
        currentState.copyWith(
          images: searchResult.items,
          total: searchResult.total,
        ),
      );
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pruneImages(BuildContext context) async {
    showImagePruneSheet(context);
  }

  Future<void> pruneBuildCache(BuildContext context) async {
    final titleText = context.l10n.containers_pruneBuildCache;
    final operationFailedText = context.l10n.containers_operationFailed;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: titleText,
      icon: TablerIcons.trash,
      content: context.l10n.containers_pruneBuildCacheConfirm,
      isDestructive: true,
    );

    if (confirmed != true) return;

    final taskID = const Uuid().v4();
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.pruneContainers(
        taskID: taskID,
        pruneType: 'buildcache',
        withTagAll: true,
      );

      if (context.mounted) {
        showTaskLogSheet(
          context,
          title: titleText,
          taskID: taskID,
          reader: repo.readTaskLog,
          onFinished: refresh,
        );
      }
    } catch (e) {
      showAppErrorToast(operationFailedText, description: e.toString());
    }
  }

  Future<void> deleteImages(
    BuildContext context,
    List<String> ids, {
    String? displayName,
  }) async {
    final isBatch = ids.length > 1;
    final nameToDisplay =
        displayName ??
        (isBatch ? context.l10n.containers_imageCount(ids.length) : ids.first);
    final deleteFailedText = context.l10n.containers_deleteFailed;

    final confirmed = await showFrostedConfirmDialog(
      context,
      title: isBatch
          ? context.l10n.containers_batchDeleteImages
          : context.l10n.containers_deleteImage,
      icon: TablerIcons.trash,
      content: context.l10n.containers_deleteImageConfirm(nameToDisplay),
      isDestructive: true,
    );

    if (confirmed != true) return;

    final taskID = const Uuid().v4();
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.removeImage(
        BatchDeleteReq(taskID: taskID, names: ids, force: false),
      );

      await refresh();
    } catch (e) {
      showAppErrorToast(deleteFailedText, description: e.toString());
    }
  }

  Future<void> pullImage({
    required BuildContext context,
    required int repoID,
    required List<String> imageNames,
  }) async {
    final taskID = const Uuid().v4();
    final pullImageText = context.l10n.containers_pullImage;
    final pullFailedText = context.l10n.containers_pullFailed;
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.pullImage(
        ImagePullReq(taskID: taskID, repoID: repoID, imageName: imageNames),
      );

      if (context.mounted) {
        Navigator.pop(context);
        showTaskLogSheet(
          context,
          title: pullImageText,
          taskID: taskID,
          reader: repo.readTaskLog,
          onFinished: refresh,
        );
      }
    } catch (e) {
      showAppErrorToast(pullFailedText, description: e.toString());
    }
  }

  // TODO: 暂未测试
  Future<void> loadImage(BuildContext context) async {
    final importImageText = context.l10n.containers_importImage;
    final importFailedText = context.l10n.containers_importFailed;
    final results = await FileBrowserPickerSheet.showMultiple(
      context,
      title: context.l10n.containers_selectImageFile,
      confirmText: context.l10n.containers_import,
      selectionMode: FilePickerSelectionMode.files,
    );

    if (results == null || results.isEmpty) return;

    final paths = results.map((r) => r.path).toList();
    final taskID = const Uuid().v4();

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.loadImage(ImageLoadReq(taskID: taskID, paths: paths));

      if (context.mounted) {
        showTaskLogSheet(
          context,
          title: importImageText,
          taskID: taskID,
          reader: repo.readTaskLog,
          onFinished: refresh,
        );
      }
    } catch (e) {
      showAppErrorToast(importFailedText, description: e.toString());
    }
  }

  // TODO: 暂未测试
  Future<void> buildImage({
    required BuildContext context,
    required String from,
    required String name,
    required String dockerfile,
    required List<String> tags,
    required List<String> args,
  }) async {
    final taskID = const Uuid().v4();
    final buildImageTitle = context.l10n.containers_buildImageTask(name);
    final buildFailedText = context.l10n.containers_buildFailed;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.buildImage(
        ImageBuildReq(
          taskID: taskID,
          from: from,
          name: name,
          dockerfile: dockerfile,
          tags: tags,
          args: args,
        ),
      );

      if (context.mounted) {
        Navigator.pop(context);
        showTaskLogSheet(
          context,
          title: buildImageTitle,
          taskID: taskID,
          reader: repo.readTaskLog,
          onFinished: refresh,
        );
      }
    } catch (e) {
      showAppErrorToast(buildFailedText, description: e.toString());
    }
  }

  Future<void> updateImage(BuildContext context, List<String> tags) async {
    final taskID = const Uuid().v4();
    final updateImageText = context.l10n.containers_updateImage;
    final updateFailedText = context.l10n.containers_updateFailed;
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.pullImage(
        ImagePullReq(taskID: taskID, repoID: 0, imageName: tags),
      );

      if (context.mounted) {
        Navigator.pop(context);
        showTaskLogSheet(
          context,
          title: updateImageText,
          taskID: taskID,
          reader: repo.readTaskLog,
          onFinished: refresh,
        );
      }
    } catch (e) {
      showAppErrorToast(updateFailedText, description: e.toString());
    }
  }
}
