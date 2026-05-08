import 'package:flutter/widgets.dart';

/// 经过计算的定位数据，由 [computeTapOffsetPosition] 生成
class OverlayPositionData {
  const OverlayPositionData({
    required this.top,
    required this.left,
    required this.showAbove,
    required this.screenSize,
    required this.anchorOffset,
  });

  final double top;
  final double left;
  final bool showAbove;
  final Size screenSize;
  final Offset anchorOffset;

  /// 根据 showAbove 返回适合 ScaleTransition 的对齐方式
  Alignment get scaleAlignment =>
      showAbove ? Alignment.bottomCenter : Alignment.topCenter;
}

/// 管理 [OverlayEntry] 生命周期的 Mixin，用于浮层菜单场景。
///
/// 职责：OverlayEntry 的创建、插入、移除和 dispose 清理。
/// 定位逻辑由调用方负责，可通过 [computeTapOffsetPosition] 辅助计算。
mixin OverlayMenuMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? _overlayMenuEntry;

  /// 当前是否有浮层处于打开状态
  bool get isOverlayMenuOpen => _overlayMenuEntry != null;

  /// 显示浮层菜单。
  ///
  /// [contentBuilder] 返回需要放入 Stack 的 Widget 列表（通常是 Positioned 菜单面板）。
  /// [dismissBuilder] 可自定义点击外部关闭的背景 Widget，默认为不透明 GestureDetector。
  /// [animationController] 传入后关闭时会先执行反向动画再移除。
  void showOverlayMenu({
    required List<Widget> Function(BuildContext context) contentBuilder,
    Widget Function(BuildContext context, VoidCallback onDismiss)?
    dismissBuilder,
    AnimationController? animationController,
    VoidCallback? onOverlayBuilt,
  }) {
    if (_overlayMenuEntry != null || !mounted) return;

    _overlayMenuEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          dismissBuilder?.call(context, hideOverlayMenu) ??
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: hideOverlayMenu,
                ),
              ),
          ...contentBuilder(context),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayMenuEntry!);
    onOverlayBuilt?.call();
  }

  /// 关闭浮层菜单。
  ///
  /// 传入 [animationController] 会先执行反向动画再移除。
  /// 返回 Future 以便在动画完成后执行后续操作。
  Future<void> hideOverlayMenu({AnimationController? animationController}) {
    if (_overlayMenuEntry == null) return Future.value();

    if (animationController != null) {
      return animationController.reverse().then((_) {
        _forceRemoveOverlayMenu();
        if (mounted) setState(() {});
      });
    } else {
      _forceRemoveOverlayMenu();
      if (mounted) setState(() {});
      return Future.value();
    }
  }

  /// 无动画移除浮层，供 dispose 调用
  void _forceRemoveOverlayMenu() {
    _overlayMenuEntry?.remove();
    _overlayMenuEntry = null;
  }

  /// 触发浮层重建（用于实时更新，如切换子菜单）
  void rebuildOverlay() => _overlayMenuEntry?.markNeedsBuild();

  @override
  void dispose() {
    _forceRemoveOverlayMenu();
    super.dispose();
  }

  /// 计算基于点击坐标的浮层位置。
  ///
  /// 自动判断在点击上方还是下方显示，并水平夹紧确保不超出屏幕。
  static OverlayPositionData computeTapOffsetPosition({
    required Offset tapOffset,
    required Size screenSize,
    required double menuWidth,
    required double menuHeight,
    double horizontalMargin = 12.0,
    double verticalGap = 10.0,
    double horizontalBias = 0.0,
  }) {
    final showAbove = tapOffset.dy > screenSize.height / 2;

    double menuLeft = tapOffset.dx + horizontalBias;
    if (menuLeft + menuWidth > screenSize.width - horizontalMargin) {
      menuLeft = screenSize.width - menuWidth - horizontalMargin;
    }
    if (menuLeft < horizontalMargin) menuLeft = horizontalMargin;

    final menuTop = showAbove
        ? tapOffset.dy - menuHeight - verticalGap
        : tapOffset.dy + verticalGap;

    return OverlayPositionData(
      top: menuTop,
      left: menuLeft,
      showAbove: showAbove,
      screenSize: screenSize,
      anchorOffset: tapOffset,
    );
  }

  /// 静态方法模式的浮层辅助（如 FileContextMenu.show）。
  ///
  /// 返回一个用于移除浮层的回调函数。
  static VoidCallback showStaticOverlay({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(builder: builder);
    overlay.insert(entry);
    return entry.remove;
  }
}
