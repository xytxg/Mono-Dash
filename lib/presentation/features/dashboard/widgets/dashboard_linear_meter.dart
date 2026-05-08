import 'package:flutter/cupertino.dart';

class DashboardLinearMeter extends StatelessWidget {
  const DashboardLinearMeter({
    super.key,
    required this.percent,
    required this.color,
  });

  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: percent.clamp(0.0, 100.0) / 100),
      builder: (context, value, _) {
        return FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      },
    );
  }
}
