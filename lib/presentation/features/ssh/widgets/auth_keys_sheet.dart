import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../common/components/app_code_editor.dart';
import '../providers/ssh_info_provider.dart';

/// 打开 authorized_keys 编辑器（全屏代码编辑 sheet）。
Future<void> showAuthKeysSheet(BuildContext context, WidgetRef ref) {
  final notifier = ref.read(sshInfoControllerProvider.notifier);
  return showAppCodeEditorSheet(
    context,
    title: context.l10n.ssh_authorizedKeys,
    language: 'bash',
    onLoad: () => notifier.loadSshFile('authKeys'),
    onSave: (content) => notifier.updateSshFile('authKeys', '', content),
  );
}
