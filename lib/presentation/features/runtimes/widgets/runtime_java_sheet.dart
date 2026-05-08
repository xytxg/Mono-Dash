import 'package:flutter/cupertino.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../common/components/action_sheet_launcher.dart';
import 'runtime_base_sheet.dart';

/// 打开 Java 运行环境创建/编辑 Sheet。
Future<void> showRuntimeJavaSheet(
  BuildContext context, {
  RuntimeDetailDto? editItem,
  required Future<void> Function(RuntimeCreateReq req) onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _RuntimeJavaSheet(editItem: editItem, onSubmit: onSubmit),
  );
}

class _RuntimeJavaSheet extends StatelessWidget {
  const _RuntimeJavaSheet({this.editItem, required this.onSubmit});

  final RuntimeDetailDto? editItem;
  final Future<void> Function(RuntimeCreateReq req) onSubmit;

  @override
  Widget build(BuildContext context) {
    return RuntimeBaseSheet(
      type: 'java',
      title: editItem != null
          ? context.l10n.runtime_editTitle('Java')
          : context.l10n.runtime_createTitle('Java'),
      themeColor: CupertinoColors.systemOrange,
      editItem: editItem,
      onSubmit: onSubmit,
    );
  }
}
