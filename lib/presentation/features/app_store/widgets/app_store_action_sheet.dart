import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import 'app_action_list.dart';
import 'app_icon_view.dart';

/// 显示应用商店操作菜单
void showAppStoreActionSheet(
  BuildContext context,
  WidgetRef ref,
  AppInstalledDto app,
) {
  showActionSheet(
    context: context,
    builder: (context) => _AppStoreActionSheet(app: app),
  );
}

class _AppStoreActionSheet extends StatelessWidget {
  const _AppStoreActionSheet({required this.app});

  final AppInstalledDto app;

  @override
  Widget build(BuildContext context) {
    final isRunning = app.status.toLowerCase() == 'running';
    final statusColor = isRunning
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemRed.resolveFrom(context);

    return ActionSheetScaffold(
      infoCard: ActionSheetInfoCard(
        leading: AppIconView(
          iconName: app.name,
          inlineIcon: app.icon,
          size: 56,
          borderRadius: 16,
        ),
        title: app.displayName,
        subtitle: app.version,
        trailing: Icon(
          isRunning
              ? TablerIcons.circle_check_filled
              : TablerIcons.circle_x_filled,
          size: 28,
          color: statusColor,
        ),
      ),
      child: AppActionList(app: app),
    );
  }
}
