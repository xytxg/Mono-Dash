import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';

/// 数据库模块通用加载失败占位组件。
class DatabaseErrorPlaceholder extends StatelessWidget {
  const DatabaseErrorPlaceholder({
    super.key,
    required this.error,
    this.onRetry,
    this.padding = const EdgeInsets.all(32),
    this.iconColor,
  });

  final Object error;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        iconColor ?? CupertinoColors.systemOrange.resolveFrom(context);
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(TablerIcons.alert_triangle, size: 48, color: effectiveColor),
            const SizedBox(height: 16),
            Text(
              context.l10n.common_loadingFailed,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryLabel(context),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CupertinoButton(
                onPressed: onRetry,
                child: Text(context.l10n.common_retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 数据库模块通用「实例未运行」占位组件。
class DatabaseNotRunningPlaceholder extends StatelessWidget {
  const DatabaseNotRunningPlaceholder({
    super.key,
    this.status,
    this.icon = TablerIcons.player_pause,
    this.iconColor,
    this.title,
  });

  /// 当前状态文本，如 "exited"。为 null 时不显示详情。
  final String? status;

  /// 顶部图标。
  final IconData icon;

  /// 图标颜色。默认为 systemGrey。
  final Color? iconColor;

  /// 标题文本。
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: iconColor ?? CupertinoColors.systemGrey.resolveFrom(context),
          ),
          const SizedBox(height: 16),
          Text(
            title ?? context.l10n.databases_instanceNotRunning,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
            ),
          ),
          if (status != null) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.databases_instanceStatusMessage(status!),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
