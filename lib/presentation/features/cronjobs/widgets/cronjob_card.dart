import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/cronjob/cronjob_dto.dart';
import '../../../../data/dto/cronjob/spec_helper.dart';
import '../providers/cronjob_provider.dart';

class CronjobCard extends StatelessWidget {
  const CronjobCard({super.key, required this.item, required this.onTap});

  final CronjobDto item;
  final VoidCallback onTap;

  static const _typeColors = {
    'shell': CupertinoColors.systemGreen,
    'app': CupertinoColors.systemBlue,
    'website': CupertinoColors.systemIndigo,
    'database': CupertinoColors.systemPurple,
    'directory': CupertinoColors.systemOrange,
    'log': CupertinoColors.systemBrown,
    'curl': CupertinoColors.systemTeal,
    'cutWebsiteLog': CupertinoColors.systemPink,
    'clean': CupertinoColors.systemGrey,
    'snapshot': CupertinoColors.systemYellow,
    'ntp': CupertinoColors.activeBlue,
    'syncIpGroup': CupertinoColors.systemRed,
    'cleanLog': CupertinoColors.systemGrey,
  };

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'enable':
        return CupertinoColors.systemGreen;
      case 'disable':
        return CupertinoColors.systemGrey;
      case 'pending':
        return CupertinoColors.systemYellow;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  String _statusLabel(BuildContext context, String status) {
    final l10n = context.l10n;
    switch (status.toLowerCase()) {
      case 'enable':
        return l10n.cronjobs_statusEnabled;
      case 'disable':
        return l10n.cronjobs_statusDisabled;
      case 'pending':
        return l10n.cronjobs_statusPending;
      default:
        return status;
    }
  }

  String _formatTime(BuildContext context, String raw) {
    if (raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return formatRelativeTime(parsed, context.l10n);
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[item.type] ?? CupertinoColors.systemGrey;
    final icon = cronjobTypeIcons[item.type] ?? TablerIcons.clock;
    final typeLabel = cronjobTypeLabel(item.type, context.l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.separator(context).withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, size: 20, color: color),
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
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.4,
                                  color: AppColors.label(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                typeLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondaryLabel(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusIndicator(context),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Schedule information
                    Row(
                      children: [
                        Icon(
                          TablerIcons.clock,
                          size: 13,
                          color: AppColors.tertiaryLabel(context),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          describeSpec(item.spec, context.l10n),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryLabel(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          TablerIcons.history,
                          size: 13,
                          color: AppColors.tertiaryLabel(context),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          context.l10n.cronjobs_retentionCopies(
                            item.retainCopies,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryLabel(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground(
                    context,
                  ).withValues(alpha: 0.5),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.separator(
                        context,
                      ).withValues(alpha: 0.05),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (item.lastRecordStatus.isNotEmpty) ...[
                      _buildLastStatusIcon(context),
                      const SizedBox(width: 6),
                      Text(
                        _lastStatusText(context),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _lastStatusColor(context),
                        ),
                      ),
                    ] else
                      Text(
                        context.l10n.cronjobs_notExecutedYet,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.tertiaryLabel(context),
                        ),
                      ),
                    const Spacer(),
                    if (item.lastRecordTime.isNotEmpty) ...[
                      Text(
                        _formatTime(context, item.lastRecordTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.tertiaryLabel(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final statusColor = _statusColor(item.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
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
            _statusLabel(context, item.status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastStatusIcon(BuildContext context) {
    final s = item.lastRecordStatus.toLowerCase();
    if (s == 'success') {
      return Icon(
        TablerIcons.circle_check_filled,
        size: 14,
        color: CupertinoColors.systemGreen.resolveFrom(context),
      );
    } else if (s == 'failed') {
      return Icon(
        TablerIcons.circle_x_filled,
        size: 14,
        color: CupertinoColors.systemRed.resolveFrom(context),
      );
    }
    return Icon(
      TablerIcons.circle_filled,
      size: 14,
      color: CupertinoColors.systemGrey.resolveFrom(context),
    );
  }

  String _lastStatusText(BuildContext context) {
    final s = item.lastRecordStatus.toLowerCase();
    if (s == 'success') return context.l10n.cronjobs_runSuccess;
    if (s == 'failed') return context.l10n.cronjobs_runFailed;
    return item.lastRecordStatus;
  }

  Color _lastStatusColor(BuildContext context) {
    final s = item.lastRecordStatus.toLowerCase();
    if (s == 'success') return CupertinoColors.systemGreen.resolveFrom(context);
    if (s == 'failed') return CupertinoColors.systemRed.resolveFrom(context);
    return AppColors.secondaryLabel(context);
  }
}
