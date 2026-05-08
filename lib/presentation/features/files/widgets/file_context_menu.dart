import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../utils/file_icon_utils.dart';
import '../../../../core/utils/file_type_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../common/app_toast.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../models/files_view_state.dart';
import '../providers/download_manager_provider.dart';
import '../providers/files_provider.dart';
import '../screens/file_editor_page.dart';
import '../screens/file_image_viewer_page.dart';
import 'download_progress_sheet.dart';
import 'file_details_sheet.dart';
import 'file_delete_sheet.dart';
import 'file_permission_sheet.dart';
import 'file_compress_sheet.dart';
import 'file_decompress_sheet.dart';
import 'file_move_copy_sheet.dart';
import 'file_share_sheet.dart';

class FileContextMenu {
  FileContextMenu._();

  static void show(
    BuildContext context,
    FileItemDto item, {
    FileViewMode viewMode = FileViewMode.list,
  }) {
    HapticFeedback.mediumImpact();

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final overlay = Overlay.of(context);
    final container = ProviderScope.containerOf(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => UncontrolledProviderScope(
        container: container,
        child: _FileContextMenuOverlay(
          item: item,
          sourceContext: context,
          providerContainer: container,
          isDark: isDark,
          viewMode: viewMode,
          anchorOffset: offset,
          anchorSize: size,
          onDismiss: () {
            entry.remove();
          },
        ),
      ),
    );

    overlay.insert(entry);
  }
}

class _FileContextMenuOverlay extends ConsumerStatefulWidget {
  const _FileContextMenuOverlay({
    required this.item,
    required this.sourceContext,
    required this.providerContainer,
    required this.isDark,
    required this.viewMode,
    required this.anchorOffset,
    required this.anchorSize,
    required this.onDismiss,
  });

  final FileItemDto item;
  final BuildContext sourceContext;
  final ProviderContainer providerContainer;
  final bool isDark;
  final FileViewMode viewMode;
  final Offset anchorOffset;
  final Size anchorSize;
  final VoidCallback onDismiss;

  @override
  ConsumerState<_FileContextMenuOverlay> createState() =>
      _FileContextMenuOverlayState();
}

