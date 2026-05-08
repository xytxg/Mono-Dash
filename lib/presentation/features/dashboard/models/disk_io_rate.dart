/// 基于两次采样计算出的磁盘 IO 瞬时速率。
class DiskIoRate {
  const DiskIoRate({
    required this.readBytesPerSecond,
    required this.writeBytesPerSecond,
    required this.ioCountPerSecond,
    required this.latencyMs,
    required this.readTimeMsPerSecond,
    required this.writeTimeMsPerSecond,
  });

  const DiskIoRate.zero()
    : readBytesPerSecond = 0,
      writeBytesPerSecond = 0,
      ioCountPerSecond = 0,
      latencyMs = 0,
      readTimeMsPerSecond = 0,
      writeTimeMsPerSecond = 0;

  final double readBytesPerSecond;
  final double writeBytesPerSecond;
  final double ioCountPerSecond;
  final double latencyMs;
  final double readTimeMsPerSecond;
  final double writeTimeMsPerSecond;
}
