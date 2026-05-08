import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_theme.dart';
import 'more_info_card.dart';

class LoadingBlock extends StatelessWidget {
  const LoadingBlock({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: moreCardDecoration(context),
      child: Row(
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: AppColors.secondaryLabel(context)),
          ),
        ],
      ),
    );
  }
}
