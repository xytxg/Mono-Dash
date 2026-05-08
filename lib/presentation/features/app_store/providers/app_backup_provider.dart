import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../data/dto/backup/backup_record_dto.dart';
import '../../../../data/dto/backup/backup_record_search_req.dart';
import '../../../../data/dto/common/task_log_dto.dart';
import '../../../../data/repositories_impl/backup_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../models/app_backup_state.dart';

final appBackupControllerProvider =
    AsyncNotifierProvider.family<AppBackupController, AppBackupState, String>(
      AppBackupController.new,
      dependencies: [backupRepositoryProvider],
    );

class AppBackupController extends FamilyAsyncNotifier<AppBackupState, String> {
  static const _pageSize = 10;

  String get _appName => arg;

  BackupRecordSearchReq _req(int page) => BackupRecordSearchReq(
    page: page,
    pageSize: _pageSize,
    type: 'app',
    name: _appName,
    detailName: _appName,
  );

  @override
  Future<AppBackupState> build(String arg) => _load();

  Future<AppBackupState> _load() async {
    final repo = await ref.read(backupRepositoryProvider.future);
    final result = await repo.searchRecords(_req(1));
    var records = result.items;
    if (records.isNotEmpty) {
      records = await _mergeSizes(records, 1);
    }
    return AppBackupState(
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
      showAppErrorToast(
        ref.read(appLocalizationsProvider).appStore_loadMoreBackupsFailed,
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
  }) async {
    final taskID = const Uuid().v4();
    final repo = await ref.read(backupRepositoryProvider.future);
    await repo.backupApp(
      name: _appName,
      detailName: _appName,
      secret: secret,
      taskID: taskID,
      description: description,
    );
    return taskID;
  }

  Future<String> recover(
    BackupRecordDto record, {
    required String secret,
  }) async {
    final taskID = const Uuid().v4();
    final repo = await ref.read(backupRepositoryProvider.future);
    await repo.recoverApp(
      downloadAccountID: record.downloadAccountID,
      name: _appName,
      detailName: _appName,
      file: record.filePath,
      secret: secret,
      taskID: taskID,
      backupRecordID: record.id,
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
