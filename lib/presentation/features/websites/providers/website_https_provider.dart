import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_https_dto.dart';
import '../../../../data/dto/website/website_acme_account_dto.dart';
import '../../../../data/dto/website/website_ssl_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_https_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteHttpsController extends _$WebsiteHttpsController {
  @override
  FutureOr<WebsiteHttpsDto> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteHttps(websiteId);
  }

  Future<void> updateHttps(Map<String, dynamic> req) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteHttps(websiteId, req);
    state = AsyncData(await repo.getWebsiteHttps(websiteId));
  }

  Future<List<WebsiteAcmeAccountDto>> fetchAcmeAccounts() async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    return repo.searchAcmeAccounts();
  }

  Future<List<WebsiteSslDto>> fetchCertificates(int acmeAccountId) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    return repo.listWebsiteSsl(acmeAccountId);
  }
}
