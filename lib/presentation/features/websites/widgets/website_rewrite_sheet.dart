import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:re_editor/re_editor.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_code_editor.dart';
import '../../../common/components/app_picker.dart';
import '../providers/website_rewrite_provider.dart';
import 'website_modal_sheet.dart';

part 'rewrite/website_rewrite_sheet_form.part.dart';

void showWebsiteRewriteSheet(
  BuildContext context, {
  required int websiteId,
  required String title,
}) {
  showWebsiteModalSheet<void>(
    context: context,
    child: _WebsiteRewriteSheet(websiteId: websiteId, title: title),
  );
}

class _WebsiteRewriteSheet extends ConsumerStatefulWidget {
  const _WebsiteRewriteSheet({required this.websiteId, required this.title});

  final int websiteId;
  final String title;

  @override
  ConsumerState<_WebsiteRewriteSheet> createState() =>
      _WebsiteRewriteSheetState();
}

class _WebsiteRewriteSheetState extends ConsumerState<_WebsiteRewriteSheet> {
  late final CodeLineEditingController _codeController;
  String _selectedName = 'current';
  bool _initialized = false;
  bool _saving = false;

  final List<String> _builtinTemplates = [
    'default',
    'wordpress',
    'wp2',
    'typecho',
    'typecho2',
    'thinkphp',
    'yii2',
    'laravel5',
    'discuz',
    'discuzx',
    'discuzx2',
    'discuzx3',
    'EduSoho',
    'EmpireCMS',
    'ShopWind',
    'crmeb',
    'dabr',
    'dbshop',
    'dedecms',
    'drupal',
    'ecshop',
    'emlog',
    'maccms',
    'mvc',
    'niushop',
    'phpcms',
    'sablog',
    'seacms',
    'shopex',
    'zblog',
  ];

  @override
  void initState() {
    super.initState();
    _codeController = CodeLineEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _initFromState(WebsiteRewriteState state) {
    if (_initialized) return;
    _codeController.text = state.currentContent;
    _initialized = true;
  }

  Future<void> _handleTemplateChanged(String name) async {
    final errorTitle = context.l10n.websites_fetchTemplateContentFailed;
    setState(() {
      _selectedName = name;
      _saving = true;
    });
    try {
      final content = await ref
          .read(websiteRewriteControllerProvider(widget.websiteId).notifier)
          .fetchTemplateContent(name);
      _codeController.text = content;
    } catch (e) {
      showAppErrorToast(errorTitle, description: '$e');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      await ref
          .read(websiteRewriteControllerProvider(widget.websiteId).notifier)
          .updateRewrite(_selectedName, _codeController.text);
      showAppSuccessToast(l10n.websites_rewriteSavedAndReloaded);
    } on AppNetworkException catch (e) {
      showAppErrorToast(l10n.websites_saveFailed, description: e.message);
    } catch (e) {
      showAppErrorToast(l10n.websites_saveFailed, description: '$e');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _saveAsTemplate() async {
    final l10n = context.l10n;
    final nameController = TextEditingController();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(l10n.websites_saveAsTemplate),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: nameController,
            placeholder: l10n.websites_templateNamePlaceholder,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.common_confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final name = nameController.text.trim().toLowerCase();
      if (name.isEmpty) {
        showAppWarningToast(l10n.websites_templateNameRequired);
        return;
      }
      setState(() => _saving = true);
      try {
        await ref
            .read(websiteRewriteControllerProvider(widget.websiteId).notifier)
            .saveAsTemplate(name, _codeController.text);
        showAppSuccessToast(l10n.websites_templateSavedAs(name));
        setState(() => _selectedName = name);
      } catch (e) {
        showAppErrorToast(
          l10n.websites_saveAsTemplateFailed,
          description: '$e',
        );
      } finally {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _deleteTemplate(String name) async {
    final l10n = context.l10n;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(l10n.websites_deleteTemplate),
        content: Text(l10n.websites_deleteTemplateConfirmName(name)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _saving = true);
      try {
        await ref
            .read(websiteRewriteControllerProvider(widget.websiteId).notifier)
            .deleteTemplate(name);
        showAppSuccessToast(l10n.websites_templateDeleted);
        _handleTemplateChanged('current');
      } catch (e) {
        showAppErrorToast(
          l10n.websites_deleteTemplateFailed,
          description: '$e',
        );
      } finally {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebsiteAsyncModalSheet<WebsiteRewriteState>(
      provider: websiteRewriteControllerProvider(widget.websiteId),
      isAdaptive: true,
      showHandle: false,
      errorTitle: context.l10n.websites_loadRewriteConfigFailed,
      headerBuilder: (context, ref, async) => _Header(title: widget.title),
      dataBuilder: (context, state) {
        _initFromState(state);
        return _RewriteForm(
          websiteId: widget.websiteId,
          codeController: _codeController,
          selectedName: _selectedName,
          customTemplates: state.customTemplates,
          builtinTemplates: _builtinTemplates,
          onTemplateChanged: _handleTemplateChanged,
          onSave: _save,
          onSaveAs: _saveAsTemplate,
          onDelete: () => _deleteTemplate(_selectedName),
          saving: _saving,
        );
      },
      onRetry: (ref) =>
          ref.invalidate(websiteRewriteControllerProvider(widget.websiteId)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.separator(context).withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemPink
                  .resolveFrom(context)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              TablerIcons.wand,
              size: 20,
              color: CupertinoColors.systemPink.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.websites_rewrite,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
