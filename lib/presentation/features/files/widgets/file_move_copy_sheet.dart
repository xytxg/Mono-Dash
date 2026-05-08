import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/file_browser_picker_sheet.dart';
import '../../../../core/utils/format_utils.dart';
import '../providers/files_provider.dart';

enum FileOperationType { copy, move }

class FileMoveCopySheet extends ConsumerStatefulWidget {
  const FileMoveCopySheet({
    super.key,
    required this.items,
    required this.type,
    required this.targetPath,
    required this.collisions,
  });

  final List<FileItemDto> items;
  final FileOperationType type;
  final String targetPath;
  final List<FileItemDto> collisions;

  static Future<void> start({
    required BuildContext context,
    required ProviderContainer container,
    required List<FileItemDto> items,
    required FileOperationType type,
  }) async {
    final l10n = context.l10n;
    final currentPath =
        container.read(filesControllerProvider).valueOrNull?.currentPath ?? '/';

    await FileBrowserPickerSheet.show(
      context,
      initialPath: currentPath,
      title: type == FileOperationType.copy
          ? l10n.files_copyToTitle
          : l10n.files_moveToTitle,
      confirmText: type == FileOperationType.copy
          ? l10n.files_actionCopy
          : l10n.files_actionMove,
      onConfirm: (pickerContext, result) async {
        final dst = _normalizePath(result.path);
        if (type == FileOperationType.move &&
            dst == _normalizePath(currentPath)) {
          showAppErrorToast(l10n.files_moveCopySamePathError);
          return false;
        }

        final collisions = await _checkCollisions(container, items, dst, l10n);
        if (collisions.isEmpty) {
          return _executeMoveCopy(
            container: container,
            items: items,
            type: type,
            dst: dst,
            l10n: l10n,
          );
        }

        if (!pickerContext.mounted) return false;
        final resolved = await showActionSheet<bool>(
          context: pickerContext,
          providerContainer: container,
          barrierColor: CupertinoColors.black.withValues(alpha: 0.16),
          builder: (context) => FileMoveCopySheet(
            items: items,
            type: type,
            targetPath: dst,
            collisions: collisions,
          ),
        );
        return resolved == true;
      },
    );
  }

  static Future<List<FileItemDto>> _checkCollisions(
    ProviderContainer container,
    List<FileItemDto> items,
    String dst,
    AppLocalizations l10n,
  ) async {
    try {
      final notifier = container.read(filesControllerProvider.notifier);
      if (items.length == 1) {
        final item = items.first;
        final exists = await notifier.checkFileExists(
          _joinPath(dst, item.name),
        );
        return exists ? [item] : const <FileItemDto>[];
      }

      final pathsToCheck = items.map((e) => _joinPath(dst, e.name)).toList();
      return notifier.batchCheckFilesExists(pathsToCheck);
    } catch (e) {
      showAppErrorToast(
        l10n.files_moveCopyCheckConflictFailed,
        description: e.toString(),
      );
      return items;
    }
  }

  static Future<bool> _executeMoveCopy({
    required ProviderContainer container,
    required List<FileItemDto> items,
    required FileOperationType type,
    required String dst,
    String name = '',
    bool cover = false,
    List<String> coverPaths = const [],
    required AppLocalizations l10n,
  }) async {
    try {
      final typeStr = type == FileOperationType.copy ? 'copy' : 'cut';
      await container
          .read(filesControllerProvider.notifier)
          .moveCopyFiles(
            oldPaths: items.map((e) => e.path).toList(),
            newPath: dst,
            type: typeStr,
            name: name,
            cover: cover,
            coverPaths: coverPaths,
          );
      showAppSuccessToast(
        type == FileOperationType.copy
            ? l10n.files_copySuccess
            : l10n.files_moveSuccess,
      );
      return true;
    } catch (e) {
      showAppErrorToast(l10n.files_operationFailed, description: e.toString());
      return false;
    }
  }

  static String _normalizePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty || trimmed == '/') return '/';
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  static String _joinPath(String dir, String name) {
    final normalized = _normalizePath(dir);
    return normalized == '/' ? '/$name' : '$normalized/$name';
  }

  @override
  ConsumerState<FileMoveCopySheet> createState() => _FileMoveCopySheetState();
}

class _FileMoveCopySheetState extends ConsumerState<FileMoveCopySheet> {
  bool _isSubmitting = false;

  ProviderContainer get _container => ProviderScope.containerOf(context);

