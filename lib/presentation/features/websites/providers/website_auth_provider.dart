import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/dto/website/website_auth_dto.dart';
import '../../../../data/dto/website/website_auth_req.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_auth_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteAuthController extends _$WebsiteAuthController {
  @override
  Future<WebsiteAuthDto> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteAuth(websiteId);
  }

  Future<void> refresh() async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    state = AsyncData(await repo.getWebsiteAuth(websiteId));
  }

  Future<void> updateAuth(WebsiteAuthUpdateReq req) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteAuth(req);
    await refresh();
  }

  Future<void> setEnabled(bool enabled) async {
    await updateAuth(WebsiteAuthUpdateReq(
      websiteId: websiteId,
      operate: enabled ? 'enable' : 'disable',
    ));
  }

  Future<void> deleteAccount(String username) async {
    await updateAuth(WebsiteAuthUpdateReq(
      websiteId: websiteId,
      operate: 'delete',
      username: username,
    ));
  }
}

@Riverpod(dependencies: [websiteRepository])
class WebsitePathAuthController extends _$WebsitePathAuthController {
  @override
  Future<List<WebsitePathAuthItemDto>> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.listWebsitePathAuths(websiteId);
  }

  Future<void> refresh() async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    state = AsyncData(await repo.listWebsitePathAuths(websiteId));
  }

  Future<void> updatePathAuth(WebsitePathAuthUpdateReq req) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsitePathAuth(req);
    await refresh();
  }

  Future<void> deletePathAuth({
    required String path,
    required String name,
    required String username,
    required String remark,
  }) async {
    await updatePathAuth(WebsitePathAuthUpdateReq(
      websiteId: websiteId,
      path: path,
      name: name,
      username: username,
      remark: remark,
      operate: 'delete',
      password: '', // Password not needed for delete
    ));
  }
}
