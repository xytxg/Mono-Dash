import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/frosted_dialog.dart';
import '../models/compose_template_state.dart';

part 'compose_template_provider.g.dart';

@Riverpod(dependencies: [containerRepository])
class ComposeTemplateController extends _$ComposeTemplateController {
  final _searchDebounce = Debouncer();

  @override
  FutureOr<ComposeTemplateState> build() async {
    final repo = await ref.watch(containerRepositoryProvider.future);
    final data = await repo.searchTemplates();
    return ComposeTemplateState(items: data.items, total: data.total);
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    if (current == null) {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(containerRepositoryProvider.future);
      final data = await repo.searchTemplates(
        info: state.valueOrNull?.searchQuery ?? '',
        page: 1,
        pageSize: state.valueOrNull?.pageSize ?? 20,
      );
      return (state.valueOrNull ?? const ComposeTemplateState()).copyWith(
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
      final data = await repo.searchTemplates(
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

  Future<void> deleteTemplates(BuildContext context, List<int> ids) async {
    final isBatch = ids.length > 1;
    final deleteSuccessText = context.l10n.containers_deleteSuccess;
    final deleteFailedText = context.l10n.containers_deleteFailed;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: isBatch
          ? context.l10n.containers_batchDeleteTemplates
          : context.l10n.containers_deleteTemplate,
      icon: TablerIcons.trash,
      content: isBatch
          ? context.l10n.containers_deleteTemplatesConfirm(ids.length)
          : context.l10n.containers_deleteTemplateConfirm,
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.deleteTemplates(ids);
      showAppSuccessToast(deleteSuccessText);
      refresh();
    } catch (e) {
      showAppErrorToast(deleteFailedText, description: e.toString());
    }
  }
}
