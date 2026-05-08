import 'package:flutter/cupertino.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../domain/entities/dashboard.dart';

List<DiskUsage> visibleDashboardDisks(List<DiskUsage> disks) {
  if (disks.length <= 3) return disks;
  final root = disks.where((disk) => disk.path == '/').toList();
  final rootDisk = root.take(1).toList();
  final others = disks
      .where((disk) => disk.path != '/')
      .take(3 - rootDisk.length);
  return [...rootDisk, ...others].toList(growable: false);
}

DiskUsage? primaryDashboardDisk(List<DiskUsage> disks) {
  if (disks.isEmpty) return null;
  for (final disk in disks) {
    if (disk.path == '/') return disk;
  }
  return disks.first;
}

String firstNotEmpty(String first, String second) =>
    first.isNotEmpty ? first : second;

String formatDashboardCpuUsage(DashboardBase base, DashboardCurrent current) {
  final total = base.cpuLogicalCores > 0
      ? base.cpuLogicalCores
      : current.cpuTotal;
  if (total <= 0) return '-';
  return '${current.cpuUsed.toStringAsFixed(2)} / $total ${total == 1 ? 'Core' : 'Cores'}';
}

String formatDashboardUptime(int seconds, AppLocalizations l10n) {
  if (seconds <= 0) return l10n.dashboard_uptimeMinutes(0);
  final days = seconds ~/ Duration.secondsPerDay;
  final hours = (seconds % Duration.secondsPerDay) ~/ Duration.secondsPerHour;
  final minutes =
      (seconds % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;
  if (days > 0) return l10n.dashboard_uptimeDaysHours(days, hours);
  if (hours > 0) return l10n.dashboard_uptimeHoursMinutes(hours, minutes);
  return l10n.dashboard_uptimeMinutes(minutes);
}

String dashboardOsAsset(DashboardBase base) {
  final source = [
    base.prettyDistro,
    base.platform,
    base.platformFamily,
    base.os,
  ].join(' ').toLowerCase();

  if (source.contains('ubuntu')) return 'assets/icons/os/Ubuntu.svg';
  if (source.contains('debian')) return 'assets/icons/os/Debian.svg';
  if (source.contains('centos')) return 'assets/icons/os/CentOS.svg';
  if (source.contains('fedora')) return 'assets/icons/os/Fedora.svg';
  if (source.contains('arch')) return 'assets/icons/os/Arch Linux.svg';
  if (source.contains('suse')) return 'assets/icons/os/openSUSE.svg';
  return 'assets/icons/os/Linux.svg';
}

Color dashboardUsageColor(BuildContext context, double percent) {
  if (percent >= 85) return CupertinoColors.systemRed.resolveFrom(context);
  if (percent >= 60) return CupertinoColors.systemOrange.resolveFrom(context);
  return CupertinoColors.systemGreen.resolveFrom(context);
}
