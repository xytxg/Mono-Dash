import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/repositories_impl/website_repository_impl.dart';

part 'website_rewrite_provider.g.dart';

class WebsiteRewriteState {
  const WebsiteRewriteState({
    required this.customTemplates,
    required this.currentContent,
  });

  final List<String> customTemplates;
  final String currentContent;

  WebsiteRewriteState copyWith({
    List<String>? customTemplates,
    String? currentContent,
  }) {
    return WebsiteRewriteState(
      customTemplates: customTemplates ?? this.customTemplates,
      currentContent: currentContent ?? this.currentContent,
    );
  }
}

@Riverpod(dependencies: [websiteRepository])
class WebsiteRewriteController extends _$WebsiteRewriteController {
  @override
  FutureOr<WebsiteRewriteState> build(int websiteId) async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    final custom = await repo.getCustomRewriteTemplates();
    final current = await repo.getRewriteContent(websiteId, 'current');
    return WebsiteRewriteState(
      customTemplates: custom,
      currentContent: current,
    );
  }

  Future<String> fetchTemplateContent(String name) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    return repo.getRewriteContent(websiteId, name);
  }

  Future<void> updateRewrite(String name, String content) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.updateRewrite(websiteId, name, content);
    ref.invalidateSelf();
    await future;
  }

  Future<void> saveAsTemplate(String name, String content) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.manageCustomRewrite(name: name, operate: 'create', content: content);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteTemplate(String name) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    await repo.manageCustomRewrite(name: name, operate: 'delete');
    ref.invalidateSelf();
    await future;
  }
}
