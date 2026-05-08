import 'package:flutter/cupertino.dart';

import '../../../common/components/info_panel.dart';
import '../../../common/components/info_rows.dart';
import '../../../common/components/thin_divider.dart';

/// 键值对信息卡片（用于展示 OS 信息、运行时信息等静态数据）。
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    required this.rows,
    this.labelFlex = 2,
    this.valueFlex = 5,
    this.loading = false,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final List<(String label, String value)> rows;
  final int labelFlex;
  final int valueFlex;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InfoPanel(
      title: title,
      icon: icon,
      iconColor: iconColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            ConfigRow(
              label: rows[i].$1,
              value: rows[i].$2.isEmpty ? '-' : rows[i].$2,
              valueTextAlign: TextAlign.end,
              labelFlex: labelFlex,
              valueFlex: valueFlex,
              loading: loading,
            ),
            if (i != rows.length - 1) const ThinDivider(),
          ],
        ],
      ),
    );
  }
}
