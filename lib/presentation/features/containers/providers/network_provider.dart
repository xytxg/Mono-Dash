import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/task_log_sheet.dart';
import '../models/network_state.dart';

part 'network_provider.g.dart';

@Riverpod(dependencies: [containerRepository])
class NetworkController extends _$NetworkController {
  final _searchDebounce = Debouncer();

  @override
  FutureOr<NetworkState> build() async {
    final repo = await ref.watch(containerRepositoryProvider.future);
    final data = await repo.searchNetworks();
    return NetworkState(items: data.items, total: data.total);
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    if (current == null) {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(containerRepositoryProvider.future);
      final data = await repo.searchNetworks(
        info: state.valueOrNull?.searchQuery ?? '',
        page: 1,
        pageSize: state.valueOrNull?.pageSize ?? 20,
      );
      return (state.valueOrNull ?? const NetworkState()).copyWith(
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
      final data = await repo.searchNetworks(
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

  Future<void> deleteNetworks(BuildContext context, List<String> names) async {
    final deleteFailedText = context.l10n.containers_deleteFailed;
    final deleteSuccessText = context.l10n.containers_deleteSuccess;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: context.l10n.containers_deleteNetwork,
      icon: TablerIcons.trash,
      content: names.length == 1
          ? context.l10n.containers_deleteNetworkConfirm(names.first)
          : context.l10n.containers_deleteNetworksConfirm(names.length),
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.deleteNetworks(names);
      showAppSuccessToast(deleteSuccessText);
      refresh();
    } catch (e) {
      showAppErrorToast(deleteFailedText, description: e.toString());
    }
  }

  Future<void> pruneNetworks(BuildContext context) async {
    final pruneNetworksText = context.l10n.containers_pruneNetworks;
    final pruneNetworksFailedText = context.l10n.containers_pruneNetworksFailed;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: context.l10n.containers_pruneUnusedNetworks,
      icon: TablerIcons.eraser,
      content: context.l10n.containers_pruneUnusedNetworksConfirm,
    );

    if (confirmed != true) return;

    final taskID = const Uuid().v4();

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.pruneContainers(taskID: taskID, pruneType: 'network');

      if (!context.mounted) return;
      Navigator.pop(context);
      showTaskLogSheet(
        context,
        title: pruneNetworksText,
        taskID: taskID,
        reader: repo.readTaskLog,
        onFinished: refresh,
      );
    } catch (e) {
      showAppErrorToast(pruneNetworksFailedText, description: e.toString());
    }
  }
}
