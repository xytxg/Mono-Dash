import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/feature_scroll.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/more_info_card.dart';
import '../widgets/clean_item.dart';

class CleanScanPage extends StatelessWidget {
  const CleanScanPage({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groups = data.entries
        .map((entry) => MapEntry(entry.key, (entry.value as List?) ?? const []))
        .where((entry) => entry.value.isNotEmpty)
        .toList(growable: false);

    return FrostedScaffold(
      title: l10n.toolbox_cacheClean,
      body: FeatureScroll(
        children: [
          for (final group in groups) ...[
            MoreSectionTitle(title: _cleanGroupName(group.key, l10n)),
            for (final item in group.value.whereType<Map>())
              CleanItem(item: item.cast<String, dynamic>()),
            const SizedBox(height: 12),
          ],
          if (groups.isEmpty)
            AppEmptyState(
              icon: TablerIcons.check,
              title: l10n.toolbox_noCleanItems,
              useCardStyle: true,
            ),
        ],
      ),
    );
  }
}

String _cleanGroupName(String key, AppLocalizations l10n) {
  return switch (key) {
    'systemClean' => l10n.toolbox_cleanGroupSystem,
    'backupClean' => l10n.toolbox_cleanGroupBackup,
    'uploadClean' => l10n.toolbox_cleanGroupUpload,
    'downloadClean' => l10n.toolbox_cleanGroupDownload,
    'systemLogClean' => l10n.toolbox_cleanGroupSystemLog,
    'containerClean' => l10n.toolbox_cleanGroupContainer,
    _ => key,
  };
}
