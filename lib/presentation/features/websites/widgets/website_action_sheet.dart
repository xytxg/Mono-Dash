import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/defer_init.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../providers/website_detail_provider.dart';
import 'website_domain_sheet.dart';
import 'website_dir_sheet.dart';
import 'website_index_sheet.dart';
import 'website_limit_sheet.dart';
import 'website_log_sheet.dart';
import 'website_other_sheet.dart';
import 'website_proxy_sheet.dart';
import 'website_auth_sheet.dart';
import 'website_leech_sheet.dart';
import 'website_real_ip_sheet.dart';
import 'website_cors_sheet.dart';
import 'website_rewrite_sheet.dart';
import 'website_redirect_sheet.dart';
import 'website_https_sheet.dart';
import 'website_config_sheet.dart';
import 'website_list_item.dart';
import 'website_php_sheet.dart';
import 'website_resource_sheet.dart';
import '../../../common/components/skeleton_item.dart';

void showWebsiteActionSheet(
  BuildContext context,
  WidgetRef ref,
  WebsiteDto website,
) {
  showActionSheet(
    context: context,
    builder: (context) => _WebsiteActionSheet(website: website),
  );
}

class _WebsiteActionSheet extends StatelessWidget {
  const _WebsiteActionSheet({required this.website});

  final WebsiteDto website;

