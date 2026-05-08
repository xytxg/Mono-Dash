import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/file/file_item_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';

part 'file_editor_provider.g.dart';

@Riverpod(dependencies: [fileRepository])
class FileEditorController extends _$FileEditorController {
  @override
  Future<FileItemDto> build(String path) async {
    final repo = await ref.watch(fileRepositoryProvider.future);
    return repo.getFileContent(path: path);
  }

  Future<void> save(String content) async {
    final repo = await ref.read(fileRepositoryProvider.future);
    await repo.saveFileContent(path: path, content: content);
    ref.invalidateSelf();
  }
}
