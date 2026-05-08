import 'package:flutter/cupertino.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../common/components/app_picker.dart';
import '../../../common/components/frosted_dialog.dart';
import 'app_install_sheet.dart';

/// 显示版本选择对话框
Future<void> showAppVersionPickerDialog({
  required BuildContext context,
  required int serverId,
  required int appId,
  required String appKey,
  required String appName,
  required List<String> versions,
}) async {
  if (versions.isEmpty) return;

  // 如果只有一个版本，直接进入安装页面
  if (versions.length == 1) {
    showAppInstallSheet(
      context: context,
      serverId: serverId,
      appId: appId,
      appKey: appKey,
      appName: appName,
      version: versions.first,
    );
    return;
  }

  String selectedVersion = versions.first;

  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => FrostedDialog(
      title: context.l10n.appStore_selectInstallVersion,
      onCancel: () => Navigator.pop(context, false),
      onConfirm: () => Navigator.pop(context, true),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              return AppInlinePicker<String>(
                options: versions
                    .map((v) => AppPickerOption(label: v, value: v))
                    .toList(),
                value: selectedVersion,
                onChanged: (v) => setState(() => selectedVersion = v),
              );
            },
          ),
        ],
      ),
    ),
  );

  if (confirmed == true && context.mounted) {
    showAppInstallSheet(
      context: context,
      serverId: serverId,
      appId: appId,
      appKey: appKey,
      appName: appName,
      version: selectedVersion,
    );
  }
}
