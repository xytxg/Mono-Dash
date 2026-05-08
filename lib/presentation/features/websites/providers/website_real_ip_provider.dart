import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_real_ip_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_real_ip_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteRealIpController extends _$WebsiteRealIpController {
  @override
  FutureOr<WebsiteRealIpDto> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteRealIp(websiteId);
  }

  Future<void> updateRealIp(WebsiteRealIpDto req) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteRealIp(req);
    ref.invalidateSelf();
    await future;
  }
}
