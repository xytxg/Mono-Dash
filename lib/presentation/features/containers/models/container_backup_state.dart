import '../../../../data/dto/backup/backup_record_dto.dart';

class ContainerBackupState {
  const ContainerBackupState({
    required this.records,
    required this.total,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<BackupRecordDto> records;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;

  ContainerBackupState copyWith({
    List<BackupRecordDto>? records,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ContainerBackupState(
      records: records ?? this.records,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
