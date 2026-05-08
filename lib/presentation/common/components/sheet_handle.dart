import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

/// ActionSheet 顶部的拖拽手柄。
class ActionSheetHandle extends StatelessWidget {
  const ActionSheetHandle({super.key, this.top = 10, this.bottom = 10});

  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: top, bottom: bottom),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.tertiaryLabel(context).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
