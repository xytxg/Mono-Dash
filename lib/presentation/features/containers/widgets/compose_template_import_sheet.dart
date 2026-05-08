import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_code_editor.dart';
import '../providers/compose_template_provider.dart';

/// 选择 JSON 文件，展示内容供用户确认后导入
Future<void> importComposeTemplates(BuildContext context, WidgetRef ref) async {
  final cannotReadFileText = context.l10n.containers_cannotReadFile;
  final readFileFailedText = context.l10n.containers_readFileFailed;
  final importTemplateText = context.l10n.containers_importTemplate;
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result == null || result.files.isEmpty) return;

  final file = result.files.first;
  final String jsonString;
  try {
    if (kIsWeb) {
      if (file.bytes == null) {
        showAppErrorToast(cannotReadFileText);
        return;
      }
      jsonString = utf8.decode(file.bytes!);
    } else {
      if (file.path == null) {
        showAppErrorToast(cannotReadFileText);
        return;
      }
      jsonString = await File(file.path!).readAsString();
    }
  } catch (e) {
    showAppErrorToast(readFileFailedText, description: e.toString());
    return;
  }

  if (!context.mounted) return;

  showAppCodeEditorSheet(
    context,
    title: importTemplateText,
    subtitle: file.name,
    initialContent: jsonString,
    language: 'json',
    onSave: (content) => _doImport(context, ref, content),
  );
}

Future<bool> _doImport(
  BuildContext context,
  WidgetRef ref,
  String content,
) async {
  final parsed = jsonDecode(content);
  if (parsed is! List) {
    showAppErrorToast(context.l10n.containers_jsonRootArrayRequired);
    return false;
  }

  final templates = <Map<String, dynamic>>[];
  for (final entry in parsed) {
    if (entry is! Map) continue;
    final name = entry['name']?.toString() ?? '';
    final templateContent = entry['content']?.toString() ?? '';
    if (name.isEmpty || templateContent.isEmpty) continue;
    templates.add({
      'name': name,
      'description': entry['description']?.toString() ?? '',
      'content': templateContent,
    });
  }

  if (templates.isEmpty) {
    showAppErrorToast(context.l10n.containers_noValidTemplateData);
    return false;
  }

  final importSuccessText = context.l10n.containers_importTemplatesSuccess(
    templates.length,
  );
  final repo = await ref.read(containerRepositoryProvider.future);
  await repo.batchImportTemplates(templates);

  showAppSuccessToast(importSuccessText);
  ref.read(composeTemplateControllerProvider.notifier).refresh();
  return true;
}
