import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../models/container_monitor_state.dart';

part 'container_monitor_provider.g.dart';

@Riverpod(dependencies: [containerRepository])
class ContainerMonitor extends _$ContainerMonitor {
  Timer? _timer;

  @override
  ContainerMonitorState build(String containerId) {
    _startPolling(2);

    ref.onDispose(() {
      _timer?.cancel();
    });

    Future.microtask(_fetchStats);

    return const ContainerMonitorState();
  }

  void _startPolling(int seconds) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: seconds), (_) => _fetchStats());
  }

  Future<void> _fetchStats() async {
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      final stats = await repo.getContainerStats(containerId);

      final newHistory = [...state.history, stats];
      if (newHistory.length > 30) {
        newHistory.removeAt(0);
      }

      state = state.copyWith(
        history: newHistory,
        isLoading: false,
        totalPointsCount: state.totalPointsCount + 1,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void setInterval(int seconds) {
    if (state.intervalSeconds == seconds) return;
    state = state.copyWith(intervalSeconds: seconds);
    _startPolling(seconds);
  }
}
