import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// 统一的状态胶囊组件，用于显示运行中、停止等状态。
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.active,
    this.activeColor,
    this.inactiveColor,
  });

  final String label;
  final bool active;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (activeColor ?? CupertinoColors.systemGreen.resolveFrom(context))
        : (inactiveColor ?? CupertinoColors.systemRed.resolveFrom(context));

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? TablerIcons.circle_check_filled : TablerIcons.circle_x,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
