import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/repositories_impl/dashboard_repository_impl.dart';
import '../../../../domain/entities/dashboard.dart';
import '../models/dashboard_view_state.dart';
import '../models/disk_io_rate.dart';
import '../utils/dashboard_calculators.dart';

export '../models/dashboard_view_state.dart';
export '../models/disk_io_rate.dart';
export '../models/speed_point.dart';

part 'dashboard_provider.g.dart';

/// 仪表盘数据加载器，依赖当前激活服务器。
///
/// - 首次 build：拉取监控选项与 base/current，初始化历史序列。
/// - 可见时刷新：由 DashboardPage 在概览 Tab 可见时每秒触发一次 current。
/// - 下拉刷新：直接拉一次 current，不清空旧数据（避免图表闪白）。
/// - 出错恢复：`state` 无值时，`refresh()` 会触发 provider 重建。
@Riverpod(dependencies: [dashboardRepository])
class DashboardController extends _$DashboardController {
  static const _minPointInterval = Duration(milliseconds: 500);

  bool _refreshingCurrent = false;
  bool _refreshingBase = false;
  DateTime? _lastDataPointTime;

  @override
  Future<DashboardViewState> build() async {
    final repo = await ref.watch(dashboardRepositoryProvider.future);
    final ioOptions = await _loadOptions(repo.getMonitorIoOptions);
    final netOptions = await _loadOptions(repo.getMonitorNetOptions);
    final selectedIoOption = ioOptions.first;
    final selectedNetOption = netOptions.first;
    final dashboard = await repo.getDashboard(
      ioOption: selectedIoOption,
      netOption: selectedNetOption,
    );
    final now = DateTime.now();
    _lastDataPointTime = now;
    return DashboardViewState(
      dashboard: dashboard,
      downloadHistory: NetworkSpeedSeries.initialHistory(now),
      uploadHistory: NetworkSpeedSeries.initialHistory(now),
      now: now,
      ioOptions: ioOptions,
      netOptions: netOptions,
      selectedIoOption: selectedIoOption,
      selectedNetOption: selectedNetOption,
      ioRate: const DiskIoRate.zero(),
      lastFetchMs: 0,
    );
  }

  /// 下拉刷新。
  ///
  /// - 有旧数据时：静默拉取新 current，图表继续展示旧历史以避免闪白。
  /// - 无旧数据（首次加载失败）时：触发 provider 重建，让用户能从错误中恢复。
  Future<void> refresh() async {
    if (!state.hasValue) {
      ref.invalidateSelf();
      await future;
      return;
    }
    await refreshCurrent();
  }

  /// 手动刷新基础信息。
  Future<void> refreshBase() async {
    if (_refreshingBase || !state.hasValue) return;

    _refreshingBase = true;
    final previous = state.requireValue;
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(dashboardRepositoryProvider.future);
      final base = await repo.getDashboardBase(
        ioOption: previous.selectedIoOption,
        netOption: previous.selectedNetOption,
      );
      return previous.copyWith(
        dashboard: Dashboard(base: base, current: previous.dashboard.current),
      );
    });
    _refreshingBase = false;
  }

  /// 拉取一次 current，追加到历史序列。不会清空旧数据。
  Future<void> refreshCurrent() async {
    if (_refreshingCurrent || !state.hasValue) return;

    _refreshingCurrent = true;
    final previous = state.requireValue;
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(dashboardRepositoryProvider.future);
      final stopWatch = Stopwatch()..start();
      final current = await repo.getDashboardCurrent(
        ioOption: previous.selectedIoOption,
        netOption: previous.selectedNetOption,
      );
      final elapsed = stopWatch.elapsedMilliseconds;
      final dashboard = Dashboard(
        base: previous.dashboard.base,
        current: current,
      );
      return _buildNextState(previous, dashboard).copyWith(lastFetchMs: elapsed);
    });
    _refreshingCurrent = false;
  }

  Future<void> selectIoOption(String option) async {
    final previous = state.valueOrNull;
    if (previous == null || previous.selectedIoOption == option) return;

    state = AsyncValue.data(
      previous.copyWith(
        selectedIoOption: option,
        ioRate: const DiskIoRate.zero(),
      ),
    );
    await refreshCurrent();
  }

  Future<void> selectNetOption(String option) async {
    final previous = state.valueOrNull;
    if (previous == null || previous.selectedNetOption == option) return;

    final now = DateTime.now();
    _lastDataPointTime = now;
    state = AsyncValue.data(
      previous.copyWith(
        selectedNetOption: option,
        downloadHistory: NetworkSpeedSeries.initialHistory(now),
        uploadHistory: NetworkSpeedSeries.initialHistory(now),
        now: now,
      ),
    );
    await refreshCurrent();
  }

  DashboardViewState _buildNextState(
    DashboardViewState previous,
    Dashboard dashboard,
  ) {
    final now = DateTime.now();
    final lastPointTime = _lastDataPointTime;
    if (lastPointTime != null) {
      final elapsed = now.difference(lastPointTime);
      // 间隔过短（< 500ms）时只更新数据、不追加采样点，避免图表抖动。
      if (elapsed < _minPointInterval) {
        return previous.copyWith(dashboard: dashboard, now: now);
      }
    }

    final previousCurrent = previous.dashboard.current;
    final seconds = now.difference(previous.now).inMilliseconds / 1000;
    final downloadSpeed = seconds <= 0
        ? 0.0
        : (dashboard.current.netBytesRecv - previousCurrent.netBytesRecv) /
              seconds;
    final uploadSpeed = seconds <= 0
        ? 0.0
        : (dashboard.current.netBytesSent - previousCurrent.netBytesSent) /
              seconds;
    final ioRate = DiskIoRateCalculator.calculate(
      previousCurrent,
      dashboard.current,
      seconds,
    );

    final historyResult = NetworkSpeedSeries.appendWithGapCheck(
      downloadHistory: previous.downloadHistory,
      uploadHistory: previous.uploadHistory,
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      now: now,
      lastPointTime: lastPointTime,
    );

    _lastDataPointTime = now;

    return previous.copyWith(
      dashboard: dashboard,
      downloadHistory: historyResult.download,
      uploadHistory: historyResult.upload,
      now: now,
      ioRate: ioRate,
    );
  }

  List<String> _normalizeOptions(List<String> options) {
    final values = [
      'all',
      ...options.where((option) => option.isNotEmpty && option != 'all'),
    ];
    return values.toSet().toList(growable: false);
  }

  Future<List<String>> _loadOptions(
    Future<List<String>> Function() load,
  ) async {
    try {
      return _normalizeOptions(await load());
    } catch (_) {
      return const ['all'];
    }
  }
}
