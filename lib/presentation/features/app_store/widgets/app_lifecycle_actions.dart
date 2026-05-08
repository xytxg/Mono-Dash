import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../common/components/frosted_dialog.dart';
import '../providers/app_store_provider.dart';

Future<void> confirmRebuildApp(
  BuildContext context,
  WidgetRef ref,
  AppInstalledDto app,
) => _confirmAndRun(
  context,
  title: context.l10n.appStore_rebuildApp,
  message: context.l10n.appStore_rebuildConfirm(app.displayName),
  icon: TablerIcons.refresh,
  confirmText: context.l10n.appStore_rebuild,
  destructive: true,
  action: () =>
      ref.read(appStoreControllerProvider.notifier).rebuildInstalledApp(app),
);

Future<void> confirmRestartApp(
  BuildContext context,
  WidgetRef ref,
  AppInstalledDto app,
) => _confirmAndRun(
  context,
  title: context.l10n.appStore_restartApp,
  message: context.l10n.appStore_restartConfirm(app.displayName),
  icon: TablerIcons.rotate_clockwise,
  confirmText: context.l10n.appStore_restart,
  action: () =>
      ref.read(appStoreControllerProvider.notifier).restartInstalledApp(app),
);

Future<void> confirmStopApp(
  BuildContext context,
  WidgetRef ref,
  AppInstalledDto app,
) => _confirmAndRun(
  context,
  title: context.l10n.appStore_stopApp,
  message: context.l10n.appStore_stopConfirm(app.displayName),
  icon: TablerIcons.player_stop,
  confirmText: context.l10n.appStore_stop,
  destructive: true,
  action: () =>
      ref.read(appStoreControllerProvider.notifier).stopInstalledApp(app),
);

Future<void> confirmStartApp(
  BuildContext context,
  WidgetRef ref,
  AppInstalledDto app,
) => _confirmAndRun(
  context,
  title: context.l10n.appStore_startApp,
  message: context.l10n.appStore_startConfirm(app.displayName),
  icon: TablerIcons.player_play,
  confirmText: context.l10n.appStore_start,
  action: () =>
      ref.read(appStoreControllerProvider.notifier).startInstalledApp(app),
);

Future<void> _confirmAndRun(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  required IconData icon,
  required Future<void> Function() action,
  bool destructive = false,
}) async {
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (ctx) => FrostedDialog(
      title: title,
      subtitle: message,
      icon: icon,
      confirmText: confirmText,
      onCancel: () => Navigator.of(ctx).pop(false),
      onConfirm: () => Navigator.of(ctx).pop(true),
      child: const SizedBox.shrink(),
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await action();
  if (context.mounted) Navigator.of(context).pop();
}