  Future<void> _handleSingleRename() async {
    final item = widget.items.first;
    final now = DateTime.now();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final timestamp =
        '${now.year}${twoDigits(now.month)}${twoDigits(now.day)}${twoDigits(now.hour)}${twoDigits(now.minute)}${twoDigits(now.second)}';

    final extension = item.extension;
    final nameWithoutExt = item.name.contains('.')
        ? item.name.substring(0, item.name.lastIndexOf('.'))
        : item.name;
    final newName = '$nameWithoutExt-$timestamp$extension';

    await _execute(name: newName);
  }

  Future<void> _handleOverwrite() async {
    final collisionNames = widget.collisions.map((e) => e.name).toSet();
    final sourceItemsToCover = widget.items
        .where((item) => collisionNames.contains(item.name))
        .toList();

    await _execute(
      cover: true,
      coverPaths: sourceItemsToCover.map((e) => e.path).toList(),
    );
  }

  Future<void> _handleBatchSkip() async {
    final collisionNames = widget.collisions.map((e) => e.name).toSet();
    final filteredItems = widget.items
        .where((item) => !collisionNames.contains(item.name))
        .toList();

    if (filteredItems.isEmpty) {
      showAppSuccessToast(context.l10n.files_moveCopySkippedAll);
      if (mounted) Navigator.of(context).pop(false);
      return;
    }

    await _execute(itemsOverride: filteredItems);
  }

  Future<void> _execute({
    String name = '',
    bool cover = false,
    List<String> coverPaths = const [],
    List<FileItemDto>? itemsOverride,
  }) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final ok = await FileMoveCopySheet._executeMoveCopy(
      container: _container,
      items: itemsOverride ?? widget.items,
      type: widget.type,
      dst: widget.targetPath,
      name: name,
      cover: cover,
      coverPaths: coverPaths,
      l10n: context.l10n,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      isFloating: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  TablerIcons.alert_triangle,
                  color: CupertinoColors.systemOrange,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.files_moveCopyConflictTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.label(context),
                  ),
                ),
              ],
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(
                context.l10n.common_cancel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              context.l10n.files_moveCopyConflictDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCollisionList(),
          const SizedBox(height: 24),
          if (widget.items.length == 1)
            _buildSingleActions()
          else
            _buildBatchActions(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildCollisionList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.05),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 140),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: widget.collisions.length,
          separatorBuilder: (context, index) => Container(
            height: 0.5,
            color: AppColors.separator(context).withValues(alpha: 0.1),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          itemBuilder: (context, index) {
            final item = widget.collisions[index];
            return Row(
              children: [
                Icon(
                  item.isDir ? TablerIcons.folder : TablerIcons.file,
                  size: 16,
                  color: AppColors.secondaryLabel(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.label(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  TablerIcons.clock_edit,
                  size: 13,
                  color: AppColors.secondaryLabel(
                    context,
                  ).withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  formatFileModTime(item.modTime),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSingleActions() {
    return Row(
      children: [
        Expanded(
          child: _secondaryButton(
            context.l10n.files_actionRename,
            _handleSingleRename,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _destructiveButton(
            context.l10n.files_moveCopyOverwrite,
            _handleOverwrite,
          ),
        ),
      ],
    );
  }

  Widget _buildBatchActions() {
    return Row(
      children: [
        Expanded(
          child: _secondaryButton(
            context.l10n.files_moveCopySkipAll,
            _handleBatchSkip,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _destructiveButton(
            context.l10n.files_moveCopyOverwriteAll,
            _handleOverwrite,
          ),
        ),
      ],
    );
  }

  Widget _cancelButton() {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: AppColors.secondaryBackground(context),
      borderRadius: BorderRadius.circular(12),
      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
      child: Text(
        context.l10n.common_cancel,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.label(context),
        ),
      ),
    );
  }

  Widget _secondaryButton(String text, Future<void> Function() onPressed) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: AppColors.secondaryBackground(context),
      borderRadius: BorderRadius.circular(12),
      onPressed: _isSubmitting ? null : onPressed,
      child: _isSubmitting
          ? const CupertinoActivityIndicator(radius: 8)
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.activeBlue,
              ),
            ),
    );
  }

  Widget _destructiveButton(String text, Future<void> Function() onPressed) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: CupertinoColors.destructiveRed,
      borderRadius: BorderRadius.circular(12),
      onPressed: _isSubmitting ? null : onPressed,
      child: _isSubmitting
          ? const CupertinoActivityIndicator(
              radius: 8,
              color: CupertinoColors.white,
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.white,
              ),
            ),
    );
  }
}
