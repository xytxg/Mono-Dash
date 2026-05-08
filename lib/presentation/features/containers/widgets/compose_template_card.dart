import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/compose_template_dto.dart';

class ComposeTemplateCard extends StatelessWidget {
  const ComposeTemplateCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ComposeTemplateDto item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = AppColors.secondaryLabel(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemIndigo
                          .resolveFrom(context)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      TablerIcons.template,
                      size: 24,
                      color: CupertinoColors.systemIndigo.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                          ),
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: secondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(TablerIcons.clock, size: 14, color: secondary),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.containers_createdAt,
                    style: TextStyle(fontSize: 12, color: secondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formatTimeAgo(
                        DateTime.tryParse(item.createdAt),
                        context.l10n,
                        prefix: '',
                      ),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.label(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
