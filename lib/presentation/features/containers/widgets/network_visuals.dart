import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';

class NetworkVisual {
  const NetworkVisual({
    required this.icon,
    required this.color,
    required this.label,
    required this.isSystem,
  });

  final IconData icon;
  final Color color;
  final String label;
  final bool isSystem;
}

NetworkVisual networkVisualFor(BuildContext context, String name) {
  final green = CupertinoColors.systemGreen.resolveFrom(context);
  switch (name) {
    case 'bridge':
      return NetworkVisual(
        icon: TablerIcons.git_fork,
        color: green,
        label: 'Bridge',
        isSystem: true,
      );
    case 'host':
      return NetworkVisual(
        icon: TablerIcons.server,
        color: green,
        label: 'Host',
        isSystem: true,
      );
    case 'none':
      return NetworkVisual(
        icon: TablerIcons.circle_off,
        color: green,
        label: 'None',
        isSystem: true,
      );
    default:
      return NetworkVisual(
        icon: TablerIcons.network,
        color: green,
        label: context.l10n.containers_custom,
        isSystem: false,
      );
  }
}
