import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/l10n_x.dart';
import '../../../core/theme/app_theme.dart';
import '../../features/files/utils/file_icon_utils.dart';
import '../../../data/dto/file/file_item_dto.dart';
import '../../../data/repositories_impl/file_repository_impl.dart';
import 'action_sheet_launcher.dart';
import 'action_sheet_scaffold.dart';
import 'skeleton_item.dart';

enum FilePickerSelectionMode { files, directories, filesAndDirectories }

typedef FilePickerConfirmCallback =
    Future<bool> Function(BuildContext context, FilePickerResult result);

class FilePickerResult {
  const FilePickerResult({
    required this.path,
    required this.isDirectory,
    this.item,
  });

  final String path;
  final bool isDirectory;
  final FileItemDto? item;
}

class FileBrowserPickerSheet extends ConsumerStatefulWidget {
  const FileBrowserPickerSheet({
    super.key,
    this.initialPath = '/',
    this.title,
    this.confirmText,
    this.selectionMode = FilePickerSelectionMode.directories,
    this.showHidden = true,
    this.allowMultiple = false,
    this.initialSelectedPaths = const <String>{},
    this.onConfirm,
  });

  final String initialPath;
  final String? title;
  final String? confirmText;
  final FilePickerSelectionMode selectionMode;
  final bool showHidden;
  final bool allowMultiple;
  final Set<String> initialSelectedPaths;
  final FilePickerConfirmCallback? onConfirm;

  static Future<FilePickerResult?> show(
    BuildContext context, {
    String initialPath = '/',
    String? title,
    String? confirmText,
    FilePickerSelectionMode selectionMode = FilePickerSelectionMode.directories,
    bool showHidden = true,
    FilePickerConfirmCallback? onConfirm,
  }) {
    return showActionSheet<FilePickerResult>(
      context: context,
      expand: true,
      builder: (context) => FileBrowserPickerSheet(
        initialPath: initialPath,
        title: title,
        confirmText: confirmText,
        selectionMode: selectionMode,
        showHidden: showHidden,
        onConfirm: onConfirm,
      ),
    );
  }

  static Future<List<FilePickerResult>?> showMultiple(
    BuildContext context, {
    String initialPath = '/',
    String? title,
    String? confirmText,
    FilePickerSelectionMode selectionMode =
        FilePickerSelectionMode.filesAndDirectories,
    bool showHidden = true,
    Set<String> initialSelectedPaths = const <String>{},
  }) {
    return showActionSheet<List<FilePickerResult>>(
      context: context,
      expand: true,
      builder: (context) => FileBrowserPickerSheet(
        initialPath: initialPath,
        title: title,
        confirmText: confirmText,
        selectionMode: selectionMode,
        showHidden: showHidden,
        allowMultiple: true,
        initialSelectedPaths: initialSelectedPaths,
      ),
    );
  }

  @override
  ConsumerState<FileBrowserPickerSheet> createState() =>
      _FileBrowserPickerSheetState();
}

