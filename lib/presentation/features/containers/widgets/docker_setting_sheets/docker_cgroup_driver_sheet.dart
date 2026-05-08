import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../../core/localization/l10n_x.dart';
import '../../../../common/components/action_sheet_launcher.dart';
import '../../../../common/components/action_sheet_scaffold.dart';
import '../../../../common/components/action_sheet_info_card.dart';
import '../../../../common/components/app_action_components.dart';

/// 显示 Cgroup Driver 选择 Sheet。
///
/// 返回选中的 driver 名称；用户取消返回 `null`。
Future<String?> showDockerCgroupDriverSheet(
  BuildContext context, {
  required String current,
}) {
  return showActionSheet<String>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => _CgroupDriverSheet(current: current),
  );
}

class _CgroupDriverSheet extends StatelessWidget {
  const _CgroupDriverSheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      maxHeightFactor: 0.35,
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBlue
                .resolveFrom(context)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              TablerIcons.cpu,
              size: 22,
              color: CupertinoColors.systemBlue.resolveFrom(context),
            ),
          ),
        ),
        title: 'Cgroup Driver',
        subtitle: context.l10n.containers_currentValue(current),
        trailing: const SizedBox.shrink(),
      ),
      child: AppActionGroup(
        children: [
          for (final driver in const ['cgroupfs', 'systemd'])
            AppActionRow(
              icon: driver == 'systemd' ? TablerIcons.cpu : TablerIcons.cpu_2,
              iconColor: driver == current
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey,
              title: driver,
              subtitle: Text(
                driver == 'cgroupfs'
                    ? context.l10n.containers_cgroupFsDriverDesc
                    : context.l10n.containers_cgroupSystemdDriverDesc,
              ),
              onTap: () => Navigator.pop(context, driver),
            ),
        ],
      ),
    );
  }
}
