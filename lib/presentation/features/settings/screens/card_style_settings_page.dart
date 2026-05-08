import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/server.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/sub_menu_page.dart';
import '../../servers/widgets/server_card_simple.dart';
import '../../servers/widgets/server_card_terminal.dart';
import '../../servers/widgets/server_card_shared.dart';
import '../providers/app_settings_provider.dart';

class CardStyleSettingsPage extends ConsumerWidget {
  const CardStyleSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsControllerProvider);
    final selectedStyle =
        settingsAsync.valueOrNull?.serverCardStyle ?? ServerCardStyle.simple;
    final l10n = context.l10n;

    final mockServer = Server()
      ..name = 'Production Server'
      ..host = '1.2.3.4'
      ..port = 8888
      ..createdAt = DateTime.now();

    const mockStatus = ServerCardStatus(isLoading: false, hasData: true);

    return FrostedScaffold(
      title: l10n.settings_appearance_cardStyleTitle,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: FrostedScaffold.contentTopPadding(context) + 16,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SubMenuCard(
                  title: l10n.settings_cardStyle_selectTitle,
                  children: ServerCardStyle.values.map((style) {
                    final isSelected = style == selectedStyle;
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: isSelected || settingsAsync.isLoading
                          ? null
                          : () => ref
                                .read(appSettingsControllerProvider.notifier)
                                .setServerCardStyle(style),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    style.labelOf(l10n),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.label(context),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    CupertinoIcons.checkmark_circle_fill,
                                    color: CupertinoColors.activeBlue
                                        .resolveFrom(context),
                                    size: 24,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Preview
                            IgnorePointer(
                              child: style == ServerCardStyle.terminal
                                  ? TerminalServerCard(
                                      server: mockServer,
                                      status: mockStatus,
                                      dashboard: null,
                                      onTap: () {},
                                      isSelected: false,
                                    )
                                  : SimpleServerCard(
                                      server: mockServer,
                                      status: mockStatus,
                                      dashboard: null,
                                      onTap: () {},
                                      isSelected: false,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
