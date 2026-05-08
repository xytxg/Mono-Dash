import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../core/localization/l10n_x.dart';
import '../../../core/theme/app_theme.dart';

/// Header search field used inside [FrostedScaffold.trailingBuilder].
///
/// It gives CupertinoSearchTextField an explicit surface so list content under
/// the frosted header does not bleed through the input while focused.
class AppHeaderSearchField extends StatelessWidget {
  const AppHeaderSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.onChanged,
    required this.onCancel,
    this.onSubmitted,
    this.onClear,
    this.actions = const [],
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback onCancel;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width - 32;
    final fieldBorderColor = isDark
        ? CupertinoColors.white.withValues(alpha: 0.10)
        : CupertinoColors.white.withValues(alpha: 0.72);
    final buttonBorderColor = isDark
        ? CupertinoColors.white.withValues(alpha: 0.08)
        : CupertinoColors.white.withValues(alpha: 0.62);
    final surfaceColor = isDark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.86)
        : CupertinoColors.systemBackground
              .resolveFrom(context)
              .withValues(alpha: 0.94);
    final cancelSurfaceColor = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.42)
        : CupertinoColors.systemBackground
              .resolveFrom(context)
              .withValues(alpha: 0.54);

    return SizedBox(
      width: width,
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: fieldBorderColor, width: 0.6),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(
                      alpha: isDark ? 0.14 : 0.035,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: CupertinoSearchTextField(
                    controller: controller,
                    focusNode: focusNode,
                    placeholder: placeholder,
                    autocorrect: false,
                    backgroundColor: surfaceColor,
                    borderRadius: BorderRadius.circular(11),
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.label(context),
                    ),
                    placeholderStyle: TextStyle(
                      fontSize: 15,
                      color: AppColors.secondaryLabel(context),
                    ),
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    onSuffixTap: () {
                      controller.clear();
                      onClear?.call();
                    },
                  ),
                ),
              ),
            ),
          ),
          for (final action in actions) ...[const SizedBox(width: 8), action],
          const SizedBox(width: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cancelSurfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: buttonBorderColor, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  minimumSize: const Size(48, 32),
                  onPressed: onCancel,
                  child: Text(
                    context.l10n.common_cancel,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.activeBlue.resolveFrom(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
