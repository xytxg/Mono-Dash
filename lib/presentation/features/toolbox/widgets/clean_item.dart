import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../common/components/more_info_card.dart';
import '../../../common/utils/display_utils.dart';

class CleanItem extends StatelessWidget {
  const CleanItem({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: moreCardDecoration(context),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text(item['label'] ?? item['name']),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label(context),
                ),
              ),
            ),
            Text(
              formatBytes(item['size']),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
