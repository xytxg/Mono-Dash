import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_log_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_log_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteLogController extends _$WebsiteLogController {
  @override
  Future<WebsiteLogFileDto> build(int websiteId, WebsiteLogType type) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.readWebsiteLog(websiteId, type);
  }

  Future<void> refresh() async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    state = AsyncData(await repo.readWebsiteLog(websiteId, type));
  }

  Future<void> clear() async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.operateWebsiteLog(websiteId, type: type, operate: 'delete');
    state = AsyncData(await repo.readWebsiteLog(websiteId, type));
  }

  Future<void> setEnabled(bool enabled) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.operateWebsiteLog(
      websiteId,
      type: type,
      operate: enabled ? 'enable' : 'disable',
    );
    state = AsyncData(await repo.readWebsiteLog(websiteId, type));
  }
}
