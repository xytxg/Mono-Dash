/// 一次网络速率采样：带时间戳的瞬时速率（字节/秒）。
class SpeedPoint {
  const SpeedPoint(this.value, this.time);

  final double value;
  final DateTime time;
}
