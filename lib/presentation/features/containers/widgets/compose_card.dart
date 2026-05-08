import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/container_compose_dto.dart';

class ComposeCard extends StatelessWidget {
  const ComposeCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onStart,
    required this.onStop,
    required this.onRestart,
  });

  final ContainerComposeDto item;
  final VoidCallback onTap;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final isRunning = item.runningCount > 0;
    final statusColor = isRunning
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemGrey.resolveFrom(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, statusColor),
              const SizedBox(height: 12),
              _buildInfo(context),
              const SizedBox(height: 16),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color statusColor) {
    final (icon, color) = _getIconInfo(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCreatedBy(context, item.createdBy),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${item.runningCount}/${item.containerCount}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    final secondary = AppColors.secondaryLabel(context);
    return Column(
      children: [
        _InfoRow(
          icon: TablerIcons.clock,
          label: context.l10n.containers_createdAt,
          value: formatTimeAgo(
            DateTime.tryParse(item.createdAt),
            context.l10n,
            prefix: '',
          ),
          color: secondary,
        ),
        const SizedBox(height: 8),
        _InfoRow(
          icon: TablerIcons.folder,
          label: context.l10n.containers_workDir,
          value: item.workdir,
          color: secondary,
          isPath: true,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: TablerIcons.player_play,
            label: context.l10n.containers_start,
            color: CupertinoColors.systemGreen.resolveFrom(context),
            onPressed: onStart,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: TablerIcons.player_stop,
            label: context.l10n.containers_stop,
            color: CupertinoColors.systemRed.resolveFrom(context),
            onPressed: onStop,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: TablerIcons.refresh,
            label: context.l10n.containers_restart,
            color: CupertinoColors.activeBlue.resolveFrom(context),
            onPressed: onRestart,
          ),
        ),
      ],
    );
  }

  (Widget, Color) _getIconInfo(BuildContext context) {
    final type = item.createdBy.toLowerCase();
    if (type == 'apps') {
      final color = CupertinoColors.systemBlue.resolveFrom(context);
      return (Icon(TablerIcons.brand_appstore, size: 24, color: color), color);
    }
    if (type == '1panel') {
      final color = CupertinoColors.activeBlue.resolveFrom(context);
      return (
        SvgPicture.asset(
          'assets/icons/1panel.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        color,
      );
    }
    final color = CupertinoColors.systemPurple.resolveFrom(context);
    return (Icon(TablerIcons.stack_2, size: 24, color: color), color);
  }

  String _formatCreatedBy(BuildContext context, String createdBy) {
    if (createdBy.toLowerCase() == 'apps') {
      return context.l10n.containers_appStoreSource;
    }
    if (createdBy.toLowerCase() == '1panel') return '1Panel';
    if (createdBy.isEmpty) return context.l10n.containers_localSource;
    return createdBy;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isPath = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isPath;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.label(context),
              fontWeight: isPath ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
