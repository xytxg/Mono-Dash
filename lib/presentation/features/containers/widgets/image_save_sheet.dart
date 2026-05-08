import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/file_browser_picker_sheet.dart';
import '../../../common/components/task_log_sheet.dart';
import '../providers/image_list_provider.dart';

void showImageSaveSheet(BuildContext context, DockerImageInfo image) {
  showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => _ImageSaveSheet(image: image),
  );
}

class _ImageSaveSheet extends ConsumerStatefulWidget {
  const _ImageSaveSheet({required this.image});

  final DockerImageInfo image;

  @override
  ConsumerState<_ImageSaveSheet> createState() => _ImageSaveSheetState();
}

class _ImageSaveSheetState extends ConsumerState<_ImageSaveSheet> {
  final _pathController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _pathController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String get _firstTag =>
      widget.image.tags.isNotEmpty ? widget.image.tags.first : '';

  Future<void> _pickDirectory() async {
    final result = await FileBrowserPickerSheet.show(
      context,
      title: context.l10n.containers_selectExportDirectory,
      selectionMode: FilePickerSelectionMode.directories,
    );
    if (result != null) {
      setState(() => _pathController.text = result.path);
    }
  }

  void _submit() {
    final tagName = _firstTag;
    if (tagName.isEmpty || tagName == '<none>') {
      showAppErrorToast(context.l10n.containers_imageNoAvailableTag);
      return;
    }

    final path = _pathController.text.trim();
    if (path.isEmpty) {
      showAppErrorToast(context.l10n.containers_selectExportDirectoryRequired);
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppErrorToast(context.l10n.containers_enterFileName);
      return;
    }

    final controller = ref.read(imageListControllerProvider.notifier);
    final taskID = const Uuid().v4();
    final exportImageText = context.l10n.containers_exportImage;
    final exportFailedText = context.l10n.containers_exportFailed;

    () async {
      try {
        final repo = await ref.read(containerRepositoryProvider.future);
        await repo.saveImage(
          ImageSaveReq(
            taskID: taskID,
            tagName: tagName,
            path: path,
            name: name,
          ),
        );

        if (!mounted) return;
        Navigator.pop(context);
        showTaskLogSheet(
          context,
          title: exportImageText,
          taskID: taskID,
          reader: repo.readTaskLog,
          onFinished: controller.refresh,
        );
      } catch (e) {
        showAppErrorToast(exportFailedText, description: e.toString());
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      maxHeightFactor: 0.85,
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
              context.l10n.containers_exportImage,
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
              context.l10n.containers_export,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final firstTag = _firstTag;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context.l10n.containers_localTag, TablerIcons.tag),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            firstTag.isEmpty ? '-' : firstTag,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: AppColors.label(context),
            ),
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionTitle(
          context.l10n.containers_saveDirectory,
          TablerIcons.folder,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _pathController,
                  placeholder: context.l10n.containers_selectServerDirectory,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: null,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.label(context),
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                onPressed: _pickDirectory,
                child: Icon(
                  TablerIcons.folder,
                  size: 20,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionTitle(context.l10n.containers_fileName, TablerIcons.file),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: _nameController,
          placeholder: context.l10n.containers_imageExportFilePlaceholder,
          maxLines: 1,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          style: TextStyle(fontSize: 14, color: AppColors.label(context)),
        ),
        const SizedBox(height: 20),
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
