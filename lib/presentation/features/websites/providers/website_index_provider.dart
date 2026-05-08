import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_index_config_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_index_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteIndexController extends _$WebsiteIndexController {
  @override
  Future<WebsiteIndexConfigDto> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteIndexConfig(websiteId);
  }

  Future<void> saveIndexFiles(List<String> indexFiles) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteIndexConfig(websiteId, indexFiles);
    state = AsyncData(await repo.getWebsiteIndexConfig(websiteId));
  }
}
