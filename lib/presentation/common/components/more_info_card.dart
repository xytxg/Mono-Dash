import 'package:flutter/cupertino.dart';

import '../../../core/localization/l10n_x.dart';
import '../../../core/theme/app_theme.dart';

class MoreInfoCard extends StatelessWidget {
  const MoreInfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.rows,
    this.trailing,
    this.actions = const [],
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final List<MoreInfoRow> rows;
  final Widget? trailing;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(iconColor, context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: moreCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 82,
                    child: Text(
                      row.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      row.value.isEmpty ? '--' : row.value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.label(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}

class MoreInfoRow {
  const MoreInfoRow(this.label, this.value);
  final String label;
  final String value;
}

class MoreSummaryCard extends StatelessWidget {
  const MoreSummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return MoreInfoCard(
      icon: icon,
      iconColor: iconColor,
      title: title,
      rows: [
        MoreInfoRow(context.l10n.common_count, value),
        MoreInfoRow(context.l10n.common_description, subtitle),
      ],
    );
  }
}

class MoreProgressLine extends StatelessWidget {
  const MoreProgressLine({super.key, required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final value = percent.clamp(0, 100) / 100;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 7,
        color: AppColors.tertiaryBackground(context),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value,
            child: Container(
              color: CupertinoColors.activeBlue.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }
}

class MoreChipText extends StatelessWidget {
  const MoreChipText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: AppColors.secondaryLabel(context)),
    );
  }
}

class MoreSectionTitle extends StatelessWidget {
  const MoreSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryLabel(context),
        ),
      ),
    );
  }
}

BoxDecoration moreCardDecoration(BuildContext context) {
  return BoxDecoration(
    color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: AppColors.separator(context).withValues(alpha: 0.16),
      width: 0.5,
    ),
  );
}
