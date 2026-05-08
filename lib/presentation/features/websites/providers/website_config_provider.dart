import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_config_file_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_config_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteConfigController extends _$WebsiteConfigController {
  @override
  Future<WebsiteConfigFileDto> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteConfig(websiteId);
  }

  Future<bool> updateConfig(String content) async {
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.updateWebsiteConfig(websiteId, content);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
