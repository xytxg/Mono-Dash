import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../../files/screens/files_page.dart';
import '../../server_detail/providers/active_server_provider.dart';
import 'website_action_sheet.dart';

class WebsiteListItem extends ConsumerWidget {
  const WebsiteListItem({
    super.key,
    required this.website,
    this.loading = false,
  });

  final WebsiteDto website;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final cardBackground = isDark
        ? AppColors.tertiaryBackground(context)
        : AppColors.secondaryBackground(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => showWebsiteActionSheet(context, ref, website),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderRow(website: website, ref: ref, loading: loading),
              const SizedBox(height: 8),
              _DomainRow(website: website, loading: loading),
              const SizedBox(height: 8),
              _InfoRow(website: website, ref: ref, loading: loading),
              const SizedBox(height: 8),
              _FooterRow(website: website, loading: loading),
            ],
          ),
        ),
      ),
    );
  }

  static String expireText(BuildContext context, String value) {
    if (value.isEmpty) return context.l10n.websites_notSet;
    if (value == '9999-12-31T00:00:00Z') {
      return context.l10n.websites_neverExpires;
    }

    final expireAt = DateTime.tryParse(value)?.toLocal();
    if (expireAt == null) return value;

    final diff = expireAt.difference(DateTime.now());
    final abs = diff.abs();
    if (diff.isNegative) {
      if (abs.inDays >= 365) {
        return context.l10n.websites_expiredYearsAgo(abs.inDays ~/ 365);
      }
      if (abs.inDays >= 30) {
        return context.l10n.websites_expiredMonthsAgo(abs.inDays ~/ 30);
      }
      if (abs.inDays >= 1) {
        return context.l10n.websites_expiredDaysAgo(abs.inDays);
      }
      if (abs.inHours >= 1) {
        return context.l10n.websites_expiredHoursAgo(abs.inHours);
      }
      if (abs.inMinutes >= 1) {
        return context.l10n.websites_expiredMinutesAgo(abs.inMinutes);
      }
      return context.l10n.websites_justExpired;
    }

    if (abs.inDays >= 365) {
      return context.l10n.websites_expiresInYears(abs.inDays ~/ 365);
    }
    if (abs.inDays >= 30) {
      return context.l10n.websites_expiresInMonths(abs.inDays ~/ 30);
    }
    if (abs.inDays >= 1) {
      return context.l10n.websites_expiresInDays(abs.inDays);
    }
    if (abs.inHours >= 1) {
      return context.l10n.websites_expiresInHours(abs.inHours);
    }
    if (abs.inMinutes >= 1) {
      return context.l10n.websites_expiresInMinutes(abs.inMinutes);
    }
    return context.l10n.websites_expiringSoon;
  }

  static String typeText(BuildContext context, String type) {
    return switch (type) {
      'static' => context.l10n.websites_staticWebsite,
      'proxy' => context.l10n.websites_reverseProxy,
      'deployment' => context.l10n.websites_runtimeWebsite,
      _ => type.isEmpty ? context.l10n.websites_website : type,
    };
  }

  static String statusText(BuildContext context, String status) {
    return switch (status.toLowerCase()) {
      'running' => context.l10n.websites_statusRunning,
      'stopped' || 'stoped' => context.l10n.websites_statusStopped,
      'starting' => context.l10n.websites_statusStarting,
      'restarting' => context.l10n.websites_statusRestarting,
      'error' => context.l10n.websites_statusError,
      _ => status.isEmpty ? context.l10n.common_unknown : status,
    };
  }

  static String dateText(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) return '';
    final year = parsed.year.toString().padLeft(4, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static final _ipPattern = RegExp(r'^\d{1,3}(\.\d{1,3}){3}(:\d+)?$');

  static Uri? websiteUri(WebsiteDto website) {
    final domain = website.primaryDomain.trim();
    if (domain.isEmpty) return null;

    final withScheme = domain.contains('://');
    final uri = withScheme
        ? Uri.tryParse(domain)
        : Uri.tryParse(
            '${website.protocol.toLowerCase() == 'https' ? 'https' : 'http'}://$domain',
          );
    if (uri == null) return null;

    final host = uri.host;
    if (host.isEmpty) return null;
    if (host == 'localhost' || host.startsWith('localhost:')) return uri;
    if (_ipPattern.hasMatch(host)) return uri;
    if (host.contains('.')) return uri;

    return null;
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.website,
    required this.ref,
    required this.loading,
  });

  final WebsiteDto website;
  final WidgetRef ref;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isRunning = website.status.toLowerCase() == 'running';
    final statusColor = isRunning
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemRed.resolveFrom(context);

    return Row(
      children: [
        if (loading)
          const SkeletonItem.text(width: 60, height: 20, borderRadius: 4)
        else
          _Badge(
            text: WebsiteListItem.typeText(context, website.type),
            color: CupertinoColors.systemIndigo.resolveFrom(context),
          ),
        const Spacer(),
        if (loading)
          const SkeletonItem.text(width: 48, height: 20, borderRadius: 4)
        else
          _Badge(
            text: WebsiteListItem.statusText(context, website.status),
            color: statusColor,
          ),
      ],
    );
  }
}

