import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../models/container_compose_state.dart';

part 'container_compose_provider.g.dart';

@Riverpod(dependencies: [containerRepository])
class ContainerComposeController extends _$ContainerComposeController {
  final _searchDebounce = Debouncer();

  @override
  FutureOr<ContainerComposeState> build() async {
    final repo = await ref.watch(containerRepositoryProvider.future);
    final data = await repo.searchCompose();
    return ContainerComposeState(
      items: data.items,
      total: data.total,
    );
  }

  Future<void> refresh() async {
    // 如果已经在加载中，不要设置为 loading 态，避免闪烁（保持当前数据）
    final current = state.valueOrNull;
    if (current == null) {
      state = const AsyncLoading();
    }
    
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(containerRepositoryProvider.future);
      final data = await repo.searchCompose(
        info: state.valueOrNull?.searchQuery ?? '',
        page: state.valueOrNull?.page ?? 1,
        pageSize: state.valueOrNull?.pageSize ?? 100,
      );
      return (state.valueOrNull ?? const ContainerComposeState()).copyWith(
        items: data.items,
        total: data.total,
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
}
