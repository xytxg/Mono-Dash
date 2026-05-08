import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_code_editor.dart';
import '../providers/website_config_provider.dart';

/// Shows the website configuration file editor sheet.
void showWebsiteConfigSheet(
  BuildContext context, {
  required int websiteId,
  required String title,
}) {
  showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    expand: true,
    builder: (context) =>
        _WebsiteConfigSheet(websiteId: websiteId, title: title),
  );
}

class _WebsiteConfigSheet extends ConsumerWidget {
  const _WebsiteConfigSheet({required this.websiteId, required this.title});

  final int websiteId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConfig = ref.watch(websiteConfigControllerProvider(websiteId));

    return asyncConfig.when(
      data: (config) => _ConfigEditor(
        websiteId: websiteId,
        title: title,
        initialContent: config.content,
        path: config.path,
      ),
      loading: () => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(context.l10n.common_cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        child: const Center(child: CupertinoActivityIndicator()),
      ),
      error: (err, _) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(context.l10n.common_cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        child: AppErrorState(
          title: context.l10n.websites_loadConfigFailed,
          error: err,
          onRetry: () =>
              ref.invalidate(websiteConfigControllerProvider(websiteId)),
        ),
      ),
    );
  }
}

class _ConfigEditor extends StatefulWidget {
  const _ConfigEditor({
    required this.websiteId,
    required this.title,
    required this.initialContent,
    required this.path,
  });

  final int websiteId;
  final String title;
  final String initialContent;
  final String path;

  @override
  State<_ConfigEditor> createState() => _ConfigEditorState();
}

class _ConfigEditorState extends State<_ConfigEditor> {
  late final CodeLineEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = CodeLineEditingController.fromText(widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isDirty => _controller.text != widget.initialContent;

  Future<void> _handleSave(WidgetRef ref) async {
    setState(() => _isSaving = true);
    try {
      final success = await ref
          .read(websiteConfigControllerProvider(widget.websiteId).notifier)
          .updateConfig(_controller.text);
      if (success && mounted) {
        showAppSuccessToast(context.l10n.websites_configUpdatedAndReloaded);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_updateFailed,
          description: '$e',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleCancel() async {
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(context.l10n.websites_discardChangesQuestion),
        content: Text(context.l10n.websites_unsavedChangesLeaveConfirm),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.websites_continueEditing),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.websites_discard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background(context),
        middle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.websites_configFile),
            Text(
              widget.path,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : _handleCancel,
          child: Text(context.l10n.common_cancel),
        ),
        trailing: Consumer(
          builder: (context, ref, _) => CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isSaving ? null : () => _handleSave(ref),
            child: _isSaving
                ? const CupertinoActivityIndicator()
                : Text(
                    context.l10n.websites_updateAndReload,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
      child: SafeArea(
        child: AppCodeEditor(controller: _controller, language: 'nginx'),
      ),
    );
  }
}