class _DomainRow extends StatelessWidget {
  const _DomainRow({required this.website, required this.loading});

  final WebsiteDto website;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final sslState = _SslState.fromWebsite(context, website);
    final url = WebsiteListItem.websiteUri(website);

    return Row(
      children: [
        if (loading)
          const SkeletonItem.text(width: 14, height: 14)
        else
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(20),
            onPressed: () => sslState.showDialog(context),
            child: Icon(
              sslState.icon,
              size: 14,
              color: sslState.color.resolveFrom(context),
            ),
          ),
        const SizedBox(width: 6),
        Expanded(
          child: loading
              ? const SkeletonItem.text(width: 180, height: 18)
              : CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 22),
                  alignment: Alignment.centerLeft,
                  onPressed: url == null
                      ? null
                      : () async {
                          final launched = await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!launched && context.mounted) {
                            showAppErrorToast(
                              context.l10n.websites_openBrowserFailed,
                            );
                          }
                        },
                  child: Text(
                    website.primaryDomain.isEmpty
                        ? context.l10n.websites_unnamedWebsite
                        : website.primaryDomain,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.website,
    required this.ref,
    required this.loading,
  });

  final WebsiteDto website;
  final WidgetRef ref;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final path = website.sitePath.isNotEmpty
        ? website.sitePath
        : (website.siteDir.isNotEmpty
              ? website.siteDir
              : context.l10n.websites_directoryNotSet);

    return Row(
      children: [
        if (loading) ...[
          const SkeletonItem.text(width: 14, height: 14),
          const SizedBox(width: 6),
          const Expanded(child: SkeletonItem.text(width: 200, height: 12)),
          const SizedBox(width: 6),
          const SkeletonItem.text(width: 11, height: 11),
        ] else
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 20),
              alignment: Alignment.centerLeft,
              onPressed: path == context.l10n.websites_directoryNotSet
                  ? null
                  : () {
                      final serverId = ref.read(activeServerIdProvider);
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => ProviderScope(
                            overrides: [
                              activeServerIdProvider.overrideWithValue(
                                serverId,
                              ),
                            ],
                            child: StandaloneFilesPage(initialPath: path),
                          ),
                        ),
                      );
                    },
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.folder,
                    size: 14,
                    color: CupertinoColors.systemOrange.resolveFrom(context),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 11,
                    color: AppColors.tertiaryLabel(context),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({required this.website, required this.loading});

  final WebsiteDto website;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final remark = website.remark.isEmpty
        ? context.l10n.websites_noRemark
        : website.remark;

    return Row(
      children: [
        if (loading) ...[
          const SkeletonItem.text(width: 14, height: 14),
          const SizedBox(width: 6),
          const Expanded(child: SkeletonItem.text(width: 100, height: 12)),
          const Spacer(),
          const SkeletonItem.text(width: 12, height: 12),
          const SizedBox(width: 4),
          const SkeletonItem.text(width: 60, height: 12),
        ] else ...[
          Icon(
            CupertinoIcons.text_alignleft,
            size: 14,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              remark,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            CupertinoIcons.calendar,
            size: 12,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(width: 4),
          Text(
            WebsiteListItem.expireText(context, website.expireDate),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ],
    );
  }
}

class _SslState {
  const _SslState({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.isWarning = false,
  });

  final IconData icon;
  final CupertinoDynamicColor color;
  final String title;
  final String message;
  final bool isWarning;

  factory _SslState.fromWebsite(BuildContext context, WebsiteDto website) {
    final hasSsl = website.protocol.toLowerCase() != 'http';
    if (!hasSsl) {
      return _SslState(
        icon: CupertinoIcons.lock_open_fill,
        color: CupertinoColors.systemGrey,
        title: context.l10n.websites_sslDisabledTitle,
        message: context.l10n.websites_sslDisabledMessage,
      );
    }

    final sslExpireAt = DateTime.tryParse(website.sslExpireDate)?.toLocal();
    if (sslExpireAt != null && sslExpireAt.isBefore(DateTime.now())) {
      return _SslState(
        icon: CupertinoIcons.exclamationmark_triangle_fill,
        color: CupertinoColors.systemRed,
        title: context.l10n.websites_sslExpiredTitle,
        message: context.l10n.websites_sslExpiredMessage(
          WebsiteListItem.expireText(context, website.sslExpireDate),
        ),
        isWarning: true,
      );
    }

    final expireText = website.sslExpireDate.isEmpty
        ? context.l10n.websites_sslExpiryUnknown
        : WebsiteListItem.expireText(context, website.sslExpireDate);
    return _SslState(
      icon: CupertinoIcons.lock_fill,
      color: CupertinoColors.systemGreen,
      title: context.l10n.websites_sslEnabledTitle,
      message: context.l10n.websites_sslEnabledMessage(expireText),
    );
  }

  void showDialog(BuildContext context) {
    if (isWarning) {
      showAppWarningToast(title, description: message);
    } else {
      showAppToast(title, description: message);
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
