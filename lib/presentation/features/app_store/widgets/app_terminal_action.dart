import 'package:flutter/cupertino.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/terminal/app_terminal.dart';
import '../../../common/components/terminal/terminal_exec_dialog.dart';

Future<void> openAppTerminal(BuildContext context, AppInstalledDto app) async {
  if (app.container.isEmpty) {
    showAppErrorToast(context.l10n.appStore_containerIdFailed);
    return;
  }

  final result = await showTerminalExecDialog(
    context,
    containerId: app.container,
  );
  if (result == null || !context.mounted) return;

  Navigator.of(context).pop();
  showAppTerminal(
    context,
    containerId: app.container,
    user: result.user,
    command: result.command,
  );
}
