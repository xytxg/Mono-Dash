import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../common/components/sub_menu_page.dart';
import 'login_log_page.dart';
import 'operation_log_page.dart';
import 'ssh_log_page.dart';
import 'system_log_page.dart';
import 'task_log_page.dart';

/// 打开日志审计入口页面。
Future<void> openLogHubPage(BuildContext context, int serverId) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(builder: (_) => LogHubPage(serverId: serverId)),
  );
}

class LogHubPage extends StatelessWidget {
  const LogHubPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SubMenuPage(
      title: l10n.log_hubTitle,
      sections: [
        SubMenuSection(
          title: l10n.log_panelLogs,
          items: [
            SubMenuItem(
              title: l10n.log_operationLog,
              icon: TablerIcons.clipboard_list,
              onTap: () => openOperationLogPage(context, serverId),
            ),
            SubMenuItem(
              title: l10n.log_loginLog,
              icon: TablerIcons.eye,
              onTap: () => openLoginLogPage(context, serverId),
            ),
            SubMenuItem(
              title: l10n.log_systemLog,
              icon: TablerIcons.device_desktop,
              onTap: () => openSystemLogPage(context, serverId),
            ),
            SubMenuItem(
              title: l10n.log_taskLog,
              icon: TablerIcons.list_check,
              onTap: () => openTaskLogPage(context, serverId),
            ),
          ],
        ),
        SubMenuSection(
          title: l10n.log_loginLog,
          items: [
            SubMenuItem(
              title: l10n.log_sshLoginLog,
              icon: TablerIcons.login,
              onTap: () => openSshLogPage(context, serverId),
            ),
          ],
        ),
      ],
    );
  }
}
