import 'package:flutter/cupertino.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../common/components/action_sheet_launcher.dart';
import 'runtime_base_sheet.dart';

/// 打开 Python 运行环境创建/编辑 Sheet。
Future<void> showRuntimePythonSheet(
  BuildContext context, {
  RuntimeDetailDto? editItem,
  required Future<void> Function(RuntimeCreateReq req) onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) =>
        _RuntimePythonSheet(editItem: editItem, onSubmit: onSubmit),
  );
}

class _RuntimePythonSheet extends StatelessWidget {
  const _RuntimePythonSheet({this.editItem, required this.onSubmit});

  final RuntimeDetailDto? editItem;
  final Future<void> Function(RuntimeCreateReq req) onSubmit;

  @override
  Widget build(BuildContext context) {
    return RuntimeBaseSheet(
      type: 'python',
      title: editItem != null
          ? context.l10n.runtime_editTitle('Python')
          : context.l10n.runtime_createTitle('Python'),
      themeColor: CupertinoColors.systemIndigo,
      editItem: editItem,
      onSubmit: onSubmit,
    );
  }
}
