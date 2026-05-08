import 'package:flutter/widgets.dart';

/// 跟踪当前导航栈中是否存在 sheet 路由。
///
/// 除了基本的计数器，还支持注册"所有 sheet 关闭后"的回调列表，
/// 方便各页面（网站、应用商店、容器等）实现关闭 sheet 后自动刷新。
class SheetRouteTracker extends NavigatorObserver {
  final ValueNotifier<int> _activeSheetCount = ValueNotifier<int>(0);

  /// 当所有 sheet 关闭（计数归零）时触发的回调集合。
  /// 使用 Set 避免重复注册，回调本身是页面级的 VoidCallback。
  final Set<VoidCallback> _onAllSheetsClosed = {};

  bool get hasActiveSheet => _activeSheetCount.value > 0;

  /// 注册一个回调，当所有 sheet 关闭后自动执行。
  /// 通常在页面 initState 中调用。
  void addOnAllSheetsClosed(VoidCallback callback) {
    _onAllSheetsClosed.add(callback);
  }

  /// 移除已注册的回调。
  /// 通常在页面 dispose 中调用，防止内存泄漏。
  void removeOnAllSheetsClosed(VoidCallback callback) {
    _onAllSheetsClosed.remove(callback);
  }

  bool isSheetRoute(Route<dynamic>? route) {
    if (route == null) return false;
    final routeType = route.runtimeType.toString().toLowerCase();
    return routeType.contains('sheet');
  }

  void _onRoutePushed(Route<dynamic>? route) {
    if (!isSheetRoute(route)) return;
    _activeSheetCount.value += 1;
  }

  void _onRoutePopped(Route<dynamic>? route) {
    if (!isSheetRoute(route)) return;
    final nextValue = _activeSheetCount.value - 1;
    _activeSheetCount.value = nextValue < 0 ? 0 : nextValue;

    // 所有 sheet 都关闭后，触发注册的刷新回调
    if (_activeSheetCount.value == 0 && _onAllSheetsClosed.isNotEmpty) {
      // 拷贝一份再遍历，防止回调中修改集合
      for (final cb in [..._onAllSheetsClosed]) {
        cb();
      }
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onRoutePushed(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onRoutePopped(route);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onRoutePopped(route);
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _onRoutePopped(oldRoute);
    _onRoutePushed(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

final sheetRouteTracker = SheetRouteTracker();