class _FileBrowserPickerSheetState
    extends ConsumerState<FileBrowserPickerSheet> {
  late String _currentPath;
  Future<List<FileItemDto>>? _itemsFuture;
  final Map<String, FilePickerResult> _selected = {};

  bool get _canSelectCurrentDirectory =>
      widget.selectionMode != FilePickerSelectionMode.files;

  @override
  void initState() {
    super.initState();
    _currentPath = _normalizePath(widget.initialPath);
    for (final path in widget.initialSelectedPaths) {
      final normalized = _normalizePath(path);
      _selected[normalized] = FilePickerResult(
        path: normalized,
        isDirectory: false,
      );
    }
    _itemsFuture = _loadItems(_currentPath);
  }

  Future<List<FileItemDto>> _loadItems(String path) async {
    final repo = await ref.read(fileRepositoryProvider.future);
    final result = await repo.searchFiles(
      path: path,
      showHidden: widget.showHidden,
      sortBy: 'name',
      sortOrder: 'ascending',
      pageSize: 200,
    );
    final items = [...?result.items];
    items.sort((a, b) {
      if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return items;
  }

  void _openPath(String path) {
    final nextPath = _normalizePath(path);
    final future = _loadItems(nextPath);
    setState(() {
      _currentPath = nextPath;
      _itemsFuture = future;
    });
  }

  void _goUp() {
    if (_currentPath == '/') return;
    _openPath(_parentPath(_currentPath));
  }

  void _refresh() {
    final future = _loadItems(_currentPath);
    setState(() {
      _itemsFuture = future;
    });
  }

  Future<void> _selectCurrentDirectory() async {
    final result = FilePickerResult(path: _currentPath, isDirectory: true);
    final onConfirm = widget.onConfirm;
    if (onConfirm != null) {
      final shouldClose = await onConfirm(context, result);
      if (!mounted || !shouldClose) return;
    }
    if (mounted) Navigator.of(context).pop(result);
  }

  void _selectItem(FileItemDto item) {
    if (!_canSelectItem(item)) return;
    Navigator.of(context).pop(
      FilePickerResult(path: item.path, isDirectory: item.isDir, item: item),
    );
  }

  void _toggleItem(FileItemDto item) {
    if (!_canSelectItem(item)) return;
    setState(() {
      if (_selected.containsKey(item.path)) {
        _selected.remove(item.path);
      } else {
        _selected[item.path] = FilePickerResult(
          path: item.path,
          isDirectory: item.isDir,
          item: item,
        );
      }
    });
  }

  void _submitMultipleSelection() {
    if (_selected.isEmpty) return;
    Navigator.of(context).pop(_selected.values.toList(growable: false));
  }

  bool _canSelectItem(FileItemDto item) {
    return switch (widget.selectionMode) {
      FilePickerSelectionMode.files => !item.isDir,
      FilePickerSelectionMode.directories => item.isDir,
      FilePickerSelectionMode.filesAndDirectories => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      showHandle: false,
      isAdaptive: false,
      maxHeightFactor: 0.88,
      hasHorizontalPadding: true,
      panelHeader: _buildHeader(),
      child: FutureBuilder<List<FileItemDto>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error);
          }
          final items = snapshot.data ?? const <FileItemDto>[];
          if (items.isEmpty) return _buildEmpty();
          return _buildList(items);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title ?? context.l10n.filePicker_selectPath,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.label(context),
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.l10n.common_cancel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
              if (_canSelectCurrentDirectory) ...[
                const SizedBox(width: 16),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: widget.allowMultiple
                      ? (_selected.isEmpty ? null : _submitMultipleSelection)
                      : _selectCurrentDirectory,
                  child: Text(
                    widget.allowMultiple
                        ? (widget.confirmText ??
                              context.l10n.common_selectCount(_selected.length))
                        : (widget.confirmText ?? context.l10n.common_select),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.allowMultiple && _selected.isEmpty
                          ? AppColors.tertiaryLabel(context)
                          : CupertinoColors.activeBlue.resolveFrom(context),
                    ),
                  ),
                ),
              ] else if (widget.allowMultiple) ...[
                const SizedBox(width: 16),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: _selected.isEmpty
                      ? null
                      : _submitMultipleSelection,
                  child: Text(
                    widget.confirmText ??
                        context.l10n.common_selectCount(_selected.length),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selected.isEmpty
                          ? AppColors.tertiaryLabel(context)
                          : CupertinoColors.activeBlue.resolveFrom(context),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _HeaderIconButton(
                icon: TablerIcons.arrow_back_up,
                onPressed: _currentPath == '/' ? null : _goUp,
              ),
              const SizedBox(width: 8),
              Expanded(child: _PathPill(path: _currentPath)),
              const SizedBox(width: 8),
              _HeaderIconButton(icon: TablerIcons.refresh, onPressed: _refresh),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        for (var i = 0; i < 8; i++) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                SkeletonItem(width: 32, height: 32, borderRadius: 8),
                SizedBox(width: 12),
                Expanded(
                  child: SkeletonItem(
                    width: double.infinity,
                    height: 14,
                    borderRadius: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildError(Object? error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 32,
            color: AppColors.secondaryLabel(context),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.filePicker_directoryLoadFailed,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
            ),
          ),
          const SizedBox(height: 14),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            borderRadius: BorderRadius.circular(10),
            color: CupertinoColors.activeBlue.resolveFrom(context),
            onPressed: _refresh,
            child: Text(
              context.l10n.common_retry,
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.folder_badge_minus,
            size: 34,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.filePicker_directoryEmpty,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<FileItemDto> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _FilePickerRow(
              item: items[i],
              canSelect: _canSelectItem(items[i]),
              allowMultiple: widget.allowMultiple,
              isSelected: _selected.containsKey(items[i].path),
              onOpen: items[i].isDir ? () => _openPath(items[i].path) : null,
              onSelect: () => _selectItem(items[i]),
              onToggleSelection: () => _toggleItem(items[i]),
            ),
            if (i != items.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 58),
                child: Container(
                  height: 0.5,
                  color: AppColors.separator(context).withValues(alpha: 0.16),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _normalizePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return '/';
    if (trimmed == '/') return '/';
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  String _parentPath(String path) {
    final normalized = _normalizePath(path);
    if (normalized == '/') return '/';
    final index = normalized.lastIndexOf('/');
    if (index <= 0) return '/';
    return normalized.substring(0, index);
  }
}

class _PathPill extends StatelessWidget {
  const _PathPill({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Text(
        path,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryLabel(context),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(34, 34),
      borderRadius: BorderRadius.circular(10),
      color: AppColors.secondaryBackground(context).withValues(alpha: 0.55),
      disabledColor: AppColors.secondaryBackground(
        context,
      ).withValues(alpha: 0.25),
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 17,
        color: onPressed == null
            ? AppColors.tertiaryLabel(context)
            : AppColors.secondaryLabel(context),
      ),
    );
  }
}

class _FilePickerRow extends StatelessWidget {
  const _FilePickerRow({
    required this.item,
    required this.canSelect,
    required this.allowMultiple,
    required this.isSelected,
    required this.onSelect,
    required this.onToggleSelection,
    this.onOpen,
  });

  final FileItemDto item;
  final bool canSelect;
  final bool allowMultiple;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onToggleSelection;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final subtitle = item.isDir
        ? context.l10n.filePicker_folder
        : (item.extension.isEmpty
              ? context.l10n.filePicker_file
              : item.extension);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: allowMultiple
          ? (canSelect ? onToggleSelection : onOpen)
          : (item.isDir ? onOpen : (canSelect ? onSelect : null)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (allowMultiple) ...[
              _SelectionCircle(selected: isSelected, enabled: canSelect),
              const SizedBox(width: 10),
            ],
            FileIconUtils.buildIcon(context, item, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ),
            ),
            if (item.isDir && onOpen != null) ...[
              if (allowMultiple) const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                borderRadius: BorderRadius.circular(10),
                onPressed: onOpen,
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 15,
                  color: AppColors.tertiaryLabel(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final activeColor = CupertinoColors.activeBlue.resolveFrom(context);
    final borderColor = enabled
        ? AppColors.secondaryLabel(context).withValues(alpha: 0.42)
        : AppColors.tertiaryLabel(context).withValues(alpha: 0.22);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? activeColor : CupertinoColors.transparent,
        border: Border.all(
          color: selected ? activeColor : borderColor,
          width: selected ? 0 : 1.2,
        ),
      ),
      child: selected
          ? const Icon(
              TablerIcons.check,
              size: 14,
              color: CupertinoColors.white,
            )
          : null,
    );
  }
}
