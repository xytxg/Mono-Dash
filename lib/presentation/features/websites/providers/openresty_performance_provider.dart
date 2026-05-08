import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../../../data/dto/website/openresty_performance_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

final openrestyPerformanceControllerProvider =
    AutoDisposeAsyncNotifierProvider<OpenRestyPerformanceController,
        List<OpenRestyPerformanceItemDto>>(
  OpenRestyPerformanceController.new,
  dependencies: [activeServerIdProvider, websiteRepositoryProvider],
);

class OpenRestyPerformanceController
    extends AutoDisposeAsyncNotifier<List<OpenRestyPerformanceItemDto>> {
  @override
  Future<List<OpenRestyPerformanceItemDto>> build() async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getOpenRestyPerformance();
  }

  Future<void> save(Map<String, String> params) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateOpenRestyPerformance(params);
    ref.invalidateSelf();
    await future;
  }
}
