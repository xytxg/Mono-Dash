import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../utils/file_icon_utils.dart';
import '../../../../core/utils/file_type_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../models/files_view_state.dart';
import '../providers/files_provider.dart';
import '../screens/file_editor_page.dart';
import '../screens/file_image_viewer_page.dart';
import 'file_context_menu.dart';

/// 模仿 iOS "Files" app 的列表项。
class FileListItem extends ConsumerStatefulWidget {
  const FileListItem({
    super.key,
    required this.item,
    this.viewMode = FileViewMode.list,
  });

  final FileItemDto item;
  final FileViewMode viewMode;

  @override
  ConsumerState<FileListItem> createState() => _FileListItemState();
}

class _FileListItemState extends ConsumerState<FileListItem> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;
  bool _wasEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.name);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(FileListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.name != oldWidget.item.name) {
      _controller.text = widget.item.name;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !_isProcessing) {
      final filesState = ref.read(filesControllerProvider).valueOrNull;
      if (filesState?.editingPath == widget.item.path) {
        _handleRename();
      }
    }
  }

  void _handleRename() async {
    if (_isProcessing) return;

    final newName = _controller.text.trim();
    if (newName.isEmpty || newName == widget.item.name) {
      ref.read(filesControllerProvider.notifier).cancelRename();
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await ref
          .read(filesControllerProvider.notifier)
          .renameFile(widget.item, newName);
      if (mounted) {
        ref.read(filesControllerProvider.notifier).cancelRename();
      }
    } catch (_) {
      // 错误已在 controller 中处理
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleTap(BuildContext context, bool isSelectionMode, bool isEditing) {
    if (isEditing) return;
    if (isSelectionMode) {
      ref
          .read(filesControllerProvider.notifier)
          .toggleItemSelection(widget.item.path);
      return;
    }

    if (widget.item.isDir) {
      final scrollController = PrimaryScrollController.of(context);
      final offset = scrollController.hasClients
          ? scrollController.offset
          : null;
      ref
          .read(filesControllerProvider.notifier)
          .navigateTo(widget.item.path, currentOffset: offset);
      return;
    }

    if (FileTypeUtils.isImage(widget.item)) {
      final container = ProviderScope.containerOf(context);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => UncontrolledProviderScope(
            container: container,
            child: FileImageViewerPage(
              path: widget.item.path,
              fileName: widget.item.name,
            ),
          ),
        ),
      );
    } else if (FileTypeUtils.isEditable(widget.item)) {
      final container = ProviderScope.containerOf(context);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => UncontrolledProviderScope(
            container: container,
            child: FileEditorPage(
              path: widget.item.path,
              fileName: widget.item.name,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filesState = ref.watch(filesControllerProvider).valueOrNull;
    final isSelectionMode = filesState?.isSelectionMode ?? false;
    final isSelected =
        filesState?.selectedPaths.contains(widget.item.path) ?? false;
    final isEditing = filesState?.editingPath == widget.item.path;

    if (isEditing && !_wasEditing) {
      _controller.text = widget.item.name;
    }
    _wasEditing = isEditing;

    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
          final text = _controller.text;
          final dotIndex = text.lastIndexOf('.');
          final end = (dotIndex > 0) ? dotIndex : text.length;
          final safeEnd = end.clamp(0, text.length);
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: safeEnd,
          );
        }
      });
    }

    return GestureDetector(
      onTap: () => _handleTap(context, isSelectionMode, isEditing),
      onLongPress: isSelectionMode || isEditing
          ? null
          : () => FileContextMenu.show(
              context,
              widget.item,
              viewMode: widget.viewMode,
            ),
      behavior: HitTestBehavior.opaque,
      child: widget.viewMode == FileViewMode.icon
          ? _buildIconTile(context, isSelectionMode, isSelected, isEditing)
          : _buildListTile(context, isSelectionMode, isSelected, isEditing),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    bool isSelectionMode,
    bool isSelected,
    bool isEditing,
  ) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? CupertinoColors.activeBlue.withValues(alpha: isDark ? 0.15 : 0.08)
            : null,
        border: Border(
          bottom: BorderSide(
            color: AppColors.separator(context).withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isSelectionMode) ...[
            _buildSelectionIndicator(context, isSelected),
            const SizedBox(width: 14),
          ],
          FileIconUtils.buildIcon(
            context,
            widget.item,
            size: 32,
            tintColor: isSelected ? CupertinoColors.activeBlue : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: isEditing
                ? _buildRenameField(context)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameText(context, fontSize: 16, maxLines: 1),
                      const SizedBox(height: 2),
                      _buildListSubtitle(context),
                    ],
                  ),
          ),
          if (!isSelectionMode)
            isEditing
                ? _buildCancelRenameButton(context)
                : Icon(
                    CupertinoIcons.chevron_right,
                    size: 14,
                    color: AppColors.tertiaryLabel(context),
                  ),
        ],
      ),
    );
  }

  Widget _buildIconTile(
    BuildContext context,
    bool isSelectionMode,
    bool isSelected,
    bool isEditing,
  ) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        color: isSelected
            ? CupertinoColors.activeBlue.withValues(alpha: isDark ? 0.16 : 0.08)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 2),
                FileIconUtils.buildIcon(
                  context,
                  widget.item,
                  size: 44,
                  tintColor: isSelected ? CupertinoColors.activeBlue : null,
                ),
                const SizedBox(height: 8),
                isEditing
                    ? _buildRenameField(context, textAlign: TextAlign.center)
                    : _buildNameText(
                        context,
                        fontSize: 13,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                const SizedBox(height: 4),
                Text(
                  _formatIconModTime(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatItemInfo(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.tertiaryLabel(context),
                  ),
                ),
              ],
            ),
          ),
          if (isSelectionMode)
            Positioned(
              top: 0,
              left: 0,
              child: _buildSelectionIndicator(context, isSelected, size: 20),
            ),
          if (isEditing && !isSelectionMode)
            Positioned(
              top: 0,
              right: 0,
              child: _buildCancelRenameButton(context),
            ),
        ],
      ),
    );
  }

  Widget _buildRenameField(
    BuildContext context, {
    TextAlign textAlign = TextAlign.start,
  }) {
    return CupertinoTextField(
      controller: _controller,
      focusNode: _focusNode,
      autocorrect: false,
      enableSuggestions: false,
      textAlign: textAlign,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: const BoxDecoration(),
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.label(context),
      ),
      onSubmitted: (_) => _handleRename(),
    );
  }

  Widget _buildNameText(
    BuildContext context, {
    required double fontSize,
    required int maxLines,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: truncateMiddle(widget.item.name, maxLines >= 2 ? 28 : 32),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
            ),
          ),
          if (widget.item.isSymlink && widget.item.linkPath.isNotEmpty) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: '->',
              style: TextStyle(
                fontSize: fontSize - 2,
                color: AppColors.tertiaryLabel(context),
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: truncateMiddle(widget.item.linkPath, 24),
              style: TextStyle(
                fontSize: fontSize - 3,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryLabel(context).withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }

  Widget _buildCancelRenameButton(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.only(left: 8),
      minimumSize: const Size(24, 24),
      onPressed: () =>
          ref.read(filesControllerProvider.notifier).cancelRename(),
      child: Icon(
        CupertinoIcons.xmark_circle_fill,
        size: 18,
        color: AppColors.tertiaryLabel(context).withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildSelectionIndicator(
    BuildContext context,
    bool isSelected, {
    double size = 22,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? CupertinoColors.activeBlue : null,
        border: Border.all(
          color: isSelected
              ? CupertinoColors.activeBlue
              : AppColors.separator(context).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Icon(
              CupertinoIcons.checkmark,
              size: size * 0.64,
              color: CupertinoColors.white,
            )
          : null,
    );
  }

  Widget _buildListSubtitle(BuildContext context) {
    final dateStr = formatFileModTime(widget.item.modTime);
    return Text(
      '$dateStr  •  ${_formatItemInfo()}',
      style: TextStyle(fontSize: 12, color: AppColors.secondaryLabel(context)),
    );
  }

  String _formatIconModTime() {
    final date = DateTime.tryParse(widget.item.modTime)?.toLocal();
    if (date == null) return '-';

    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    if (isToday) {
      return '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
    }
    return '${date.year}/${twoDigits(date.month)}/${twoDigits(date.day)}';
  }

  String _formatItemInfo() {
    if (widget.item.isDir) {
      return formatPermissions(widget.item.mode, true);
    }
    return formatBytes(widget.item.size);
  }

}
