import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:re_editor/re_editor.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_code_editor.dart';
import '../../../common/components/file_browser_picker_sheet.dart';
import '../../../common/components/thin_divider.dart';
import '../providers/image_list_provider.dart';

void showImageBuildSheet(BuildContext context) {
  showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => const _ImageBuildSheet(),
  );
}

class _ImageBuildSheet extends ConsumerStatefulWidget {
  const _ImageBuildSheet();

  @override
  ConsumerState<_ImageBuildSheet> createState() => _ImageBuildSheetState();
}

class _ImageBuildSheetState extends ConsumerState<_ImageBuildSheet> {
  final _nameController = TextEditingController();
  final _pathController = TextEditingController();
  late final CodeLineEditingController _dockerfileController;
  final _tagsController = TextEditingController();
  final _argsController = TextEditingController();

  String _buildSource = 'edit'; // 'edit' or 'path'

  @override
  void initState() {
    super.initState();
    _dockerfileController = CodeLineEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _dockerfileController.dispose();
    _tagsController.dispose();
    _argsController.dispose();
    super.dispose();
  }

  Future<void> _pickDockerfile() async {
    final result = await FileBrowserPickerSheet.show(
      context,
      title: context.l10n.containers_selectDockerfile,
      selectionMode: FilePickerSelectionMode.files,
    );
    if (result != null) {
      setState(() {
        _pathController.text = result.path;
      });
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppErrorToast(context.l10n.containers_imageNameRequired);
      return;
    }

    String dockerfileContent = '';
    if (_buildSource == 'edit') {
      dockerfileContent = _dockerfileController.text;
      if (dockerfileContent.trim().isEmpty) {
        showAppErrorToast(context.l10n.containers_dockerfileContentRequired);
        return;
      }
    } else {
      dockerfileContent = _pathController.text.trim();
      if (dockerfileContent.isEmpty) {
        showAppErrorToast(context.l10n.containers_dockerfilePathRequired);
        return;
      }
    }

    final tags = _tagsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final args = _argsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    ref
        .read(imageListControllerProvider.notifier)
        .buildImage(
          context: context,
          from: _buildSource,
          name: name,
          dockerfile: dockerfileContent,
          tags: tags,
          args: args,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      maxHeightFactor: 0.9,
      showHandle: false,
      panelHeader: _buildPanelHeader(),
      child: _buildForm(),
    );
  }

  Widget _buildPanelHeader() {
    return Padding(
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
              context.l10n.containers_buildImage,
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
              context.l10n.containers_build,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(
          context.l10n.containers_basicInfo,
          TablerIcons.info_circle,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.separator(context).withValues(alpha: 0.1),
            ),
          ),
          child: CupertinoTextField(
            controller: _nameController,
            placeholder: context.l10n.containers_imageNamePlaceholder,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: null,
            autocorrect: false,
            enableSuggestions: false,
            style: TextStyle(color: AppColors.label(context), fontSize: 15),
          ),
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('Dockerfile', TablerIcons.file_code),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<String>(
            groupValue: _buildSource,
            children: {
              'edit': Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  context.l10n.containers_manualInput,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              'path': Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  context.l10n.containers_serverPath,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            },
            onValueChanged: (v) {
              if (v != null) setState(() => _buildSource = v);
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_buildSource == 'edit')
          Container(
            height: 360,
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
                controller: _dockerfileController,
                language: 'dockerfile',
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.separator(context).withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _pathController,
                    placeholder:
                        context.l10n.containers_dockerfilePathPlaceholder,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: null,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: TextStyle(
                      color: AppColors.label(context),
                      fontSize: 14,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.square(32),
                  onPressed: _pickDockerfile,
                  child: Icon(
                    TablerIcons.folder,
                    size: 20,
                    color: CupertinoColors.activeBlue.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),
        _buildSectionTitle(
          context.l10n.containers_additionalOptionsOptional,
          TablerIcons.settings,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                controller: _tagsController,
                placeholder: context.l10n.containers_tagsMultilinePlaceholder,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: null,
                maxLines: 3,
                autocorrect: false,
                enableSuggestions: false,
                style: TextStyle(color: AppColors.label(context), fontSize: 14),
              ),
              const ThinDivider(),
              CupertinoTextField(
                controller: _argsController,
                placeholder: context.l10n.containers_argsMultilinePlaceholder,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: null,
                maxLines: 3,
                autocorrect: false,
                enableSuggestions: false,
                style: TextStyle(color: AppColors.label(context), fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
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
