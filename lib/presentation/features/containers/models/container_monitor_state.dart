import '../../../../data/dto/container/container_stats_dto.dart';

class ContainerMonitorState {
  const ContainerMonitorState({
    this.history = const [],
    this.intervalSeconds = 2,
    this.isLoading = true,
    this.totalPointsCount = 0,
    this.error,
  });

  final List<ContainerStatsDto> history;
  final int intervalSeconds;
  final bool isLoading;
  final int totalPointsCount;
  final String? error;

  ContainerMonitorState copyWith({
    List<ContainerStatsDto>? history,
    int? intervalSeconds,
    bool? isLoading,
    int? totalPointsCount,
    String? error,
  }) {
    return ContainerMonitorState(
      history: history ?? this.history,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      isLoading: isLoading ?? this.isLoading,
      totalPointsCount: totalPointsCount ?? this.totalPointsCount,
      error: error ?? this.error,
    );
  }
}
