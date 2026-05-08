import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../common/components/frosted_overlay_menu.dart';

enum ProcessSortKey { cpu, memory, pid, connections }

class ProcessOverlayMenu extends StatelessWidget {
  const ProcessOverlayMenu({
    super.key,
    required this.isDark,
    required this.isOverlapping,
    required this.currentSort,
    required this.onSortChanged,
    required this.onSearchEnter,
  });

  final bool isDark;
  final bool isOverlapping;
  final ProcessSortKey currentSort;
  final ValueChanged<ProcessSortKey> onSortChanged;
  final VoidCallback onSearchEnter;

  @override
  Widget build(BuildContext context) {
    return FrostedOverlayMenuButton(
      label: context.l10n.common_menu,
      isDark: isDark,
      isOverlapping: isOverlapping,
      items: [
        FrostedMenuItem(
          text: context.l10n.common_search,
          icon: TablerIcons.search,
          action: onSearchEnter,
        ),
        FrostedMenuItem(
          text: context.l10n.process_sort,
          icon: TablerIcons.arrows_sort,
          action: () {},
          children: [
            _sortItem(
              context.l10n.process_sortCpu,
              TablerIcons.cpu,
              ProcessSortKey.cpu,
            ),
            _sortItem(
              context.l10n.process_sortMemory,
              TablerIcons.cpu_2,
              ProcessSortKey.memory,
            ),
            _sortItem('PID', TablerIcons.hash, ProcessSortKey.pid),
            _sortItem(
              context.l10n.process_sortConnections,
              TablerIcons.plug,
              ProcessSortKey.connections,
            ),
          ],
        ),
      ],
    );
  }

  FrostedMenuItem _sortItem(String label, IconData icon, ProcessSortKey key) {
    final isActive = currentSort == key;
    return FrostedMenuItem(
      text: label,
      icon: icon,
      iconWidget: isActive
          ? const Icon(
              TablerIcons.check,
              size: 16,
              color: CupertinoColors.activeBlue,
            )
          : null,
      action: () => onSortChanged(key),
    );
  }
}
