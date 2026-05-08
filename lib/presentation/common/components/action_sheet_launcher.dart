import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// 统一的底部弹窗启动器，封装了样式、动画和 ProviderScope 继承逻辑。
Future<T?> showActionSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  ProviderContainer? providerContainer,
  VoidCallback? onDismiss,
  bool expand = false,
  bool useRootNavigator = false,
  bool enableDrag = true,
  Duration duration = const Duration(milliseconds: 350),
  Color? barrierColor,
}) async {
  final container = providerContainer ?? ProviderScope.containerOf(context);
  final result = await showCupertinoModalBottomSheet<T>(
    context: context,
    backgroundColor: CupertinoColors.transparent,
    barrierColor: barrierColor ?? CupertinoColors.black.withValues(alpha: 0.24),
    shadow: const BoxShadow(color: CupertinoColors.transparent),
    animationCurve: Curves.easeInOutQuart,
    duration: duration,
    enableDrag: enableDrag,
    expand: expand,
    useRootNavigator: useRootNavigator,
    builder: (ctx) {
      return UncontrolledProviderScope(
        container: container,
        child: _KeyboardDismissRegion(child: builder(ctx)),
      );
    },
  );
  onDismiss?.call();
  return result;
}

/// 显示带有 ProviderScope 继承的 CupertinoDialog
Future<T?> showProviderDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool barrierDismissible = true,
}) async {
  final container = ProviderScope.containerOf(context);
  return showCupertinoDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) =>
        UncontrolledProviderScope(container: container, child: builder(ctx)),
  );
}

class _KeyboardDismissRegion extends StatelessWidget {
  const _KeyboardDismissRegion({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
