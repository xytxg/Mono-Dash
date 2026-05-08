import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/app_action_components.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FrostedScaffold(
      title: context.l10n.panelSettings_about,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: FrostedScaffold.contentTopPadding(context) + 8,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 132),
            sliver: SliverList.list(
              children: [
                // ── Logo 与名称 ──
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: CupertinoColors.activeBlue
                              .resolveFrom(context)
                              .withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          TablerIcons.server_2,
                          size: 40,
                          color: CupertinoColors.activeBlue.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '1Panel',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.panelSettings_aboutProductSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── 链接 ──
                AppSectionHeader(
                  title: context.l10n.panelSettings_links,
                  icon: TablerIcons.link,
                ),
                AppActionGroup(
                  children: [
                    AppActionRow(
                      icon: TablerIcons.book,
                      iconColor: CupertinoColors.systemBlue,
                      title: context.l10n.panelSettings_officialDocs,
                      subtitle: const Text('docs.1panel.pro'),
                      onTap: () => _openUrl('https://docs.1panel.pro'),
                    ),
                    AppActionRow(
                      icon: TablerIcons.brand_github,
                      iconColor: AppColors.label(context),
                      title: 'GitHub',
                      subtitle: const Text('1Panel-dev/1Panel'),
                      onTap: () =>
                          _openUrl('https://github.com/1Panel-dev/1Panel'),
                    ),
                    AppActionRow(
                      icon: TablerIcons.message_circle,
                      iconColor: CupertinoColors.systemGreen,
                      title: context.l10n.panelSettings_community,
                      subtitle: Text(
                        context.l10n.panelSettings_communitySubtitle,
                      ),
                      onTap: () => _openUrl(
                        'https://github.com/1Panel-dev/1Panel/discussions',
                      ),
                    ),
                    AppActionRow(
                      icon: TablerIcons.bug,
                      iconColor: CupertinoColors.systemOrange,
                      title: context.l10n.panelSettings_feedback,
                      subtitle: Text(
                        context.l10n.panelSettings_feedbackSubtitle,
                      ),
                      onTap: () => _openUrl(
                        'https://github.com/1Panel-dev/1Panel/issues',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── 关于客户端 ──
                AppSectionHeader(
                  title: context.l10n.panelSettings_client,
                  icon: TablerIcons.device_mobile,
                ),
                AppActionGroup(
                  children: [
                    AppActionRow(
                      icon: TablerIcons.info_circle,
                      iconColor: CupertinoColors.systemGrey,
                      title: '1Panel Mate',
                      subtitle: Text(context.l10n.panelSettings_clientSubtitle),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
