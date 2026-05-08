import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client_provider.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../../../data/api/app_api.dart';
import '../../../../data/dto/app/app_service_dto.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../../data/dto/website/website_acme_account_dto.dart';
import '../../../../data/dto/website/website_create_metadata.dart';
import '../../../../data/dto/website/website_create_req.dart';
import '../../../../data/dto/website/website_ssl_dto.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import 'websites_provider.dart';

part 'website_create_provider.g.dart';

@Riverpod(dependencies: [websiteRepository, WebsitesController])
class WebsiteCreateController extends _$WebsiteCreateController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> createWebsite(WebsiteCreateReq req) async {
    state = const AsyncLoading();
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.createWebsite(req);

      // Refresh the list
      ref.read(websitesControllerProvider.notifier).refresh();

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

@Riverpod(dependencies: [websiteRepository])
Future<WebsiteCreateMetadata> websiteCreateMetadata(
  WebsiteCreateMetadataRef ref,
) async {
  final repo = await ref.watch(websiteRepositoryProvider.future);
  return repo.getCreateMetadata();
}

@Riverpod(dependencies: [websiteRepository])
Future<List<WebsiteAcmeAccountDto>> websiteAcmeAccounts(
  WebsiteAcmeAccountsRef ref,
) async {
  final repo = await ref.watch(websiteRepositoryProvider.future);
  return repo.searchAcmeAccounts();
}

@Riverpod(dependencies: [websiteRepository])
Future<List<WebsiteSslDto>> websiteSslList(
  WebsiteSslListRef ref,
  int acmeAccountId,
) async {
  final repo = await ref.watch(websiteRepositoryProvider.future);
  return repo.listWebsiteSsl(acmeAccountId);
}

@Riverpod(dependencies: [runtimeRepository])
Future<List<RuntimeDto>> websiteRuntimes(
  WebsiteRuntimesRef ref,
  String type,
) async {
  final repo = await ref.watch(runtimeRepositoryProvider.future);
  final result = await repo.searchRuntimes({
    'page': 1,
    'pageSize': 100,
    'type': type,
    'status': 'Running',
  });
  return result.items;
}

@Riverpod(dependencies: [activeServerId])
Future<List<AppServiceDto>> websiteDbInstances(
  WebsiteDbInstancesRef ref,
  String key,
) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return AppApi(client).getAppServices(key);
}
