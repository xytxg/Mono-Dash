import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../data/api/file_api.dart';
import '../../../../data/repositories_impl/log_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../features/server_detail/providers/active_server_provider.dart';
import '../models/system_log_state.dart';

part 'system_log_provider.g.dart';

@Riverpod(dependencies: [logRepository, activeServerId])
class SystemLogController extends _$SystemLogController {
  @override
  FutureOr<SystemLogState> build() async {
    final repo = await ref.watch(logRepositoryProvider.future);
    final files = await repo.getSystemLogFiles();
    final selectedFile = files.isNotEmpty ? files.first : '';
    String content = '';
    if (selectedFile.isNotEmpty) {
      content = await _readFile(selectedFile, isAgent: true);
    }
    return SystemLogState(
      files: files,
      selectedFile: selectedFile,
      content: content,
      isAgent: true,
    );
  }

  Future<String> _readFile(String fileName, {required bool isAgent}) async {
    final serverId = ref.read(activeServerIdProvider);
    final client = await ref.read(dioClientProvider(serverId).future);
    final fileApi = FileApi(client);

    final name = isAgent ? fileName : 'Core-$fileName';
    final result = await fileApi.readFile<Map<String, dynamic>>(
      type: 'system',
      name: name,
      page: 1,
      pageSize: 500,
      latest: true,
      fromJson: (json) => json,
    );
    return result['content'] as String? ?? result.toString();
  }

  Future<void> selectFile(String fileName) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue.data(
      current.copyWith(selectedFile: fileName, isLoadingContent: true),
    );

    try {
      final content = await _readFile(fileName, isAgent: current.isAgent);
      final updated = state.valueOrNull;
      if (updated == null) return;
      state = AsyncValue.data(
        updated.copyWith(content: content, isLoadingContent: false),
      );
    } catch (e) {
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncValue.data(updated.copyWith(isLoadingContent: false));
      }
      showAppErrorToast(
        ref.read(appLocalizationsProvider).log_readFailed,
        description: e.toString(),
      );
    }
  }

  Future<void> toggleAgentCore({required bool isAgent}) async {
    final current = state.valueOrNull;
    if (current == null || current.isAgent == isAgent) return;

    state = AsyncValue.data(current.copyWith(isAgent: isAgent));

    if (current.selectedFile.isNotEmpty) {
      await selectFile(current.selectedFile);
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(logRepositoryProvider.future);
      final files = await repo.getSystemLogFiles();
      final current = state.valueOrNull ?? const SystemLogState();
      final selectedFile = files.contains(current.selectedFile)
          ? current.selectedFile
          : (files.isNotEmpty ? files.first : '');

      String content = '';
      if (selectedFile.isNotEmpty) {
        content = await _readFile(selectedFile, isAgent: current.isAgent);
      }

      return current.copyWith(
        files: files,
        selectedFile: selectedFile,
        content: content,
      );
    });
  }
}
