import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/l10n_x.dart';
import '../../../core/theme/app_theme.dart';
import 'action_sheet_launcher.dart';
import 'action_sheet_scaffold.dart';
import 'app_picker.dart';

/// 显示一个通用的列表选择 Action Sheet。
Future<T?> showAppActionPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<AppPickerOption<T>> options,
  required T selectedValue,
  bool isFloating = true,
}) {
  return showActionSheet<T>(
    context: context,
    useRootNavigator: true,
    builder: (_) => _AppActionPickerSheet<T>(
      title: title,
      options: options,
      selectedValue: selectedValue,
      isFloating: isFloating,
    ),
  );
}

class _AppActionPickerSheet<T> extends StatelessWidget {
  const _AppActionPickerSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    this.isFloating = true,
  });

  final String title;
  final List<AppPickerOption<T>> options;
  final T selectedValue;
  final bool isFloating;

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      isFloating: isFloating,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _OptionRow(
              icon: option.icon,
              label: option.label,
              selected: option.value == selectedValue,
              onTap: () => Navigator.of(context).pop(option.value),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.label(context)),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.label(context),
                ),
              ),
            ),
            if (selected)
              Icon(
                TablerIcons.check,
                size: 20,
                color: CupertinoColors.activeBlue.resolveFrom(context),
              ),
          ],
        ),
      ),
    );
  }
}
