import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:re_editor/re_editor.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/container/compose_template_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_code_editor.dart';
import '../providers/compose_template_provider.dart';

/// 显示创建/编辑编排模板 BottomSheet
void showComposeTemplateCreateSheet(
  BuildContext context, {
  ComposeTemplateDto? template,
}) {
  showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => _ComposeTemplateCreateSheet(template: template),
  );
}

class _ComposeTemplateCreateSheet extends ConsumerStatefulWidget {
  const _ComposeTemplateCreateSheet({this.template});

  final ComposeTemplateDto? template;

  @override
  ConsumerState<_ComposeTemplateCreateSheet> createState() =>
      _ComposeTemplateCreateSheetState();
}

class _ComposeTemplateCreateSheetState
    extends ConsumerState<_ComposeTemplateCreateSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final CodeLineEditingController _contentController;

  bool get _isEdit => widget.template != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.template?.description ?? '',
    );
    _contentController = CodeLineEditingController.fromText(
      widget.template?.content ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (!_isEdit && name.isEmpty) {
      showAppErrorToast(context.l10n.containers_nameRequired);
      return;
    }

    final content = _contentController.text;
    if (content.trim().isEmpty) {
      showAppErrorToast(context.l10n.containers_composeContentRequired);
      return;
    }

    final description = _descriptionController.text.trim();
    final successText = _isEdit
        ? context.l10n.containers_templateUpdated
        : context.l10n.containers_templateCreated;
    final failureText = _isEdit
        ? context.l10n.containers_updateFailed
        : context.l10n.containers_createFailed;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);

      if (_isEdit) {
        await repo.updateTemplate(
          id: widget.template!.id,
          description: description,
          content: content,
        );
      } else {
        await repo.createTemplate(
          name: name,
          description: description,
          content: content,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      showAppSuccessToast(successText);
      ref.read(composeTemplateControllerProvider.notifier).refresh();
    } catch (e) {
      showAppErrorToast(failureText, description: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      maxHeightFactor: 0.78,
      showHandle: false,
      contentPadding: EdgeInsets.zero,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
        child: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Text(
                _isEdit
                    ? context.l10n.containers_editTemplate
                    : context.l10n.containers_createTemplate,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: _submit,
              child: Text(
                _isEdit ? context.l10n.common_save : context.l10n.common_create,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context.l10n.containers_basicInfo,
              TablerIcons.info_circle,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(
                  context,
                ).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.separator(context).withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder:
                        context.l10n.containers_templateNameRequiredPlaceholder,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: null,
                    readOnly: _isEdit,
                    style: TextStyle(
                      color: _isEdit
                          ? AppColors.secondaryLabel(context)
                          : AppColors.label(context),
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    color: AppColors.separator(context).withValues(alpha: 0.15),
                  ),
                  CupertinoTextField(
                    controller: _descriptionController,
                    placeholder:
                        context.l10n.containers_templateDescriptionOptional,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: null,
                    style: TextStyle(
                      color: AppColors.label(context),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(
              context.l10n.containers_composeContent,
              TablerIcons.file_code,
            ),
            const SizedBox(height: 12),
            Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.separator(context).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AppCodeEditor(
                  controller: _contentController,
                  language: 'yaml',
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: CupertinoColors.activeBlue.resolveFrom(context),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }
}
