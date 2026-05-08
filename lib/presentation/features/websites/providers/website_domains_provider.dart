import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/dto/website/website_domain_req.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_domains_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteDomainsController extends _$WebsiteDomainsController {
  @override
  Future<List<WebsiteDomainDto>> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.listDomains(websiteId);
  }

  Future<void> addDomain(WebsiteDomainReq domain) async {
    final previous = state.valueOrNull ?? const <WebsiteDomainDto>[];
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.addDomains(websiteId, [domain]);
      state = AsyncData(await repo.listDomains(websiteId));
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> updateSsl(WebsiteDomainDto domain, bool ssl) async {
    final previous = state.valueOrNull ?? const <WebsiteDomainDto>[];
    state = AsyncData<List<WebsiteDomainDto>>([
      for (final item in previous)
        item.id == domain.id
            ? WebsiteDomainDto(
                id: item.id,
                domain: item.domain,
                port: item.port,
                ssl: ssl,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
              )
            : item,
    ]);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.updateDomainSsl(domain.id, ssl);
      return repo.listDomains(websiteId);
    });
  }

  Future<void> deleteDomain(WebsiteDomainDto domain) async {
    final previous = state.valueOrNull ?? const <WebsiteDomainDto>[];
    if (previous.length <= 1) return;

    state = AsyncData<List<WebsiteDomainDto>>([
      for (final item in previous)
        if (item.id != domain.id) item,
    ]);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.deleteDomain(domain.id);
      return repo.listDomains(websiteId);
    });
  }
}
