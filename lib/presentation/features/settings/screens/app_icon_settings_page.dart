import 'package:dynamic_app_icon_flutter_plus/dynamic_app_icon_flutter_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/sub_menu_page.dart';
import '../providers/app_settings_provider.dart';

class AppIconSettingsPage extends ConsumerWidget {
  const AppIconSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsControllerProvider);
    final selectedVariant =
        settingsAsync.valueOrNull?.appIconVariant ?? AppIconVariant.defaultIcon;
    final l10n = context.l10n;

    return FrostedScaffold(
      title: l10n.settings_appearance_appIconTitle,
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
                  title: l10n.settings_appIcon_selectTitle,
                  children: AppIconVariant.values.map((variant) {
                    final isSelected = variant == selectedVariant;
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: isSelected || settingsAsync.isLoading
                          ? null
                          : () => _setAppIconVariant(
                              context,
                              ref,
                              selectedVariant,
                              variant,
                            ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoColors.black.withValues(
                                      alpha: 0.1,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  variant.assetPath,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                variant.labelOf(l10n),
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
                                color: CupertinoColors.activeBlue.resolveFrom(
                                  context,
                                ),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.settings_appIcon_hint,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryLabel(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Future<void> _setAppIconVariant(
    BuildContext context,
    WidgetRef ref,
    AppIconVariant previousVariant,
    AppIconVariant variant,
  ) async {
    final controller = ref.read(appSettingsControllerProvider.notifier);
    final unsupportedMessage = context.l10n.settings_appIcon_unsupported;
    final failedTitle = context.l10n.settings_appIcon_failedTitle;
    final okLabel = context.l10n.common_ok;
    await controller.setAppIconVariant(variant);

    try {
      final isSupported =
          await DynamicAppIconFlutterPlus.supportsAlternateIcons;
      if (!isSupported) {
        throw PlatformException(
          code: 'unsupported',
          message: unsupportedMessage,
        );
      }

      await DynamicAppIconFlutterPlus.setAlternateIconName(
        variant.alternateIconName,
      );
    } catch (error) {
      await controller.setAppIconVariant(previousVariant);
      if (!context.mounted) return;

      showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(failedTitle),
          content: Text('$error'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(okLabel),
            ),
          ],
        ),
      );
    }
  }
}
