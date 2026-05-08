import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../data/api/file_api.dart';
import '../../../../data/dto/backup/backup_record_dto.dart';
import '../../../../data/dto/backup/backup_record_search_req.dart';
import '../../../../data/dto/common/task_log_dto.dart';
import '../../../../data/repositories_impl/backup_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../app_store/models/app_backup_state.dart';

typedef DbBackupKey = ({String type, String name, String dbName});

final databaseBackupControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DatabaseBackupController, AppBackupState, DbBackupKey>(
      DatabaseBackupController.new,
      dependencies: [backupRepositoryProvider],
    );

class DatabaseBackupController
    extends AutoDisposeFamilyAsyncNotifier<AppBackupState, DbBackupKey> {
  static const _pageSize = 10;

  String get _type => arg.type;
  String get _name => arg.name;
  String get _dbName => arg.dbName;

  BackupRecordSearchReq _req(int page) => BackupRecordSearchReq(
    page: page,
    pageSize: _pageSize,
    type: _type,
    name: _name,
    detailName: _dbName,
  );

  @override
  Future<AppBackupState> build(DbBackupKey arg) => _load();

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
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(
        l10n.databases_loadMoreBackupsFailed,
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
    List<String> args = const [],
  }) async {
    final taskID = const Uuid().v4();
    final repo = await ref.read(backupRepositoryProvider.future);
    await repo.backupDatabase(
      type: _type,
      name: _name,
      detailName: _dbName,
      secret: secret,
      taskID: taskID,
      description: description,
      args: args,
    );
    return taskID;
  }

  Future<String> recover(
    BackupRecordDto record, {
    required String secret,
  }) async {
    final taskID = const Uuid().v4();
    final repo = await ref.read(backupRepositoryProvider.future);
    await repo.recoverDatabase(
      downloadAccountID: record.downloadAccountID,
      type: _type,
      name: _name,
      detailName: _dbName,
      file: record.filePath,
      secret: secret,
      taskID: taskID,
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

  Future<void> downloadAndShare(BackupRecordDto record) async {
    try {
      final repo = await ref.read(backupRepositoryProvider.future);
      final serverPath = await repo.downloadRecord(
        downloadAccountID: record.downloadAccountID,
        fileDir: record.fileDir,
        fileName: record.fileName,
      );
      final l10n = ref.read(appLocalizationsProvider);
      if (serverPath.isEmpty) {
        throw Exception(l10n.databases_downloadPathUnavailable);
      }

      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/${record.fileName}';

      // 清理旧文件，避免追加写入
      final localFile = File(localPath);
      if (await localFile.exists()) await localFile.delete();

      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      await FileApi(client).downloadFile(path: serverPath, savePath: localPath);

      // 校验下载完整性
      if (!await localFile.exists() || await localFile.length() == 0) {
        throw Exception(l10n.databases_downloadedFileEmpty);
      }

      final mime = _guessMimeType(record.fileName);
      await SharePlus.instance.share(
        ShareParams(
          title: record.fileName,
          subject: record.fileName,
          files: [XFile(localPath, mimeType: mime)],
          fileNameOverrides: [record.fileName],
        ),
      );
    } catch (error) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(
        l10n.databases_downloadShareFailed,
        description: '$error',
      );
    }
  }
}

String _guessMimeType(String fileName) {
  final ext = fileName.contains('.')
      ? fileName.split('.').last.toLowerCase()
      : '';
  return switch (ext) {
    'sql' => 'application/sql',
    'gz' || 'gzip' => 'application/gzip',
    'tar' => 'application/x-tar',
    'zip' => 'application/zip',
    'bak' || 'dump' => 'application/octet-stream',
    _ => 'application/octet-stream',
  };
}
