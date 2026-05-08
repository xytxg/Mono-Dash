import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../data/api/file_api.dart';
import '../../../../data/dto/common/task_log_dto.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../../data/repositories_impl/backup_repository_impl.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../server_detail/providers/active_server_provider.dart';

typedef DbImportKey = ({String type, String name, String dbName});

final databaseImportBackupProvider = AsyncNotifierProvider.autoDispose
    .family<DatabaseImportBackupNotifier, ImportBackupState, DbImportKey>(
      DatabaseImportBackupNotifier.new,
      dependencies: [backupRepositoryProvider, settingRepositoryProvider],
    );

class ImportBackupState {
  const ImportBackupState({
    required this.baseDir,
    required this.uploadPath,
    required this.files,
  });

  final String baseDir;
  final String uploadPath;
  final List<FileItemDto> files;

  ImportBackupState copyWith({
    String? baseDir,
    String? uploadPath,
    List<FileItemDto>? files,
  }) {
    return ImportBackupState(
      baseDir: baseDir ?? this.baseDir,
      uploadPath: uploadPath ?? this.uploadPath,
      files: files ?? this.files,
    );
  }
}

class DatabaseImportBackupNotifier
    extends AutoDisposeFamilyAsyncNotifier<ImportBackupState, DbImportKey> {
  String get _type => arg.type;
  String get _name => arg.name;
  String get _dbName => arg.dbName;

  @override
  Future<ImportBackupState> build(DbImportKey arg) => _load();

  Future<ImportBackupState> _load() async {
    final settingRepo = await ref.read(settingRepositoryProvider.future);
    final baseDir = await settingRepo.getBaseDir();
    final uploadPath = '$baseDir/uploads/database/$_type/$_name/$_dbName/';
    final files = await _listFiles(uploadPath);
    return ImportBackupState(
      baseDir: baseDir,
      uploadPath: uploadPath,
      files: files,
    );
  }

  Future<List<FileItemDto>> _listFiles(String path) async {
    final serverId = ref.read(activeServerIdProvider);
    final client = await ref.read(dioClientProvider(serverId).future);
    final result = await FileApi(client).searchFiles(
      path: path,
      expand: true,
      showHidden: false,
      pageSize: 200,
      sortBy: 'name',
      sortOrder: 'descending',
    );
    final items = result.items ?? const <FileItemDto>[];
    return items.where((f) => !f.isDir).toList();
  }

  Future<void> refresh() async {
    state = AsyncData(await _load());
  }

  /// 从服务器选择文件并复制到导入目录。
  Future<void> copyFromServer(String sourcePath) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final repo = await ref.read(backupRepositoryProvider.future);
      await repo.uploadForRecover(
        filePath: sourcePath,
        targetDir: current.uploadPath,
      );
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.databases_fileCopiedToImportDir);
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.databases_copyFileFailed, description: '$e');
    }
  }

  /// 从本地上传文件到导入目录。
  Future<void> uploadFromLocal({
    required String localPath,
    void Function(double progress)? onProgress,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final fileRepo = await ref.read(fileRepositoryProvider.future);
      await fileRepo.uploadFile(
        filePath: localPath,
        targetPath: current.uploadPath,
        overwrite: true,
        onProgress: onProgress,
      );
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.databases_fileUploaded);
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.databases_uploadFileFailed, description: '$e');
    }
  }

  /// 删除导入目录中的文件。
  Future<void> deleteFile(String filePath) async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      await FileApi(client).deleteFile(path: filePath, isDir: false);
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.databases_fileDeleted);
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.databases_deleteFileFailed, description: '$e');
    }
  }

  /// 从导入目录中的文件执行恢复。
  Future<String> recoverFromFile(
    String fileName, {
    required String secret,
    int timeout = 0,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      final l10n = ref.read(appLocalizationsProvider);
      throw StateError(l10n.databases_stateNotReady);
    }
    final taskID = const Uuid().v4();
    final repo = await ref.read(backupRepositoryProvider.future);
    await repo.recoverByUpload(
      downloadAccountID: 1,
      type: _type,
      name: _name,
      detailName: _dbName,
      file: '${current.uploadPath}$fileName',
      secret: secret,
      taskID: taskID,
      timeout: timeout,
    );
    return taskID;
  }

  Future<TaskLogDto> readTaskLog(String taskID, {required bool latest}) async {
    final repo = await ref.read(backupRepositoryProvider.future);
    return repo.readTaskLog(taskID, latest: latest);
  }
}
