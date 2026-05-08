import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_dir_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_dir_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
class WebsiteDirController extends _$WebsiteDirController {
  @override
  Future<WebsiteDirDto> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    return repo.getWebsiteDir(websiteId);
  }

  Future<void> updateSiteDir(String siteDir) async {
    final previous = state.valueOrNull;
    if (previous != null) state = AsyncData(previous);

    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteSiteDir(websiteId, siteDir);
    state = AsyncData(await repo.getWebsiteDir(websiteId));
  }

  Future<void> updatePermission({
    required String user,
    required String group,
  }) async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncData(
        WebsiteDirDto(
          dirs: previous.dirs,
          user: user,
          userGroup: group,
          msg: previous.msg,
        ),
      );
    }

    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateWebsiteDirPermission(websiteId, user: user, group: group);
    state = AsyncData(await repo.getWebsiteDir(websiteId));
  }
}
