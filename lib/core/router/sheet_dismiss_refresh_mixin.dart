import 'package:flutter/widgets.dart';

import 'sheet_route_tracker.dart';

/// Mixin for State objects that want to refresh when all sheets are closed.
///
/// Usage:
/// ```dart
/// class _MyPageState extends ConsumerState<MyPage>
///     with SheetDismissRefreshMixin {
///   @override
///   void onAllSheetsClosed() {
///     ref.read(myControllerProvider.notifier).refresh();
///   }
/// }
/// ```
///
/// The mixin automatically registers in [initState] and unregisters in
/// [dispose], so you only need to implement [onAllSheetsClosed].
mixin SheetDismissRefreshMixin<T extends StatefulWidget> on State<T> {
  /// Override this to define what happens when all sheets are closed.
  void onAllSheetsClosed();

  @override
  void initState() {
    super.initState();
    sheetRouteTracker.addOnAllSheetsClosed(_handleSheetsClosed);
  }

  @override
  void dispose() {
    sheetRouteTracker.removeOnAllSheetsClosed(_handleSheetsClosed);
    super.dispose();
  }

  void _handleSheetsClosed() {
    if (mounted) {
      onAllSheetsClosed();
    }
  }
}
