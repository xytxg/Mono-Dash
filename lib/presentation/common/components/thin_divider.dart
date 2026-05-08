import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

/// 0.5px 宽度的细分隔线。
class ThinDivider extends StatelessWidget {
  const ThinDivider({super.key, this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent),
      height: 0.5,
      color: AppColors.separator(context).withValues(alpha: 0.14),
    );
  }
}