class _FileContextMenuOverlayState
    extends ConsumerState<_FileContextMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int? _activeSubmenuIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    const menuWidth = 230.0;
    const submenuWidth = 180.0;
    final items = _buildMenuItems(widget.item);

    final rowHeight = 44.0;
    const separatorHeight = 8.5; // 0.5 height + 4.0 * 2 margin

    double menuHeight = 13.0; // 12.0 padding + 1.0 border
    for (int i = 0; i < items.length; i++) {
      menuHeight += rowHeight;
      if (i < items.length - 1 && items[i + 1].hasSeparatorBefore) {
        menuHeight += separatorHeight;
      }
    }
    const gap = 10.0;

    double previewTop = widget.anchorOffset.dy;
    double menuTop = previewTop + widget.anchorSize.height + gap;
    bool isMenuAbove = false;

    if (menuTop + menuHeight > screenSize.height - 24) {
      menuTop = previewTop - menuHeight - gap;
      isMenuAbove = true;
      if (menuTop < 50) {
        double overflow = 50 - menuTop;
        menuTop += overflow;
        previewTop += overflow;
      }
    } else {
      if (previewTop + widget.anchorSize.height > screenSize.height - 40) {
        double overflow =
            (previewTop + widget.anchorSize.height) - (screenSize.height - 40);
        previewTop -= overflow;
        menuTop -= overflow;
      }
    }

    var menuLeft =
        widget.anchorOffset.dx + (widget.anchorSize.width - menuWidth) / 2;
    if (menuLeft < 12) menuLeft = 12;
    if (menuLeft + menuWidth > screenSize.width - 12) {
      menuLeft = screenSize.width - menuWidth - 12;
    }

    // 子菜单位置计算
    final showSubmenu =
        _activeSubmenuIndex != null && items[_activeSubmenuIndex!].hasSubmenu;
    double? submenuLeft;
    double? submenuTop;

    if (showSubmenu) {
      final activeItem = items[_activeSubmenuIndex!];
      final subItems = activeItem.children;
      double submenuHeight = 12.0;
      for (int i = 0; i < subItems.length; i++) {
        submenuHeight += rowHeight;
        if (i < subItems.length - 1 && subItems[i + 1].hasSeparatorBefore) {
          submenuHeight += separatorHeight;
        }
      }

      // 水平位置：智能选择空间更大的一侧
      final spaceRight = screenSize.width - (menuLeft + menuWidth + gap);
      final spaceLeft = menuLeft - gap;

      if (spaceRight >= submenuWidth) {
        // 右侧空间足够
        submenuLeft = menuLeft + menuWidth + gap;
      } else if (spaceLeft >= submenuWidth) {
        // 左侧空间足够
        submenuLeft = menuLeft - submenuWidth - gap;
      } else {
        // 两侧都不够，选择空间更大的一侧并强制 clamp
        submenuLeft = spaceRight > spaceLeft
            ? menuLeft + menuWidth + gap
            : menuLeft - submenuWidth - gap;
      }

      // 强制水平 clamp 确保在屏幕内
      submenuLeft = submenuLeft.clamp(8.0, screenSize.width - submenuWidth - 8);

      // 垂直位置：计算到当前项的准确高度
      double activeItemOffset = 6.0; // Top padding
      for (int i = 0; i < _activeSubmenuIndex!; i++) {
        activeItemOffset += rowHeight;
        if (i < items.length - 1 && items[i + 1].hasSeparatorBefore) {
          activeItemOffset += separatorHeight;
        }
      }

      submenuTop = menuTop + activeItemOffset;

      // 确保子菜单在屏幕内，且尽量不遮挡主菜单的当前项
      if (submenuTop + submenuHeight > screenSize.height - 12) {
        submenuTop = screenSize.height - submenuHeight - 12;
      }
      if (submenuTop < 12) submenuTop = 12;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismiss,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: widget.isDark
                      ? CupertinoColors.black.withValues(alpha: 0.25)
                      : CupertinoColors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: widget.anchorOffset.dx,
          top: previewTop,
          width: widget.anchorSize.width,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: isMenuAbove
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: _FilePreviewItem(
                item: widget.item,
                isDark: widget.isDark,
                viewMode: widget.viewMode,
                anchorSize: widget.anchorSize,
              ),
            ),
          ),
        ),
        Positioned(
          left: menuLeft,
          top: menuTop,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: isMenuAbove
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              child: _buildMenuPanel(items, width: menuWidth),
            ),
          ),
        ),
        if (showSubmenu)
          Positioned(
            left: submenuLeft,
            top: submenuTop,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                alignment: Alignment.centerLeft,
                child: _buildMenuPanel(
                  items[_activeSubmenuIndex!].children,
                  width: submenuWidth,
                  isSubmenu: true,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuPanel(
    List<_MenuItemData> items, {
    double width = 230,
    bool isSubmenu = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.isDark
            ? const Color(0xFF2C2C2E).withValues(alpha: 0.92)
            : CupertinoColors.systemBackground.color.withValues(alpha: 0.96),
        border: Border.all(
          color: widget.isDark
              ? CupertinoColors.white.withValues(alpha: 0.12)
              : CupertinoColors.black.withValues(alpha: 0.06),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(
              alpha: widget.isDark ? 0.4 : 0.15,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _ContextMenuItem(
                data: items[i],
                isDark: widget.isDark,
                isSubmenuActive: !isSubmenu && _activeSubmenuIndex == i,
                onTap: () {
                  if (!isSubmenu && items[i].hasSubmenu) {
                    setState(() => _activeSubmenuIndex = i);
                    return;
                  }
                  _dismiss();
                  items[i].action();
                },
              ),
              if (i < items.length - 1 && items[i + 1].hasSeparatorBefore)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  color: widget.isDark
                      ? CupertinoColors.white.withValues(alpha: 0.1)
                      : CupertinoColors.black.withValues(alpha: 0.06),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<_MenuItemData> _buildMenuItems(FileItemDto item) {
    final items = <_MenuItemData>[];

    // 1. 基础操作
    if (item.isDir) {
      items.add(
        _MenuItemData(
          text: context.l10n.files_actionOpen,
          icon: TablerIcons.folder_open,
          iconColor: CupertinoColors.activeBlue,
          action: () {
            final container = ProviderScope.containerOf(context);
            final scrollController = PrimaryScrollController.maybeOf(
              widget.sourceContext,
            );
            final offset = scrollController?.hasClients == true
                ? scrollController!.offset
                : null;
            container
                .read(filesControllerProvider.notifier)
                .navigateTo(item.path, currentOffset: offset);
          },
        ),
      );
    } else if (FileTypeUtils.isImage(item)) {
      items.add(
        _MenuItemData(
          text: context.l10n.files_actionPreviewImage,
          icon: TablerIcons.photo,
          iconColor: CupertinoColors.activeBlue,
          action: () {
            final container = ProviderScope.containerOf(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => UncontrolledProviderScope(
                  container: container,
                  child: FileImageViewerPage(
                    path: item.path,
                    fileName: item.name,
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else if (FileTypeUtils.isEditable(item)) {
      items.add(
        _MenuItemData(
          text: context.l10n.files_actionEdit,
          icon: TablerIcons.file_code,
          iconColor: CupertinoColors.activeBlue,
          action: () {
            final container = ProviderScope.containerOf(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => UncontrolledProviderScope(
                  container: container,
                  child: FileEditorPage(path: item.path, fileName: item.name),
                ),
              ),
            );
          },
        ),
      );
    }

    items.add(
      _MenuItemData(
        text: context.l10n.files_actionRename,
        icon: TablerIcons.forms,
        iconColor: CupertinoColors.systemPurple,
        action: () {
          final container = widget.providerContainer;
          container
              .read(filesControllerProvider.notifier)
              .startRename(item.path);
        },
      ),
    );

    items.add(
      _MenuItemData(
        text: context.l10n.files_actionCopyPath,
        icon: TablerIcons.clipboard_copy,
        iconColor: CupertinoColors.systemGrey,
        action: () {
          Clipboard.setData(ClipboardData(text: item.path));
          showAppSuccessToast(context.l10n.files_pathCopied);
        },
      ),
    );

    // 2. 整理与高级 (子菜单)
    items.add(
      _MenuItemData(
        text: context.l10n.files_actionOrganize,
        icon: TablerIcons.adjustments_horizontal,
        iconColor: CupertinoColors.activeBlue,
        action: () {},
        hasSeparatorBefore: true,
        children: [
          _MenuItemData(
            text: context.l10n.files_actionCopy,
            icon: TablerIcons.copy,
            iconColor: CupertinoColors.systemTeal,
            action: () => FileMoveCopySheet.start(
              context: widget.sourceContext,
              container: widget.providerContainer,
              items: [item],
              type: FileOperationType.copy,
            ),
          ),
          _MenuItemData(
            text: context.l10n.files_actionMove,
            icon: TablerIcons.cut,
            iconColor: CupertinoColors.systemOrange,
            action: () => FileMoveCopySheet.start(
              context: widget.sourceContext,
              container: widget.providerContainer,
              items: [item],
              type: FileOperationType.move,
            ),
          ),
          _MenuItemData(
            text: context.l10n.files_actionPermissions,
            icon: TablerIcons.lock,
            iconColor: CupertinoColors.systemBrown,
            action: () => FilePermissionSheet.show(
              widget.sourceContext,
              item,
              providerContainer: widget.providerContainer,
            ),
          ),
          _MenuItemData(
            text: context.l10n.files_actionCompress,
            icon: TablerIcons.file_zip,
            iconColor: CupertinoColors.systemYellow,
            action: () => FileCompressSheet.show(widget.sourceContext, [item]),
          ),
          if (FileTypeUtils.isArchive(item))
            _MenuItemData(
              text: context.l10n.files_actionDecompress,
              icon: TablerIcons.package_export,
              iconColor: CupertinoColors.systemOrange,
              action: () =>
                  FileDecompressSheet.show(widget.sourceContext, item),
            ),
        ],
      ),
    );

    // 3. 其他操作
    items.add(
      _MenuItemData(
        text: context.l10n.common_select,
        icon: TablerIcons.checkbox,
        iconColor: CupertinoColors.activeBlue,
        action: () {
          final container = ProviderScope.containerOf(context);
          final notifier = container.read(filesControllerProvider.notifier);
          notifier.toggleSelectionMode();
          notifier.toggleItemSelection(item.path);
        },
      ),
    );

    final isFavorite = item.favoriteID != 0;
    items.add(
      _MenuItemData(
        text: isFavorite
            ? context.l10n.files_actionRemoveFavorite
            : context.l10n.files_actionAddFavorite,
        icon: isFavorite ? TablerIcons.star_off : TablerIcons.star,
        iconColor: const Color(0xFFF8D748),
        action: () {
          final container = ProviderScope.containerOf(context);
          container.read(filesControllerProvider.notifier).toggleFavorite(item);
        },
      ),
    );

    if (!item.isDir) {
      final hasShare = item.shareCode.isNotEmpty;
      items.add(
        _MenuItemData(
          text: hasShare
              ? context.l10n.files_actionManageShare
              : context.l10n.files_actionCreateShare,
          icon: TablerIcons.share,
          iconColor: CupertinoColors.systemGreen,
          action: () => FileShareSheet.show(widget.sourceContext, item),
        ),
      );

      if (hasShare) {
        final shareCancelledText = context.l10n.files_shareCancelled;
        final cancelShareFailedText = context.l10n.files_cancelShareFailed;
        items.add(
          _MenuItemData(
            text: context.l10n.files_actionCancelShare,
            icon: TablerIcons.share_off,
            iconColor: CupertinoColors.destructiveRed,
            action: () async {
              final container = widget.providerContainer;
              try {
                await container
                    .read(filesControllerProvider.notifier)
                    .deleteFileShare(item.path);
                showAppSuccessToast(shareCancelledText);
              } catch (e) {
                showAppErrorToast(cancelShareFailedText('$e'));
              }
            },
          ),
        );
      }
    }

    if (!item.isDir) {
      items.add(
        _MenuItemData(
          text: context.l10n.files_actionDownloadToLocal,
          icon: TablerIcons.download,
          iconColor: CupertinoColors.systemGreen,
          action: () async {
            final container = widget.providerContainer;
            final sourceCtx = widget.sourceContext;
            final serverId = container.read(activeServerIdProvider);
            final taskId = await container
                .read(downloadManagerProvider.notifier)
                .startDownload(
                  serverId: serverId,
                  remotePath: item.path,
                  fileName: item.name,
                  fileSize: item.size,
                );
            if (!sourceCtx.mounted) return;
            showDownloadProgressSheet(sourceCtx, [taskId]);
          },
        ),
      );
    } else {
      items.add(
        _MenuItemData(
          text: context.l10n.files_actionPackageDownload,
          icon: TablerIcons.package_export,
          iconColor: CupertinoColors.systemGreen,
          action: () async {
            final container = widget.providerContainer;
            final sourceCtx = widget.sourceContext;
            final serverId = container.read(activeServerIdProvider);
            final taskId = await container
                .read(downloadManagerProvider.notifier)
                .startBatchPackageDownload(
                  serverId: serverId,
                  remotePaths: [item.path],
                );
            if (!sourceCtx.mounted) return;
            showDownloadProgressSheet(sourceCtx, [taskId]);
          },
        ),
      );
    }

    items.add(
      _MenuItemData(
        text: context.l10n.files_actionViewDetails,
        icon: TablerIcons.info_circle,
        iconColor: CupertinoColors.systemBlue,
        action: () => FileDetailsSheet.show(widget.sourceContext, item),
      ),
    );

    // 4. 删除
    items.add(
      _MenuItemData(
        text: context.l10n.files_actionDelete,
        icon: TablerIcons.trash,
        iconColor: CupertinoColors.destructiveRed,
        isDestructive: true,
        hasSeparatorBefore: true,
        action: () async {
          final container = widget.providerContainer;
          final controller = container.read(filesControllerProvider.notifier);
          final sourceCtx = widget.sourceContext;
          final recycleEnabled = await controller.getRecycleStatus();

          if (!sourceCtx.mounted) return;
          final result = await FileDeleteSheet.show(
            sourceCtx,
            item: item,
            recycleEnabled: recycleEnabled,
          );

          if (result?.confirmed != true) return;
          await controller.deleteFile(
            item,
            forceDelete: result?.forceDelete ?? false,
          );
        },
      ),
    );

    return items;
  }
}

class _MenuItemData {
  final String text;
  final IconData icon;
  final Color iconColor;
  final VoidCallback action;
  final bool isDestructive;
  final bool hasSeparatorBefore;
  final List<_MenuItemData> children;

  const _MenuItemData({
    required this.text,
    required this.icon,
    this.iconColor = CupertinoColors.activeBlue,
    required this.action,
    this.isDestructive = false,
    this.hasSeparatorBefore = false,
    this.children = const [],
  });

  bool get hasSubmenu => children.isNotEmpty;
}

class _ContextMenuItem extends StatefulWidget {
  const _ContextMenuItem({
    required this.data,
    required this.isDark,
    this.isSubmenuActive = false,
    required this.onTap,
  });

  final _MenuItemData data;
  final bool isDark;
  final bool isSubmenuActive;
  final VoidCallback onTap;

  @override
  State<_ContextMenuItem> createState() => _ContextMenuItemState();
}

class _ContextMenuItemState extends State<_ContextMenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final defaultColor = widget.isDark
        ? CupertinoColors.white
        : CupertinoColors.black;
    final textColor = widget.data.isDestructive
        ? CupertinoColors.destructiveRed
        : defaultColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44, // 强制固定高度
        color: _isPressed
            ? (widget.isDark
                  ? CupertinoColors.white.withValues(alpha: 0.1)
                  : CupertinoColors.black.withValues(alpha: 0.1))
            : widget.isSubmenuActive
            ? (widget.isDark
                  ? CupertinoColors.white.withValues(alpha: 0.08)
                  : CupertinoColors.black.withValues(alpha: 0.06))
            : const Color(0x00000000),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(
              widget.data.icon,
              size: 18,
              color: widget.data.isDestructive
                  ? CupertinoColors.destructiveRed
                  : widget.data.iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.data.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: widget.data.isDestructive
                      ? FontWeight.w500
                      : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            if (widget.data.hasSubmenu) ...[
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                size: 13,
                color: AppColors.tertiaryLabel(context).withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilePreviewItem extends StatelessWidget {
  const _FilePreviewItem({
    required this.item,
    required this.isDark,
    required this.viewMode,
    required this.anchorSize,
  });

  final FileItemDto item;
  final bool isDark;
  final FileViewMode viewMode;
  final Size anchorSize;

  @override
  Widget build(BuildContext context) {
    if (viewMode == FileViewMode.icon) {
      return _buildIconPreview(context);
    }

    return _buildPreviewSurface(
      context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            FileIconUtils.buildIcon(context, item, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildSubtitle(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSurface(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIconPreview(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: anchorSize.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 2),
            FileIconUtils.buildIcon(context, item, size: 44),
            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? CupertinoColors.white : CupertinoColors.black,
              ),
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
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final date = DateTime.tryParse(item.modTime)?.toLocal();
    final dateStr = date != null
        ? '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}'
        : '';

    String info;
    if (item.isDir) {
      info = formatPermissions(item.mode, true);
    } else {
      info = formatBytes(item.size);
    }

    return Text(
      '$dateStr  •  $info',
      style: TextStyle(fontSize: 12, color: AppColors.secondaryLabel(context)),
    );
  }

  String _formatIconModTime() {
    final date = DateTime.tryParse(item.modTime)?.toLocal();
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
    if (item.isDir) {
      return formatPermissions(item.mode, true);
    }
    return formatBytes(item.size);
  }
}
