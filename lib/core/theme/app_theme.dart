import 'package:flutter/cupertino.dart';

/// App color palette
class AppColors {
  // Primary colors
  static const Color primary = CupertinoColors.systemBlue;
  static const Color secondary = CupertinoColors.systemGrey;

  // Status colors
  static const Color success = CupertinoColors.systemGreen;
  static const Color warning = CupertinoColors.systemOrange;
  static const Color error = CupertinoColors.destructiveRed;

  // Latency colors
  static const Color latencyFast = CupertinoColors.systemGreen;
  static const Color latencyMedium = CupertinoColors.systemYellow;
  static const Color latencySlow = CupertinoColors.systemOrange;
  static const Color latencyTimeout = CupertinoColors.destructiveRed;
  static const Color latencyNotTested = CupertinoColors.systemGrey;

  // Background colors
  static Color background(BuildContext context) =>
      CupertinoColors.systemGroupedBackground.resolveFrom(context);

  static Color secondaryBackground(BuildContext context) =>
      CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);

  static Color tertiaryBackground(BuildContext context) =>
      CupertinoColors.tertiarySystemGroupedBackground.resolveFrom(context);

  // Text colors
  static Color label(BuildContext context) =>
      CupertinoColors.label.resolveFrom(context);

  static Color secondaryLabel(BuildContext context) =>
      CupertinoColors.secondaryLabel.resolveFrom(context);

  static Color tertiaryLabel(BuildContext context) =>
      CupertinoColors.tertiaryLabel.resolveFrom(context);

  // Separator color
  static Color separator(BuildContext context) =>
      CupertinoColors.separator.resolveFrom(context);
}

/// App theme configuration
class AppTheme {
  static CupertinoThemeData get systemTheme =>
      const CupertinoThemeData(primaryColor: AppColors.primary);

  static CupertinoThemeData get lightTheme => const CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
  );

  static CupertinoThemeData get darkTheme => const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
  );
}
