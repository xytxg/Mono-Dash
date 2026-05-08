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
import '../../../common/components/app_picker.dart';
import '../../../common/components/task_log_sheet.dart';
import '../providers/image_list_provider.dart';

void showImagePushSheet(BuildContext context, DockerImageInfo image) {
  showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => _ImagePushSheet(image: image),
  );
}

class _ImagePushSheet extends ConsumerStatefulWidget {
  const _ImagePushSheet({required this.image});

  final DockerImageInfo image;

  @override
  ConsumerState<_ImagePushSheet> createState() => _ImagePushSheetState();
}

class _ImagePushSheetState extends ConsumerState<_ImagePushSheet> {
  final _nameController = TextEditingController();
  List<ImageRepoDto> _repos = [];
  ImageRepoDto? _selectedRepo;
  bool _loadingRepos = true;

  @override
  void initState() {
    super.initState();
    _loadRepos();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadRepos() async {
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      final repos = await repo.listImageRepos();
      if (!mounted) return;
      setState(() {
        _repos = repos;
        _selectedRepo = repos.isNotEmpty ? repos.first : null;
        _loadingRepos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingRepos = false);
    }
  }

  String get _firstTag =>
      widget.image.tags.isNotEmpty ? widget.image.tags.first : '';

  void _submit() {
    final tagName = _firstTag;
    if (tagName.isEmpty) {
      showAppErrorToast(context.l10n.containers_imageNoAvailableTag);
      return;
    }

    final repoID = _selectedRepo?.id ?? 0;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppErrorToast(context.l10n.containers_pushNameRequired);
      return;
    }

    final controller = ref.read(imageListControllerProvider.notifier);
    final taskID = const Uuid().v4();
    final pushImageText = context.l10n.containers_pushImage;
    final pushFailedText = context.l10n.containers_pushFailed;

    () async {
      try {
        final repo = await ref.read(containerRepositoryProvider.future);
        await repo.pushImage(
          ImagePushReq(
            taskID: taskID,
            repoID: repoID,
            tagName: tagName,
            name: name,
          ),
        );

        if (!mounted) return;
        Navigator.pop(context);
        showTaskLogSheet(
          context,
          title: pushImageText,
          taskID: taskID,
          reader: repo.readTaskLog,
          onFinished: controller.refresh,
        );
      } catch (e) {
        showAppErrorToast(pushFailedText, description: e.toString());
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
              context.l10n.containers_pushImage,
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
            onPressed: _loadingRepos ? null : _submit,
            child: Text(
              context.l10n.containers_push,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _loadingRepos
                    ? CupertinoColors.inactiveGray
                    : CupertinoColors.activeBlue,
              ),
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
          context.l10n.containers_imageRepos,
          TablerIcons.database,
        ),
        const SizedBox(height: 8),
        _loadingRepos
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CupertinoActivityIndicator(),
              )
            : _repos.isEmpty
            ? Text(
                context.l10n.containers_noRepoConfigured,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryLabel(context),
                ),
              )
            : AppInlinePicker<ImageRepoDto>(
                options: _repos
                    .map((r) => AppPickerOption(value: r, label: r.name))
                    .toList(),
                value: _selectedRepo!,
                onChanged: (r) => setState(() => _selectedRepo = r),
                backgroundColor: AppColors.tertiaryBackground(
                  context,
                ).withValues(alpha: 0.5),
              ),
        const SizedBox(height: 20),

        _buildSectionTitle(context.l10n.containers_pushName, TablerIcons.edit),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: _nameController,
          placeholder: context.l10n.containers_pushNamePlaceholder,
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
