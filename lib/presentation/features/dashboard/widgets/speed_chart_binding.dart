import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../models/speed_point.dart';
import 'speed_chart_card.dart';

class SpeedChartBinding extends StatelessWidget {
  const SpeedChartBinding({
    super.key,
    required this.downloadHistory,
    required this.uploadHistory,
    required this.nowNotifier,
    this.loading = false,
  });

  final List<SpeedPoint> downloadHistory;
  final List<SpeedPoint> uploadHistory;
  final ValueListenable<DateTime> nowNotifier;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: nowNotifier,
      builder: (_, now, _) => SpeedChartCard(
        downloadHistory: downloadHistory,
        uploadHistory: uploadHistory,
        now: now.subtract(const Duration(seconds: 1)),
        loading: loading,
      ),
    );
  }
}
