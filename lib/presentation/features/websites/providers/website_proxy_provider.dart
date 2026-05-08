import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_proxy_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_proxy_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteProxyController extends _$WebsiteProxyController {
  @override
  Future<List<WebsiteProxyDto>> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.listWebsiteProxies(websiteId);
  }

  Future<void> refresh() async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    state = AsyncData(await repo.listWebsiteProxies(websiteId));
  }

  Future<void> saveProxy(Map<String, dynamic> payload) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteProxy(payload);
    state = AsyncData(await repo.listWebsiteProxies(websiteId));
  }

  Future<void> deleteProxy(String name) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.deleteWebsiteProxy(websiteId, name);
    state = AsyncData(await repo.listWebsiteProxies(websiteId));
  }

  Future<void> setStatus(String name, bool enable) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteProxyStatus(
      websiteId,
      name,
      enable ? 'enable' : 'disable',
    );
    state = AsyncData(await repo.listWebsiteProxies(websiteId));
  }

  Future<void> saveProxyFile(String name, String content) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteProxyFile(websiteId, name, content);
    state = AsyncData(await repo.listWebsiteProxies(websiteId));
  }
}
