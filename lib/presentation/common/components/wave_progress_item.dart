import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

/// 波浪进度背景绘制器，绘制液态波浪填充效果
class WaveBackgroundPainter extends CustomPainter {
  WaveBackgroundPainter({
    required this.progress,
    required this.waveValue,
    required this.color,
  });

  final double progress;
  final double waveValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    final fillWidth = size.width * progress;
    if (fillWidth <= 0) return;

    path.moveTo(0, 0);
    for (double y = 0; y <= size.height; y++) {
      final amplitude = 4.0 * (1.0 - (y / size.height));
      final dx = fillWidth +
          math.sin((y / size.height * 2 * math.pi) +
                  (waveValue * 2 * math.pi)) *
              amplitude;
      path.lineTo(dx, y);
    }
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveBackgroundPainter oldDelegate) => true;
}

/// 波浪进度动画层，封装 AnimationController + TweenAnimationBuilder + CustomPaint
class WaveProgressLayer extends StatefulWidget {
  const WaveProgressLayer({
    super.key,
    required this.progress,
    required this.color,
    this.smoothDuration = const Duration(milliseconds: 500),
  });

  /// 当前进度 (0.0 - 1.0)
  final double progress;

  /// 波浪颜色
  final Color color;

  /// 进度插值平滑过渡时长
  final Duration smoothDuration;

  @override
  State<WaveProgressLayer> createState() => _WaveProgressLayerState();
}

class _WaveProgressLayerState extends State<WaveProgressLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: widget.progress.clamp(0.0, 1.0)),
      duration: widget.smoothDuration,
      curve: Curves.linear,
      builder: (context, smoothProgress, child) {
        return AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: WaveBackgroundPainter(
                progress: smoothProgress,
                waveValue: _waveController.value,
                color: widget.color,
              ),
            );
          },
        );
      },
    );
  }
}
