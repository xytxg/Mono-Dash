import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/task_log_sheet.dart';
import '../providers/image_list_provider.dart';

enum _PruneScope { untag, unused }

void showImagePruneSheet(BuildContext context) {
  showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => const _ImagePruneSheet(),
  );
}

class _ImagePruneSheet extends ConsumerStatefulWidget {
  const _ImagePruneSheet();

  @override
  ConsumerState<_ImagePruneSheet> createState() => _ImagePruneSheetState();
}

class _ImagePruneSheetState extends ConsumerState<_ImagePruneSheet> {
  _PruneScope _scope = _PruneScope.untag;
  List<DockerImageInfo> _allImages = [];
  bool _loading = true;
  Object? _error;
  final Set<String> _selectedIds = {};
  bool _checkAll = false;

  @override
  void initState() {
    super.initState();
    _fetchAllImages();
  }

  Future<void> _fetchAllImages() async {
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      final images = await repo.getAllImages();
      if (!mounted) return;
      setState(() {
        _allImages = images;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  List<DockerImageInfo> get _scopeImages {
    switch (_scope) {
      case _PruneScope.untag:
        return _allImages.where((img) {
          final hasNoTags = img.tags.isEmpty;
          final onlyNoneTag =
              img.tags.length == 1 &&
              (img.tags.first.isEmpty || img.tags.first == '<none>');
          return (hasNoTags || onlyNoneTag) && !img.isUsed;
        }).toList();
      case _PruneScope.unused:
        return _allImages.where((img) => !img.isUsed).toList();
    }
  }

  void _onScopeChanged(_PruneScope? scope) {
    if (scope == null || scope == _scope) return;
    setState(() {
      _scope = scope;
      _selectedIds.clear();
      _checkAll = false;
    });
  }

  void _toggleCheckAll(bool? value) {
    final checked = value ?? false;
    setState(() {
      _checkAll = checked;
      _selectedIds.clear();
      if (checked) {
        for (final img in _scopeImages) {
          _selectedIds.add(img.id);
        }
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _checkAll = _selectedIds.length == _scopeImages.length;
    });
  }

  void _submit() {
    final scopeImages = _scopeImages;
    if (scopeImages.isEmpty) {
      showAppWarningToast(context.l10n.containers_noImagesToPrune);
      return;
    }

    if (_checkAll) {
      _submitPrune();
    } else {
      if (_selectedIds.isEmpty) {
        showAppWarningToast(context.l10n.containers_selectAtLeastOneImage);
        return;
      }
      _submitRemove();
    }
  }

  Future<void> _submitPrune() async {
    final taskID = const Uuid().v4();
    final withTagAll = _scope == _PruneScope.unused;
    final pruneImagesText = context.l10n.containers_pruneImages;
    final pruneFailedText = context.l10n.containers_pruneImagesFailed;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.pruneContainers(
        taskID: taskID,
        pruneType: 'image',
        withTagAll: withTagAll,
      );

      if (!mounted) return;
      final controller = ref.read(imageListControllerProvider.notifier);
      if (!context.mounted) return;
      Navigator.pop(context);
      showTaskLogSheet(
        context,
        title: pruneImagesText,
        taskID: taskID,
        reader: repo.readTaskLog,
        onFinished: controller.refresh,
      );
    } catch (e) {
      showAppErrorToast(pruneFailedText, description: e.toString());
    }
  }

  Future<void> _submitRemove() async {
    final taskID = const Uuid().v4();
    final names = _selectedIds.toList();
    final pruneImagesText = context.l10n.containers_pruneImages;
    final deleteFailedText = context.l10n.containers_deleteFailed;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.removeImage(BatchDeleteReq(taskID: taskID, names: names));

      if (!mounted) return;
      final controller = ref.read(imageListControllerProvider.notifier);
      if (!context.mounted) return;
      Navigator.pop(context);
      showTaskLogSheet(
        context,
        title: pruneImagesText,
        taskID: taskID,
        reader: repo.readTaskLog,
        onFinished: controller.refresh,
      );
    } catch (e) {
      showAppErrorToast(deleteFailedText, description: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      maxHeightFactor: 0.85,
      showHandle: false,
      panelHeader: _buildPanelHeader(),
      child: _buildBody(),
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
              context.l10n.containers_pruneImages,
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
            onPressed: _loading || (!_checkAll && _selectedIds.isEmpty)
                ? null
                : _submit,
            child: Text(
              context.l10n.containers_prune,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _loading || (!_checkAll && _selectedIds.isEmpty)
                    ? CupertinoColors.inactiveGray
                    : CupertinoColors.destructiveRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final scopeImages = _scopeImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scope segmented control
        _buildScopeSelector(),
        const SizedBox(height: 12),

        // Summary + check all
        _buildHeaderRow(scopeImages),
        const SizedBox(height: 8),

        // Image list
        if (scopeImages.isEmpty)
          _buildEmptyState()
        else
          ...scopeImages.map(_buildImageItem),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildScopeSelector() {
    return CupertinoSlidingSegmentedControl<_PruneScope>(
      groupValue: _scope,
      children: {
        _PruneScope.untag: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            context.l10n.containers_danglingImages,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        _PruneScope.unused: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            context.l10n.containers_unusedImages,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      },
      onValueChanged: _onScopeChanged,
    );
  }

  Widget _buildHeaderRow(List<DockerImageInfo> scopeImages) {
    return Row(
      children: [
        Icon(
          TablerIcons.photo,
          size: 15,
          color: AppColors.secondaryLabel(context),
        ),
        const SizedBox(width: 6),
        Text(
          context.l10n.containers_prunableImageCount(scopeImages.length),
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryLabel(context),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: scopeImages.isEmpty ? null : () => _toggleCheckAll(!_checkAll),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _checkAll ? TablerIcons.checkbox : TablerIcons.square,
                size: 20,
                color: _checkAll
                    ? CupertinoColors.activeBlue.resolveFrom(context)
                    : AppColors.tertiaryLabel(context),
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.containers_selectAll,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(DockerImageInfo image) {
    final selected = _selectedIds.contains(image.id);
    final displayName = _displayName(image);

    return GestureDetector(
      onTap: () => _toggleItem(image.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.separator(context).withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? TablerIcons.checkbox : TablerIcons.square,
              size: 20,
              color: selected
                  ? CupertinoColors.activeBlue.resolveFrom(context)
                  : AppColors.tertiaryLabel(context),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.label(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _displayId(image.id),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: AppColors.tertiaryLabel(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatBytes(image.size),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            TablerIcons.photo_off,
            size: 40,
            color: AppColors.tertiaryLabel(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.containers_noImagesToPrune,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            TablerIcons.alert_circle,
            size: 40,
            color: CupertinoColors.systemRed.resolveFrom(context),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.containers_loadImageListFailed,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(DockerImageInfo image) {
    if (image.tags.isNotEmpty) {
      final tag = image.tags.first;
      if (tag.isNotEmpty && tag != '<none>') return tag;
    }
    return '<none>';
  }

  String _displayId(String id) {
    // Show short form: sha256:abcd... -> sha256:abcd
    if (id.length > 20) {
      return id.substring(0, 19);
    }
    return id;
  }
}
