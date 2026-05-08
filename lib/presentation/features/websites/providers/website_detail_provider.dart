import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_detail_provider.g.dart';

@Riverpod(dependencies: [websiteRepository])
Future<WebsiteDetailDto> websiteDetail(
  WebsiteDetailRef ref,
  int websiteId,
) async {
  final repo = await ref.watch(websiteRepositoryProvider.future);
  return repo.getWebsite(websiteId);
}
