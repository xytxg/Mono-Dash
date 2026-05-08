import 'package:flutter/cupertino.dart';

class MiniButton extends StatelessWidget {
  const MiniButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = CupertinoColors.activeBlue,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final resolved = CupertinoDynamicColor.resolve(color, context);
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: Size.zero,
      color: resolved.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: resolved),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: resolved,
            ),
          ),
        ],
      ),
    );
  }
}
