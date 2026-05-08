import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../core/localization/l10n_x.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/theme/app_theme.dart';
import '../app_toast.dart';

/// 统一的空状态展示组件。
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 42),
    this.useCardStyle = false,
    this.onAction,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final bool useCardStyle;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: AppColors.tertiaryLabel(context)),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.label(context),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: 18),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue
                    .resolveFrom(context)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (!useCardStyle) {
      return Padding(
        padding: padding,
        child: Center(child: content),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: content,
    );
  }
}

/// 统一的错误展示组件。
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    required this.error,
    this.onRetry,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
  });

  final String title;
  final Object error;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final message = _errorMessage(error, context);
    final statusCode = error is AppNetworkException
        ? (error as AppNetworkException).statusCode
        : null;

    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange
                      .resolveFrom(context)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  TablerIcons.alert_triangle,
                  size: 22,
                  color: CupertinoColors.systemOrange.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
              const SizedBox(height: 10),
              _ErrorDetailBox(message: message, statusCode: statusCode),
              if (onRetry != null) ...[
                const SizedBox(height: 14),
                _RetryButton(onPressed: onRetry!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _errorMessage(Object error, BuildContext context) {
    if (error case AppNetworkException(:final message)) {
      return message.trim().isEmpty
          ? context.l10n.common_networkRequestFailed
          : message;
    }
    final text = error.toString().trim();
    return text.isEmpty ? context.l10n.common_requestFailed : text;
  }
}

class _ErrorDetailBox extends StatelessWidget {
  const _ErrorDetailBox({required this.message, required this.statusCode});

  final String message;
  final int? statusCode;

  @override
  Widget build(BuildContext context) {
    final detail = statusCode == null
        ? message
        : '$message\n${context.l10n.common_statusCode(statusCode!)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground(context).withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.14),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              detail,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: detail));
              showAppToast(context.l10n.common_errorInfoCopied);
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(
                  context,
                ).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.separator(context).withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
              child: Icon(
                TablerIcons.copy,
                size: 15,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: CupertinoColors.activeBlue
              .resolveFrom(context)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: CupertinoColors.activeBlue
                .resolveFrom(context)
                .withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.refresh,
              size: 15,
              color: CupertinoColors.activeBlue.resolveFrom(context),
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.common_retry,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.activeBlue.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
