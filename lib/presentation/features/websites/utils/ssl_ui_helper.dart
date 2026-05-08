import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';

class SslUIHelper {
  static String getStatusLabel(BuildContext context, String status) {
    final l10n = context.l10n;
    switch (status) {
      case 'ready':
      case 'normal':
        return l10n.websites_statusNormal;
      case 'expired':
        return l10n.websites_statusExpired;
      case 'error':
        return l10n.websites_statusError;
      case 'init':
        return l10n.websites_statusPendingApply;
      case 'applying':
        return l10n.websites_statusApplying;
      case 'applyError':
        return l10n.websites_statusApplyFailed;
      case 'systemRestart':
        return l10n.websites_statusRestartInterrupted;
      default:
        return status.isEmpty ? l10n.websites_unknown : status;
    }
  }

  static Color getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'ready':
      case 'normal':
        return CupertinoColors.systemGreen.resolveFrom(context);
      case 'expired':
      case 'error':
      case 'applyError':
        return CupertinoColors.systemRed.resolveFrom(context);
      case 'applying':
        return CupertinoColors.systemBlue.resolveFrom(context);
      case 'init':
      case 'systemRestart':
        return CupertinoColors.systemGrey.resolveFrom(context);
      default:
        return CupertinoColors.systemGrey.resolveFrom(context);
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'ready':
      case 'normal':
        return TablerIcons.circle_check_filled;
      case 'expired':
        return TablerIcons.clock;
      case 'error':
      case 'applyError':
        return TablerIcons.alert_triangle;
      case 'applying':
        return TablerIcons.loader_quarter;
      case 'init':
      case 'systemRestart':
        return TablerIcons.help_circle;
      default:
        return TablerIcons.question_mark;
    }
  }

  static String getProviderLabel(
    BuildContext context,
    String provider,
    String type,
  ) {
    final l10n = context.l10n;
    switch (provider) {
      case 'dnsAccount':
        return l10n.websites_dnsAutoValidation;
      case 'dnsManual':
        return l10n.websites_dnsManualValidation;
      case 'http':
        return l10n.websites_httpValidation;
      case 'manual':
        return l10n.websites_manualImport;
      case 'selfSigned':
        return l10n.websites_selfSignedCertificate;
      case 'fromMaster':
        return l10n.websites_masterNodePush;
      default:
        if (provider.isNotEmpty) return provider;
        if (type.isNotEmpty) return type;
        return l10n.websites_sslCertificate;
    }
  }

  static String getExpireText(
    BuildContext context,
    String expireDate, {
    bool relative = true,
  }) {
    if (expireDate.isEmpty) return '--';
    final date = DateTime.tryParse(expireDate);
    if (date == null) return expireDate;

    if (relative) {
      return context.l10n.websites_sslExpiresRelative(
        formatRelativeTime(date, context.l10n),
      );
    } else {
      final locale = Localizations.localeOf(context).toLanguageTag();
      return formatLocalDateTime(expireDate, locale: locale);
    }
  }

  static Color getExpireColor(BuildContext context, String expireDate) {
    if (expireDate.isEmpty) return AppColors.tertiaryLabel(context);
    final date = DateTime.tryParse(expireDate);
    if (date == null) return AppColors.tertiaryLabel(context);

    final now = DateTime.now();
    if (date.isBefore(now)) {
      return CupertinoColors.systemRed.resolveFrom(context);
    }
    if (date.difference(now).inDays < 30) {
      return CupertinoColors.systemOrange.resolveFrom(context);
    }
    return AppColors.tertiaryLabel(context);
  }
}
