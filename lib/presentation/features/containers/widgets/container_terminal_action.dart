import 'package:flutter/cupertino.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/container/container_search_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/terminal/app_terminal.dart';
import '../../../common/components/terminal/terminal_exec_dialog.dart';

Future<void> openTerminalById(BuildContext context, String containerId) async {
  if (containerId.isEmpty) {
    showAppErrorToast(context.l10n.containers_getContainerIdFailed);
    return;
  }

  final result = await showTerminalExecDialog(
    context,
    containerId: containerId,
  );
  if (result == null || !context.mounted) return;

  Navigator.of(context).pop();

  showAppTerminal(
    context,
    containerId: containerId,
    user: result.user,
    command: result.command,
  );
}

Future<void> openContainerTerminal(
  BuildContext context,
  ContainerItemDto containerItem,
) async {
  return openTerminalById(context, containerItem.containerID);
}
