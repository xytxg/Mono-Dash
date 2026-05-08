import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_group_dto.dart';
import '../../../../data/dto/website/website_update_req.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_other_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
Future<List<WebsiteGroupDto>> websiteGroups(WebsiteGroupsRef ref) async {
  final repo = await ref.watch(websiteRepositoryProvider.future);
  return repo.searchWebsiteGroups();
}

@Riverpod(dependencies: [websiteRepository])
class WebsiteOtherController extends _$WebsiteOtherController {
  @override
  Future<void> build(int websiteId) async {}

  Future<void> save(WebsiteUpdateReq req) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.updateWebsite(req);
    });
  }
}
