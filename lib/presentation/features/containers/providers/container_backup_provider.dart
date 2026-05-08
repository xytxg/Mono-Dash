import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../data/dto/backup/backup_record_dto.dart';
import '../../../../data/dto/backup/backup_record_search_req.dart';
import '../../../../data/dto/common/task_log_dto.dart';
import '../../../../data/repositories_impl/backup_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../models/container_backup_state.dart';

final containerBackupControllerProvider =
    AsyncNotifierProvider.family<
      ContainerBackupController,
      ContainerBackupState,
      String
    >(ContainerBackupController.new, dependencies: [backupRepositoryProvider]);

class ContainerBackupController
    extends FamilyAsyncNotifier<ContainerBackupState, String> {
  static const _pageSize = 10;

  String get _containerName => arg;

  BackupRecordSearchReq _req(int page) => BackupRecordSearchReq(
    page: page,
    pageSize: _pageSize,
    type: 'container',
    name: _containerName,
    detailName: '',
  );

  @override
  Future<ContainerBackupState> build(String arg) => _load();

  Future<ContainerBackupState> _load() async {
    final repo = await ref.read(backupRepositoryProvider.future);
    final result = await repo.searchRecords(_req(1));
    var records = result.items;
    if (records.isNotEmpty) {
      records = await _mergeSizes(records, 1);
    }
    return ContainerBackupState(
      records: records,
      total: result.total,
      hasMore: records.length >= _pageSize,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    state = AsyncData(await _load());
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.records.length ~/ _pageSize + 1;
    try {
      final repo = await ref.read(backupRepositoryProvider.future);
      final result = await repo.searchRecords(_req(nextPage));
      final more = result.items.isEmpty
          ? result.items
          : await _mergeSizes(result.items, nextPage);
      state = AsyncData(
        current.copyWith(
          records: [...current.records, ...more],
          total: result.total,
          hasMore: more.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      showAppErrorToast(
        l10n.containers_loadMoreBackupsFailed,
        description: '$error',
      );
    }
  }

  Future<List<BackupRecordDto>> _mergeSizes(
    List<BackupRecordDto> records,
    int page,
  ) async {
    final repo = await ref.read(backupRepositoryProvider.future);
    final sizes = await repo.recordSizes(_req(page));
    final sizeMap = {for (final item in sizes) item.id: item.size};
    return [
      for (final record in records) record.copyWith(size: sizeMap[record.id]),
    ];
  }

  Future<String> backup({
    required String secret,
    required String description,
    required bool stopBefore,
  }) async {
    final taskID = const Uuid().v4();
    final repo = await ref.read(backupRepositoryProvider.future);
    await repo.backupContainer(
      name: _containerName,
      detailName: '',
      secret: secret,
      taskID: taskID,
      description: description,
      stopBefore: stopBefore,
    );
    return taskID;
  }

  Future<String> recover(
    BackupRecordDto record, {
    required String secret,
    required int timeout,
  }) async {
    final taskID = const Uuid().v4();
    final repo = await ref.read(backupRepositoryProvider.future);
    await repo.recoverContainer(
      downloadAccountID: record.downloadAccountID,
      name: _containerName,
      detailName: '',
      file: record.filePath,
      secret: secret,
      taskID: taskID,
      backupRecordID: record.id,
      timeout: timeout,
    );
    return taskID;
  }

  Future<void> delete(BackupRecordDto record) async {
    final repo = await ref.read(backupRepositoryProvider.future);
    await repo.deleteRecords([record.id]);
    await refresh();
  }

  Future<TaskLogDto> readTaskLog(String taskID, {required bool latest}) async {
    final repo = await ref.read(backupRepositoryProvider.future);
    return repo.readTaskLog(taskID, latest: latest);
  }
}
