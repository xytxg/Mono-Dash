import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_leech_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_leech_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteLeechController extends _$WebsiteLeechController {
  @override
  FutureOr<WebsiteLeechDto> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteLeech(websiteId);
  }

  Future<void> updateLeech(WebsiteLeechUpdateReq req) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteLeech(req);
    ref.invalidateSelf();
    await future;
  }
}
