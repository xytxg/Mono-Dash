import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';

class BackupInlineMeta extends StatelessWidget {
  const BackupInlineMeta({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, height: 1.0, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              strutStyle: const StrutStyle(
                fontSize: 12,
                height: 1.0,
                forceStrutHeight: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackupStatusMeta extends StatelessWidget {
  const BackupStatusMeta({
    super.key,
    required this.statusIcon,
    required this.statusColor,
    required this.statusText,
    this.alignEnd = true,
  });

  final IconData statusIcon;
  final Color statusColor;
  final String statusText;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisAlignment: alignEnd
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: alignEnd ? TextAlign.right : TextAlign.left,
              strutStyle: const StrutStyle(
                fontSize: 12,
                height: 1.0,
                forceStrutHeight: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackupTextAction extends StatelessWidget {
  const BackupTextAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 6),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class BackupEmptyState extends StatelessWidget {
  const BackupEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.archive_off,
            size: 40,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.common_noBackups,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.label(context),
            ),
          ),
        ],
      ),
    );
  }
}
