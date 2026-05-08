import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_cors_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_cors_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteCorsController extends _$WebsiteCorsController {
  @override
  FutureOr<WebsiteCorsDto> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteCors(websiteId);
  }

  Future<void> updateCors(WebsiteCorsDto req) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteCors(req);
    ref.invalidateSelf();
    await future;
  }
}
