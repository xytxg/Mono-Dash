import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../common/components/status_tag.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    required this.image,
    this.onTap,
    this.onLongPress,
  });

  final DockerImageInfo image;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final statusColor = image.isUsed
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemGrey.resolveFrom(context);

    final idDisplay = image.id.replaceFirst('sha256:', '');
    final shortId = idDisplay.length > 12
        ? idDisplay.substring(0, 12)
        : idDisplay;
    final tagsDisplay = image.tags.isEmpty ? '-' : image.tags.join(', ');

    return GestureDetector(
      onLongPress: onLongPress,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.separator(context).withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      TablerIcons.photo,
                      size: 22,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shortId,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tagsDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryLabel(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusTag(
                    label: image.isUsed
                        ? context.l10n.containers_imageUsed
                        : context.l10n.containers_imageUnused,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    TablerIcons.database,
                    size: 14,
                    color: AppColors.tertiaryLabel(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatBytes(image.size),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatFileModTime(image.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.tertiaryLabel(context),
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