  @override
  Widget build(BuildContext context) {
    return DeferInit(
      builder: (context, isReady) {
        if (!isReady) {
          return _buildStaticContent(
            context,
            website: website,
            enableBlur: false,
            content: _SheetContent(
              website: website,
              detail: null,
              isDetailLoading: true,
              hasDetailError: false,
            ),
          );
        }
        return Consumer(
          builder: (context, ref, _) {
            final detailAsync = ref.watch(websiteDetailProvider(website.id));
            final detail = detailAsync.valueOrNull;
            final displayWebsite = detail?.website ?? website;

            return _buildStaticContent(
              context,
              website: displayWebsite,
              detail: detail,
              isDetailLoading: detailAsync.isLoading,
              enableBlur: true,
              content: _SheetContent(
                website: displayWebsite,
                detail: detail,
                isDetailLoading: detailAsync.isLoading,
                hasDetailError: detailAsync.hasError && detail == null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaticContent(
    BuildContext context, {
    required WebsiteDto website,
    WebsiteDetailDto? detail,
    bool isDetailLoading = false,
    required bool enableBlur,
    Widget? content,
  }) {
    final isRunning = website.status.toLowerCase() == 'running';
    final statusColor = isRunning
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemRed.resolveFrom(context);
    final statusIcon = isRunning
        ? TablerIcons.circle_check_filled
        : TablerIcons.circle_x_filled;

    final protocol = website.protocol.isEmpty
        ? 'HTTP'
        : website.protocol.toUpperCase();
    final protocolColor = protocol == 'HTTPS'
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemBlue.resolveFrom(context);

    final visual = _typeVisual(context, website);
    final domainCount = detail?.domains.length;

    return ActionSheetScaffold(
      enableBlur: enableBlur,
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: protocolColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(TablerIcons.world_www, color: protocolColor, size: 29),
              Positioned(
                right: 7,
                bottom: 7,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: visual.accent.withValues(alpha: 0.22),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(visual.icon, color: visual.accent, size: 10),
                ),
              ),
            ],
          ),
        ),
        title: website.primaryDomain,
        subtitle: '',
        trailing: Icon(statusIcon, size: 28, color: statusColor),
        chips: [
          _InfoChip(
            icon: visual.icon,
            label: WebsiteListItem.typeText(context, website.type),
            color: visual.accent,
          ),
          _InfoChip(
            icon: TablerIcons.shield_lock,
            label: protocol,
            color: protocolColor,
          ),
          if (detail != null || isDetailLoading)
            _InfoChip(
              icon: TablerIcons.at,
              label: detail != null
                  ? context.l10n.websites_domainCount(domainCount ?? 0)
                  : context.l10n.websites_loadingCount,
              isLoading: isDetailLoading,
              color: CupertinoColors.systemIndigo.resolveFrom(context),
            ),
        ],
      ),
      child: content ?? const _LoadingContent(),
    );
  }

  static ({IconData icon, Color accent}) _typeVisual(
    BuildContext context,
    WebsiteDto website,
  ) {
    final t = website.type.toLowerCase();
    final rt = website.websiteRuntimeType.toLowerCase();
    final isPhp =
        t == 'php' || rt == 'php' || (t == 'deployment' && rt == 'php');
    if (t == 'static') {
      return (
        icon: TablerIcons.file_type_html,
        accent: CupertinoColors.systemOrange.resolveFrom(context),
      );
    }
    if (isPhp) {
      return (
        icon: TablerIcons.brand_php,
        accent: CupertinoColors.systemPurple.resolveFrom(context),
      );
    }
    return (
      icon: TablerIcons.route,
      accent: CupertinoColors.activeBlue.resolveFrom(context),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 46),
      child: CupertinoActivityIndicator(),
    );
  }
}

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.website,
    required this.detail,
    required this.isDetailLoading,
    required this.hasDetailError,
  });

  final WebsiteDto website;
  final WebsiteDetailDto? detail;
  final bool isDetailLoading;
  final bool hasDetailError;

  @override
  Widget build(BuildContext context) {
    final detailWebsite = detail?.website ?? website;
    final sitePath = detail != null
        ? Text(detailWebsite.sitePath.isEmpty ? '--' : detailWebsite.sitePath)
        : (hasDetailError
              ? Text(context.l10n.websites_detailLoadFailed)
              : const SkeletonItem(width: 160, height: 14));
    final runtimeName = detail != null
        ? Text(
            detailWebsite.runtimeName.isEmpty
                ? context.l10n.websites_noPhpRuntimeBound
                : detailWebsite.runtimeName,
          )
        : (hasDetailError
              ? Text(context.l10n.websites_detailLoadFailed)
              : const SkeletonItem(width: 120, height: 14));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSectionHeader(
          title: context.l10n.websites_settings,
          icon: TablerIcons.world_cog,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.at,
              iconColor: CupertinoColors.systemBlue,
              title: context.l10n.websites_domainSettings,
              subtitle: Text(context.l10n.websites_domainSettingsSubtitle),
              onTap: () => showWebsiteDomainSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.folder_root,
              iconColor: CupertinoColors.systemOrange,
              title: context.l10n.websites_siteDirectory,
              subtitle: sitePath,
              onTap: () {
                final loadedDetail = detail;
                if (loadedDetail == null) {
                  showAppToast(
                    context.l10n.websites_siteDirectory,
                    description: context.l10n.websites_detailLoadingRetry,
                  );
                  return;
                }
                showWebsiteDirSheet(context, detail: loadedDetail);
              },
            ),
            AppActionRow(
              icon: TablerIcons.file_type_html,
              iconColor: CupertinoColors.systemIndigo,
              title: context.l10n.websites_defaultDocument,
              subtitle: Text(context.l10n.websites_defaultDocumentSubtitle),
              onTap: () => showWebsiteIndexSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.gauge,
              iconColor: CupertinoColors.systemTeal,
              title: context.l10n.websites_trafficLimit,
              subtitle: Text(context.l10n.websites_trafficLimitSubtitle),
              onTap: () => showWebsiteLimitSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.websites_accessControl,
          icon: TablerIcons.lock,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.route,
              iconColor: CupertinoColors.systemPurple,
              title: context.l10n.websites_reverseProxy,
              subtitle: Text(context.l10n.websites_reverseProxySubtitle),
              onTap: () => showWebsiteProxySheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            // AppActionRow(
            //   icon: TablerIcons.server,
            //   iconColor: CupertinoColors.systemGreen,
            //   title: 'Load Balancing',
            //   subtitle: const Text('Configure upstream servers and scheduling algorithm'),
            //   onTap: () => showAppTodoToast('Load Balancing'),
            // ),
            AppActionRow(
              icon: TablerIcons.password_user,
              iconColor: CupertinoColors.systemRed,
              title: context.l10n.websites_passwordAccess,
              subtitle: Text(context.l10n.websites_passwordAccessSubtitle),
              onTap: () => showWebsiteAuthSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.arrows_exchange_2,
              iconColor: CupertinoColors.activeBlue,
              title: context.l10n.websites_corsAccess,
              subtitle: Text(context.l10n.websites_corsAccessSubtitle),
              onTap: () => showWebsiteCorsSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.shield_lock,
              iconColor: CupertinoColors.systemGreen,
              title: 'HTTPS',
              subtitle: _httpsSubtitle(
                context,
                website: detailWebsite,
                detail: detail,
                isDetailLoading: isDetailLoading,
                hasDetailError: hasDetailError,
              ),
              onTap: () => showWebsiteHttpsSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.cloud_lock_open,
              iconColor: CupertinoColors.systemGreen,
              title: context.l10n.websites_realIp,
              subtitle: Text(context.l10n.websites_realIpSubtitle),
              onTap: () => showWebsiteRealIpSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.websites_rulesAndRuntime,
          icon: TablerIcons.settings,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.wand,
              iconColor: CupertinoColors.systemPink,
              title: context.l10n.websites_rewrite,
              subtitle: Text(context.l10n.websites_rewriteSubtitle),
              onTap: () => showWebsiteRewriteSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.hand_stop,
              iconColor: CupertinoColors.systemOrange,
              title: context.l10n.websites_antiLeech,
              subtitle: Text(context.l10n.websites_antiLeechSubtitle),
              onTap: () => showWebsiteLeechSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.arrow_forward_up,
              iconColor: CupertinoColors.systemBlue,
              title: context.l10n.websites_redirect,
              subtitle: Text(context.l10n.websites_redirectSubtitle),
              onTap: () => showWebsiteRedirectSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.brand_php,
              iconColor: CupertinoColors.systemPurple,
              title: 'PHP',
              subtitle: runtimeName,
              onTap: () => showWebsitePhpSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.chart_bar,
              iconColor: CupertinoColors.systemTeal,
              title: context.l10n.websites_resource,
              subtitle: Text(context.l10n.websites_resourceSubtitle),
              onTap: () => showWebsiteResourceSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.dots,
              iconColor: CupertinoColors.systemGrey,
              title: context.l10n.websites_other,
              subtitle: Text(context.l10n.websites_otherSubtitle),
              onTap: () {
                final loadedDetail = detail;
                if (loadedDetail == null) {
                  showAppToast(
                    context.l10n.websites_other,
                    description: context.l10n.websites_detailLoadingRetry,
                  );
                  return;
                }
                showWebsiteOtherSheet(context, detail: loadedDetail);
              },
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.websites_diagnostics,
          icon: TablerIcons.file_search,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.logs,
              iconColor: CupertinoColors.systemBrown,
              title: context.l10n.websites_logs,
              subtitle: Text(context.l10n.websites_logsSubtitle),
              onTap: () {
                final loadedDetail = detail;
                if (loadedDetail == null) {
                  showAppToast(
                    context.l10n.websites_logs,
                    description: context.l10n.websites_detailLoadingRetry,
                  );
                  return;
                }
                showWebsiteLogSheet(context, detail: loadedDetail);
              },
            ),
            AppActionRow(
              icon: TablerIcons.file_settings,
              iconColor: CupertinoColors.systemIndigo,
              title: context.l10n.websites_configFile,
              subtitle: Text(context.l10n.websites_configFileSubtitle),
              onTap: () => showWebsiteConfigSheet(
                context,
                websiteId: detailWebsite.id,
                title: detailWebsite.primaryDomain,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _httpsSubtitle(
    BuildContext context, {
    required WebsiteDto website,
    required WebsiteDetailDto? detail,
    required bool isDetailLoading,
    required bool hasDetailError,
  }) {
    if (website.protocol.toLowerCase() == 'http') {
      return Text(context.l10n.websites_sslNotEnabled);
    }
    if (detail == null) {
      if (hasDetailError) {
        return Text(context.l10n.websites_certificateLoadFailed);
      }
      return isDetailLoading
          ? const SkeletonItem(width: 100, height: 14)
          : Text(context.l10n.websites_httpsEnabled);
    }
    final ssl = detail.ssl;
    if (ssl == null || ssl.expireDate.startsWith('0001-')) {
      return Text(context.l10n.websites_httpsEnabled);
    }
    return Text(
      context.l10n.websites_certificateExpiry(
        WebsiteListItem.expireText(context, ssl.expireDate),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.14), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          if (isLoading)
            const SkeletonItem(width: 45, height: 10, borderRadius: 4)
          else
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.1,
                height: 1,
              ),
            ),
        ],
      ),
    );
  }
}
