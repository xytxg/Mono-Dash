import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/defer_init.dart';

typedef WebsiteSheetHeaderBuilder<T> =
    Widget Function(BuildContext context, WidgetRef ref, AsyncValue<T>? value);
typedef WebsiteSheetDataBuilder<T> =
    Widget Function(BuildContext context, T data);
typedef WebsiteSheetOverlayBuilder<T> =
    Widget Function(BuildContext context, AsyncValue<T>? value);

/// Shows a BottomSheet dedicated to the website module.
Future<T?> showWebsiteModalSheet<T>({
  required BuildContext context,
  required Widget child,
  Color? barrierColor,
  bool expand = false,
  bool useRootNavigator = false,
}) {
  return showActionSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    expand: expand,
    barrierColor: barrierColor,
    builder: (context) => child,
  );
}

/// Generic async loading panel for the website module.
class WebsiteAsyncModalSheet<T> extends StatelessWidget {
  const WebsiteAsyncModalSheet({
    super.key,
    required this.provider,
    this.headerBuilder,
    required this.dataBuilder,
    required this.onRetry,
    this.maxHeightFactor = 0.88,
    this.minBodyHeightFactor,
    this.backgroundAlpha = 0.92,
    this.errorTitle = 'Load failed',
    this.isAdaptive = false,
    this.showHandle = true,
    this.panelOverlayBuilder,
    this.infoCardBuilder,
  });

  final ProviderListenable<AsyncValue<T>> provider;
  final WebsiteSheetHeaderBuilder<T>? headerBuilder;
  final WebsiteSheetHeaderBuilder<T>? infoCardBuilder;
  final WebsiteSheetDataBuilder<T> dataBuilder;
  final void Function(WidgetRef ref) onRetry;
  final double maxHeightFactor;
  final double? minBodyHeightFactor;
  final double backgroundAlpha;
  final String errorTitle;
  final bool isAdaptive;
  final bool showHandle;
  final WebsiteSheetOverlayBuilder<T>? panelOverlayBuilder;

  @override
  Widget build(BuildContext context) {
    return DeferInit(
      builder: (context, isReady) {
        return Consumer(
          builder: (context, ref, _) {
            final async = isReady ? ref.watch(provider) : null;
            final body =
                async?.when(
                  data: (data) => dataBuilder(context, data),
                  loading: () => const WebsiteSheetLoadingState(),
                  error: (error, _) => WebsiteSheetErrorState(
                    title: errorTitle,
                    error: error,
                    onRetry: () => onRetry(ref),
                  ),
                ) ??
                const WebsiteSheetLoadingState();

            return ActionSheetScaffold(
              enableBlur: isReady,
              maxHeightFactor: maxHeightFactor,
              minBodyHeightFactor: minBodyHeightFactor,
              backgroundAlpha: backgroundAlpha,
              isAdaptive: isAdaptive,
              showHandle: showHandle,
              infoCard: infoCardBuilder?.call(context, ref, async),
              panelHeader: headerBuilder?.call(context, ref, async),
              panelOverlay: panelOverlayBuilder?.call(context, async),
              child: body,
            );
          },
        );
      },
    );
  }
}

/// Loading state dedicated to the website module.
class WebsiteSheetLoadingState extends StatelessWidget {
  const WebsiteSheetLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 52),
      child: CupertinoActivityIndicator(),
    );
  }
}

/// Error state dedicated to the website module.
class WebsiteSheetErrorState extends StatelessWidget {
  const WebsiteSheetErrorState({
    super.key,
    required this.error,
    required this.onRetry,
    this.title = 'Load failed',
  });

  final Object error;
  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: title,
      error: error,
      onRetry: onRetry,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
    );
  }
}
