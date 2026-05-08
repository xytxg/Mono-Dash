import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/container/compose_template_dto.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_code_editor.dart';
import '../../../common/components/status_pill.dart';
import '../providers/compose_template_provider.dart';
import 'compose_template_create_sheet.dart';

/// 显示编排模板操作菜单
void showComposeTemplateActionSheet(
  BuildContext context,
  ComposeTemplateDto template,
) {
  showActionSheet(
    context: context,
    builder: (context) => _ComposeTemplateActionSheet(template: template),
  );
}

class _ComposeTemplateActionSheet extends StatelessWidget {
  const _ComposeTemplateActionSheet({required this.template});

  final ComposeTemplateDto template;

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: CupertinoColors.systemIndigo
                .resolveFrom(context)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              TablerIcons.template,
              size: 32,
              color: CupertinoColors.systemIndigo.resolveFrom(context),
            ),
          ),
        ),
        title: template.name,
        subtitle: template.description.isNotEmpty ? template.description : '',
        trailing: StatusPill(
          label: context.l10n.containers_template,
          active: true,
          activeColor: CupertinoColors.systemIndigo.resolveFrom(context),
        ),
      ),
      child: _ActionList(template: template),
    );
  }
}

class _ActionList extends ConsumerWidget {
  const _ActionList({required this.template});

  final ComposeTemplateDto template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppSectionHeader(
          title: context.l10n.containers_templateOperations,
          icon: TablerIcons.settings,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.edit,
              iconColor: CupertinoColors.systemOrange,
              title: context.l10n.common_edit,
              subtitle: Text(context.l10n.containers_editTemplateSubtitle),
              onTap: () {
                Navigator.pop(context);
                showComposeTemplateCreateSheet(context, template: template);
              },
            ),
            AppActionRow(
              icon: TablerIcons.eye,
              iconColor: CupertinoColors.activeBlue,
              title: context.l10n.containers_viewContent,
              subtitle: Text(context.l10n.containers_viewYamlSubtitle),
              onTap: () {
                Navigator.pop(context);
                _showContent(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.containers_dangerZone,
          icon: TablerIcons.alert_triangle,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.trash,
              iconColor: CupertinoColors.systemRed,
              title: context.l10n.common_delete,
              subtitle: Text(context.l10n.containers_deleteTemplateSubtitle),
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(composeTemplateControllerProvider.notifier)
                    .deleteTemplates(context, [template.id]);
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showContent(BuildContext context) {
    showAppCodeEditorSheet(
      context,
      title: template.name,
      subtitle: 'YAML',
      initialContent: template.content,
      language: 'yaml',
      readOnly: true,
    );
  }
}
