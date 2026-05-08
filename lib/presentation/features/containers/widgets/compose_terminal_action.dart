import 'package:flutter/cupertino.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../common/app_toast.dart';
import 'container_terminal_action.dart';
import '../../../../data/dto/container/container_compose_dto.dart';

Future<void> openComposeTerminal(
  BuildContext context,
  ContainerComposeDto item,
) async {
  final containers = item.containers ?? [];
  if (containers.isEmpty) {
    showAppErrorToast(
      context.l10n.containers_openTerminalFailed,
      description: context.l10n.containers_composeNoAvailableContainer,
    );
    return;
  }

  if (containers.length == 1) {
    return openTerminalById(context, containers.first.containerID);
  }

  final selectedContainerId = await showCupertinoModalPopup<String>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text(context.l10n.containers_selectContainer),
      message: Text(context.l10n.containers_selectContainerMessage),
      actions: containers.map((c) {
        return CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, c.containerID),
          child: Text(c.name, style: const TextStyle(fontSize: 16)),
        );
      }).toList(),
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.common_cancel),
      ),
    ),
  );

  if (selectedContainerId != null && context.mounted) {
    return openTerminalById(context, selectedContainerId);
  }
}
