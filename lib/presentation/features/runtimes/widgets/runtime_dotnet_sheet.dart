import 'package:flutter/cupertino.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../common/components/action_sheet_launcher.dart';
import 'runtime_base_sheet.dart';

/// 打开 .NET 运行环境创建/编辑 Sheet。
Future<void> showRuntimeDotnetSheet(
  BuildContext context, {
  RuntimeDetailDto? editItem,
  required Future<void> Function(RuntimeCreateReq req) onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) =>
        _RuntimeDotnetSheet(editItem: editItem, onSubmit: onSubmit),
  );
}

class _RuntimeDotnetSheet extends StatelessWidget {
  const _RuntimeDotnetSheet({this.editItem, required this.onSubmit});

  final RuntimeDetailDto? editItem;
  final Future<void> Function(RuntimeCreateReq req) onSubmit;

  @override
  Widget build(BuildContext context) {
    return RuntimeBaseSheet(
      type: 'dotnet',
      title: editItem != null
          ? context.l10n.runtime_editTitle('.NET')
          : context.l10n.runtime_createTitle('.NET'),
      themeColor: CupertinoColors.systemPurple,
      editItem: editItem,
      onSubmit: onSubmit,
    );
  }
}
