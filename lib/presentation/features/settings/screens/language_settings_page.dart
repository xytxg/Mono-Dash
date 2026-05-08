import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/sub_menu_page.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(localeControllerProvider);

    return FrostedScaffold(
      title: l10n.settings_language_title,
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
                  title: l10n.settings_language_sectionTitle,
                  children: AppLocaleOption.values.map((option) {
                    final isSelected = option == selected;
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: isSelected
                          ? null
                          : () => ref
                                .read(localeControllerProvider.notifier)
                                .setOption(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.labelOf(l10n),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.label(context),
                                    ),
                                  ),
                                  if (option == AppLocaleOption.system)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        l10n.settings_language_systemSubtitle,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.secondaryLabel(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Opacity(
                              opacity: isSelected ? 1 : 0,
                              child: Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                color: CupertinoColors.activeBlue.resolveFrom(
                                  context,
                                ),
                                size: 24,
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
