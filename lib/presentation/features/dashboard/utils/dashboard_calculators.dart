import '../models/disk_io_rate.dart';
import '../models/speed_point.dart';
import '../../../../domain/entities/dashboard.dart';

class NetworkSpeedSeries {
  static const historyWindow = Duration(seconds: 65);
  static const gapThreshold = Duration(seconds: 2);

  static List<SpeedPoint> initialHistory(DateTime now) {
    return [
      for (var i = 0; i < 60; i++)
        SpeedPoint(0, now.subtract(Duration(seconds: 60 - i))),
    ];
  }

  static List<SpeedPoint> appendPoint(
    List<SpeedPoint> history,
    SpeedPoint point,
    DateTime now,
  ) {
    final windowStart = now.subtract(historyWindow);
    return [...history.where((item) => item.time.isAfter(windowStart)), point];
  }

  static ({List<SpeedPoint> download, List<SpeedPoint> upload}) appendWithGapCheck({
    required List<SpeedPoint> downloadHistory,
    required List<SpeedPoint> uploadHistory,
    required double downloadSpeed,
    required double uploadSpeed,
    required DateTime now,
    DateTime? lastPointTime,
  }) {
    var down = downloadHistory;
    var up = uploadHistory;

    // 采样中断较久（> 2s）时，补 0 点让图表呈现断崖，避免误连成平滑曲线。
    if (lastPointTime != null && now.difference(lastPointTime) > gapThreshold) {
      final dropTime = lastPointTime.add(const Duration(milliseconds: 100));
      final riseTime = now.subtract(const Duration(milliseconds: 100));
      down = appendPoint(down, SpeedPoint(0, dropTime), now);
      up = appendPoint(up, SpeedPoint(0, dropTime), now);
      if (riseTime.isAfter(dropTime)) {
        down = appendPoint(down, SpeedPoint(0, riseTime), now);
        up = appendPoint(up, SpeedPoint(0, riseTime), now);
      }
    }

    down = appendPoint(down, SpeedPoint(downloadSpeed < 0 ? 0 : downloadSpeed, now), now);
    up = appendPoint(up, SpeedPoint(uploadSpeed < 0 ? 0 : uploadSpeed, now), now);

    return (download: down, upload: up);
  }
}

class DiskIoRateCalculator {
  static DiskIoRate calculate(
    DashboardCurrent previous,
    DashboardCurrent current,
    double seconds,
  ) {
    if (seconds <= 0) return const DiskIoRate.zero();

    final readBytesDelta = current.ioReadBytes - previous.ioReadBytes;
    final writeBytesDelta = current.ioWriteBytes - previous.ioWriteBytes;
    final ioCountDelta = current.ioCount - previous.ioCount;
    final readTimeDelta = current.ioReadTime - previous.ioReadTime;
    final writeTimeDelta = current.ioWriteTime - previous.ioWriteTime;
    final safeIoCountDelta = ioCountDelta <= 0 ? 0 : ioCountDelta;
    final latencyMs = safeIoCountDelta == 0
        ? 0.0
        : (readTimeDelta + writeTimeDelta).clamp(0, double.infinity) /
              safeIoCountDelta;

    return DiskIoRate(
      readBytesPerSecond: readBytesDelta <= 0 ? 0 : readBytesDelta / seconds,
      writeBytesPerSecond: writeBytesDelta <= 0 ? 0 : writeBytesDelta / seconds,
      ioCountPerSecond: ioCountDelta <= 0 ? 0 : ioCountDelta / seconds,
      latencyMs: latencyMs,
      readTimeMsPerSecond: readTimeDelta <= 0 ? 0 : readTimeDelta / seconds,
      writeTimeMsPerSecond: writeTimeDelta <= 0 ? 0 : writeTimeDelta / seconds,
    );
  }
}
