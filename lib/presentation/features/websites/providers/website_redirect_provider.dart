import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_redirect_dto.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_redirect_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteRedirectController extends _$WebsiteRedirectController {
  @override
  FutureOr<List<WebsiteRedirectDto>> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteRedirects(websiteId);
  }

  Future<void> updateRedirect(Map<String, dynamic> req) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteRedirect(req);
    state = AsyncData(await repo.getWebsiteRedirects(websiteId));
  }

  Future<void> saveRedirectFile(String name, String content) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.saveWebsiteRedirectFile(websiteId, name, content);
    state = AsyncData(await repo.getWebsiteRedirects(websiteId));
  }

  Future<List<WebsiteDomainDto>> fetchDomains() async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    return repo.listDomains(websiteId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(websiteRepositoryProvider.future);
      return repo.getWebsiteRedirects(websiteId);
    });
  }
}
