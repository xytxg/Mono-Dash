import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';

/// Docker 状态警告卡片
class DockerWarningCard extends StatelessWidget {
  const DockerWarningCard({
    super.key,
    required this.isExist,
    required this.isActive,
  });

  final bool isExist;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoColors.systemOrange.resolveFrom(context);
    final message = !isExist
        ? context.l10n.appStore_dockerNotFoundWarning
        : !isActive
        ? context.l10n.appStore_dockerNotRunningWarning
        : context.l10n.appStore_dockerAbnormalWarning;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(TablerIcons.alert_triangle, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
