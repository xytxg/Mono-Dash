import 'package:flutter/widgets.dart';

/// A widget that defers the initialization of its content until the 
/// current route animation is completed.
/// This helps in preventing jank during transition animations by 
/// delaying heavy build/fetch operations.
class DeferInit extends StatefulWidget {
  final Widget Function(BuildContext context, bool isReady) builder;
  const DeferInit({super.key, required this.builder});

  @override
  State<DeferInit> createState() => _DeferInitState();
}

class _DeferInitState extends State<DeferInit> {
  bool _isReady = false;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route == null) {
        setState(() => _isReady = true);
        return;
      }
      
      _animation = route.animation;
      if (_animation == null || _animation!.status == AnimationStatus.completed) {
        setState(() => _isReady = true);
      } else {
        _animation!.addStatusListener(_onAnimationStatusChanged);
      }
    });
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) setState(() => _isReady = true);
      _animation?.removeStatusListener(_onAnimationStatusChanged);
    }
  }

  @override
  void dispose() {
    _animation?.removeStatusListener(_onAnimationStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isReady);
  }
}
