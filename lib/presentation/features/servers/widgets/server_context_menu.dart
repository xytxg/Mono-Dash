import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../domain/entities/server.dart';
import '../../settings/providers/app_settings_provider.dart';
import 'server_card.dart';

class ServerContextMenu {
  const ServerContextMenu._();

  static void show(
    BuildContext context,
    Server server, {
    required ServerCardStyle style,
    required VoidCallback onSort,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
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
        child: _ServerContextMenuOverlay(
          server: server,
          style: style,
          isDark: isDark,
          anchorOffset: offset,
          anchorSize: size,
          onSort: onSort,
          onEdit: onEdit,
          onDelete: onDelete,
          onDismiss: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);
  }
}

class _ServerContextMenuOverlay extends StatefulWidget {
  const _ServerContextMenuOverlay({
    required this.server,
    required this.style,
    required this.isDark,
    required this.anchorOffset,
    required this.anchorSize,
    required this.onSort,
    required this.onEdit,
    required this.onDelete,
    required this.onDismiss,
  });

  final Server server;
  final ServerCardStyle style;
  final bool isDark;
  final Offset anchorOffset;
  final Size anchorSize;
  final VoidCallback onSort;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDismiss;

  @override
  State<_ServerContextMenuOverlay> createState() =>
      _ServerContextMenuOverlayState();
}

class _ServerContextMenuOverlayState extends State<_ServerContextMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

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
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss([VoidCallback? afterDismiss]) {
    _controller.reverse().then((_) {
      widget.onDismiss();
      afterDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenSize = MediaQuery.sizeOf(context);
    const menuWidth = 230.0;
    const menuHeight = 145.0;
    const gap = 10.0;

    double previewTop = widget.anchorOffset.dy;
    double menuTop = previewTop + widget.anchorSize.height + gap;
    var isMenuAbove = false;
    if (menuTop + menuHeight > screenSize.height - 24) {
      menuTop = previewTop - menuHeight - gap;
      isMenuAbove = true;
      if (menuTop < 50) {
        final overflow = 50 - menuTop;
        menuTop += overflow;
        previewTop += overflow;
      }
    }

    var menuLeft =
        widget.anchorOffset.dx + (widget.anchorSize.width - menuWidth) / 2;
    if (menuLeft < 12) menuLeft = 12;
    if (menuLeft + menuWidth > screenSize.width - 12) {
      menuLeft = screenSize.width - menuWidth - 12;
    }

    final items = [
      _MenuItemData(
        text: l10n.servers_sort,
        icon: TablerIcons.arrows_sort,
        iconColor: CupertinoColors.activeBlue,
        action: widget.onSort,
      ),
      _MenuItemData(
        text: l10n.servers_edit,
        icon: TablerIcons.edit,
        iconColor: CupertinoColors.systemPurple,
        action: widget.onEdit,
      ),
      _MenuItemData(
        text: l10n.common_delete,
        icon: TablerIcons.trash,
        iconColor: CupertinoColors.destructiveRed,
        isDestructive: true,
        hasSeparatorBefore: true,
        action: widget.onDelete,
      ),
    ];

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
              child: _ServerPreviewItem(
                server: widget.server,
                style: widget.style,
                isDark: widget.isDark,
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
              child: _buildMenuPanel(items),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuPanel(List<_MenuItemData> items) {
    return Container(
      width: 230,
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
            for (var i = 0; i < items.length; i++) ...[
              _ContextMenuItem(
                data: items[i],
                isDark: widget.isDark,
                onTap: () => _dismiss(items[i].action),
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
}

class _ServerPreviewItem extends StatelessWidget {
  const _ServerPreviewItem({
    required this.server,
    required this.style,
    required this.isDark,
  });

  final Server server;
  final ServerCardStyle style;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ServerCard(server: server, style: style),
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.text,
    required this.icon,
    required this.action,
    this.iconColor = CupertinoColors.activeBlue,
    this.isDestructive = false,
    this.hasSeparatorBefore = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback action;
  final Color iconColor;
  final bool isDestructive;
  final bool hasSeparatorBefore;
}

class _ContextMenuItem extends StatefulWidget {
  const _ContextMenuItem({
    required this.data,
    required this.isDark,
    required this.onTap,
  });

  final _MenuItemData data;
  final bool isDark;
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
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        color: _isPressed
            ? (widget.isDark
                  ? CupertinoColors.white.withValues(alpha: 0.1)
                  : CupertinoColors.black.withValues(alpha: 0.1))
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
          ],
        ),
      ),
    );
  }
}
