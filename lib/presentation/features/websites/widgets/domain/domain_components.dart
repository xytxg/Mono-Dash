import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class DomainProtocolBadge extends StatelessWidget {
  const DomainProtocolBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class DomainActionButton extends StatelessWidget {
  const DomainActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 34),
      onPressed: onPressed,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color.withValues(alpha: enabled ? 1 : 0.4),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: enabled ? 1 : 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DomainIconActionButton extends StatelessWidget {
  const DomainIconActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(34),
      onPressed: onPressed,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color.withValues(alpha: enabled ? 1 : 0.35),
        ),
      ),
    );
  }
}

Color domainProtocolColor(BuildContext context, bool ssl) {
  return ssl
      ? CupertinoColors.systemGreen.resolveFrom(context)
      : CupertinoColors.systemBlue.resolveFrom(context);
}

IconData domainProtocolIcon(bool ssl) {
  return ssl ? TablerIcons.lock : TablerIcons.lock_open;
}

String domainProtocolLabel(bool ssl) {
  return ssl ? 'HTTPS' : 'HTTP';
}
