import '../../../../domain/entities/dashboard.dart';
import 'disk_io_rate.dart';
import 'speed_point.dart';

/// Dashboard Tab 的展示状态（包含原始数据 + 派生的速率/历史）。
class DashboardViewState {
  const DashboardViewState({
    required this.dashboard,
    required this.downloadHistory,
    required this.uploadHistory,
    required this.now,
    required this.ioOptions,
    required this.netOptions,
    required this.selectedIoOption,
    required this.selectedNetOption,
    required this.ioRate,
    required this.lastFetchMs,
  });

  final Dashboard dashboard;
  final List<SpeedPoint> downloadHistory;
  final List<SpeedPoint> uploadHistory;
  final DateTime now;
  final List<String> ioOptions;
  final List<String> netOptions;
  final String selectedIoOption;
  final String selectedNetOption;
  final DiskIoRate ioRate;
  final int lastFetchMs;

  DashboardViewState copyWith({
    Dashboard? dashboard,
    List<SpeedPoint>? downloadHistory,
    List<SpeedPoint>? uploadHistory,
    DateTime? now,
    List<String>? ioOptions,
    List<String>? netOptions,
    String? selectedIoOption,
    String? selectedNetOption,
    DiskIoRate? ioRate,
    int? lastFetchMs,
  }) {
    return DashboardViewState(
      dashboard: dashboard ?? this.dashboard,
      downloadHistory: downloadHistory ?? this.downloadHistory,
      uploadHistory: uploadHistory ?? this.uploadHistory,
      now: now ?? this.now,
      ioOptions: ioOptions ?? this.ioOptions,
      netOptions: netOptions ?? this.netOptions,
      selectedIoOption: selectedIoOption ?? this.selectedIoOption,
      selectedNetOption: selectedNetOption ?? this.selectedNetOption,
      ioRate: ioRate ?? this.ioRate,
      lastFetchMs: lastFetchMs ?? this.lastFetchMs,
    );
  }

  static DashboardViewState dummy() {
    final now = DateTime.now();
    return DashboardViewState(
      dashboard: const Dashboard(
        base: DashboardBase(
          hostname: '',
          ipV4Addr: '',
          os: '',
          platform: '',
          platformFamily: '',
          platformVersion: '',
          prettyDistro: '',
          kernelArch: '',
          kernelVersion: '',
          cpuCores: 0,
          cpuLogicalCores: 0,
          cpuMhz: 0,
          cpuModelName: '',
          virtualizationSystem: '',
          systemProxy: '',
          websiteNumber: 0,
          databaseNumber: 0,
          cronjobNumber: 0,
          appInstalledNumber: 0,
          agentNumber: 0,
        ),
        current: DashboardCurrent(
          uptimeSeconds: 0,
          timeSinceUptime: '',
          shotTime: '',
          procs: 0,
          load1: 0,
          load5: 0,
          load15: 0,
          loadUsagePercent: 0,
          cpuTotal: 0,
          cpuUsed: 0,
          cpuUsedPercent: 0,
          cpuPercent: [],
          cpuDetailedPercent: [],
          memoryTotal: 0,
          memoryUsed: 0,
          memoryFree: 0,
          memoryAvailable: 0,
          memoryCache: 0,
          memoryUsedPercent: 0,
          swapMemoryTotal: 0,
          swapMemoryUsed: 0,
          swapMemoryAvailable: 0,
          swapMemoryUsedPercent: 0,
          netBytesSent: 0,
          netBytesRecv: 0,
          ioCount: 0,
          ioReadBytes: 0,
          ioReadTime: 0,
          ioWriteBytes: 0,
          ioWriteTime: 0,
          disks: [],
          topCpuItems: [],
          topMemItems: [],
          gpus: [],
          xpus: [],
        ),
      ),
      downloadHistory: [],
      uploadHistory: [],
      now: now,
      ioOptions: ['all'],
      netOptions: ['all'],
      selectedIoOption: 'all',
      selectedNetOption: 'all',
      ioRate: const DiskIoRate.zero(),
      lastFetchMs: 0,
    );
  }
}
