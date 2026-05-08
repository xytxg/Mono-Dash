import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/frosted_dialog.dart';
import '../models/ssl_manage_state.dart';

part 'ssl_manage_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class SslManageController extends _$SslManageController {
  final _searchDebounce = Debouncer();

  @override
  FutureOr<SslManageState> build() async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    final data = await repo.searchSsl(const {
      'page': 1,
      'pageSize': 20,
      'orderBy': 'expire_date',
      'order': 'ascending',
    });
    return SslManageState(items: data.items, total: data.total);
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    if (current == null) {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final data = await repo.searchSsl({
        'page': 1,
        'pageSize': state.valueOrNull?.pageSize ?? 20,
        'orderBy': 'expire_date',
        'order': 'ascending',
        if ((state.valueOrNull?.searchQuery ?? '').isNotEmpty)
          'domain': state.valueOrNull!.searchQuery,
      });
      return (state.valueOrNull ?? const SslManageState()).copyWith(
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
      final repo = await ref.read(websiteRepositoryProvider.future);
      final data = await repo.searchSsl({
        'page': current.page + 1,
        'pageSize': current.pageSize,
        'orderBy': 'expire_date',
        'order': 'ascending',
        if (current.searchQuery.isNotEmpty) 'domain': current.searchQuery,
      });

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

  Future<void> deleteSsl(BuildContext context, List<int> ids) async {
    final l10n = context.l10n;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: l10n.websites_deleteCertificate,
      icon: TablerIcons.trash,
      content: ids.length == 1
          ? l10n.websites_deleteCertificateConfirm
          : l10n.websites_deleteCertificatesConfirm(ids.length),
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.deleteSsl(ids);
      showAppSuccessToast(l10n.websites_deleteSuccess);
      refresh();
    } catch (e) {
      showAppErrorToast(l10n.websites_deleteFailed, description: e.toString());
    }
  }

  Future<void> obtainSsl(BuildContext context, int id) async {
    final l10n = context.l10n;
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.obtainSsl(id);
      showAppSuccessToast(l10n.websites_applyTaskSubmitted);
    } catch (e) {
      showAppErrorToast(l10n.websites_applyFailed, description: e.toString());
    }
  }
}
