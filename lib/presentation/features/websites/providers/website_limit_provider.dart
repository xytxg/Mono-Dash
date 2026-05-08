import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_limit_config_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_limit_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteLimitController extends _$WebsiteLimitController {
  @override
  Future<WebsiteLimitConfigDto> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteLimitConfig(websiteId);
  }

  Future<void> save({
    required bool enable,
    required int perServerLimit,
    required int perIpLimit,
    required int rateKb,
  }) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteLimitConfig(
      websiteId,
      enable: enable,
      perServerLimit: perServerLimit,
      perIpLimit: perIpLimit,
      rateKb: rateKb,
    );
    state = AsyncData(await repo.getWebsiteLimitConfig(websiteId));
  }
}
