import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatter.dart';
import '../../../common/components/info_panel.dart';
import '../../../common/components/skeleton_item.dart';
import '../providers/dashboard_provider.dart';

/// 上传/下载实时速率图表。
class SpeedChartCard extends StatelessWidget {
  const SpeedChartCard({
    super.key,
    required this.downloadHistory,
    required this.uploadHistory,
    required this.now,
    this.loading = false,
  });

  final List<SpeedPoint> downloadHistory;
  final List<SpeedPoint> uploadHistory;
  final DateTime now;
  final bool loading;

  double _calculateMaxScale(double currentMax) {
    if (currentMax < 2048) return 2048;

    final magnitude = pow(10, (log(currentMax) / ln10).floor()).toDouble();
    final normalized = currentMax / magnitude;

    final scale = switch (normalized) {
      <= 1 => 1,
      <= 2 => 2,
      <= 5 => 5,
      _ => 10,
    };

    return magnitude * scale * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    final windowStart = now.subtract(const Duration(seconds: 60));
    final currentMax = [
      ...downloadHistory
          .where((point) => point.time.isAfter(windowStart))
          .map((point) => point.value),
      ...uploadHistory
          .where((point) => point.time.isAfter(windowStart))
          .map((point) => point.value),
    ].fold<double>(0, max);
    final maxValue = _calculateMaxScale(currentMax);
    final downloadSpeed = downloadHistory.isEmpty
        ? 0.0
        : downloadHistory.last.value;
    final uploadSpeed = uploadHistory.isEmpty ? 0.0 : uploadHistory.last.value;

    return InfoPanel(
      title: context.l10n.dashboard_realtimeSpeedTitle,
      icon: TablerIcons.chart_area_line,
      iconColor: CupertinoColors.activeBlue.resolveFrom(context),
      trailing: Wrap(
        alignment: WrapAlignment.end,
        spacing: 12,
        runSpacing: 6,
        children: [
          _LegendItem(
            color: CupertinoColors.systemBlue.resolveFrom(context),
            icon: TablerIcons.download,
            semanticLabel: context.l10n.dashboard_download,
            value: Formatter.speed(downloadSpeed),
            loading: loading,
          ),
          _LegendItem(
            color: CupertinoColors.systemGreen.resolveFrom(context),
            icon: TablerIcons.upload,
            semanticLabel: context.l10n.dashboard_upload,
            value: Formatter.speed(uploadSpeed),
            loading: loading,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: loading
                ? const Center(
                    child: SkeletonItem(width: double.infinity, height: 160),
                  )
                : ClipRect(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _SpeedChartPainter(
                        downloadData: downloadHistory,
                        uploadData: uploadHistory,
                        maxValue: maxValue,
                        now: now,
                        labelStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryLabel(
                            context,
                          ).withValues(alpha: 0.6),
                        ),
                        gridColor: AppColors.separator(
                          context,
                        ).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.icon,
    required this.semanticLabel,
    required this.value,
    this.loading = false,
  });

  final Color color;
  final IconData icon;
  final String semanticLabel;
  final String value;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(icon, size: 13, color: color, semanticLabel: semanticLabel),
              const SizedBox(width: 4),
              SizedBox(
                width: 64,
                child: loading
                    ? const Align(
                        alignment: Alignment.centerRight,
                        child: SkeletonItem.text(width: 48, height: 11),
                      )
                    : Text(
                        value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpeedChartPainter extends CustomPainter {
  const _SpeedChartPainter({
    required this.downloadData,
    required this.uploadData,
    required this.maxValue,
    required this.labelStyle,
    required this.gridColor,
    required this.now,
  });

  final List<SpeedPoint> downloadData;
  final List<SpeedPoint> uploadData;
  final double maxValue;
  final TextStyle labelStyle;
  final Color gridColor;
  final DateTime now;

  @override
  void paint(Canvas canvas, Size size) {
    const stepCount = 4;
    final stepHeight = size.height / stepCount;
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i <= stepCount; i++) {
      final y = i * stepHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      if (i < stepCount) {
        final value = maxValue * (1 - i / stepCount);
        final textPainter = TextPainter(
          text: TextSpan(text: Formatter.speed(value), style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(16, y + 6));
      }
    }

    _drawSmoothLine(canvas, size, uploadData, CupertinoColors.systemGreen);
    _drawSmoothLine(canvas, size, downloadData, CupertinoColors.systemBlue);
  }

  void _drawSmoothLine(
    Canvas canvas,
    Size size,
    List<SpeedPoint> data,
    Color color,
  ) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    const totalDuration = 60.0;
    var isFirst = true;
    var lastX = 0.0;
    var lastY = 0.0;

    for (final point in data) {
      final diff = now.difference(point.time).inMilliseconds / 1000.0;
      if (diff > totalDuration + 2 || diff < -2) continue;

      final x = (1 - diff / totalDuration) * size.width;
      final value = point.value > maxValue ? maxValue : point.value;
      final y = size.height - (value / maxValue * size.height);

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        final controlX = lastX + (x - lastX) / 2;
        path.cubicTo(controlX, lastY, controlX, y, x, y);
      }
      lastX = x;
      lastY = y;
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpeedChartPainter oldDelegate) {
    return now != oldDelegate.now ||
        downloadData != oldDelegate.downloadData ||
        uploadData != oldDelegate.uploadData ||
        maxValue != oldDelegate.maxValue;
  }
}
