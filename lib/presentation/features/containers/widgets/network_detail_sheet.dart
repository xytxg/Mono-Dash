import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/network_dtos.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/app_action_components.dart';
import '../providers/network_provider.dart';
import 'network_visuals.dart';

void showNetworkDetailSheet(BuildContext context, NetworkDto network) {
  showActionSheet<void>(
    context: context,
    builder: (context) => _NetworkDetailSheet(network: network),
  );
}

class _NetworkDetailSheet extends ConsumerStatefulWidget {
  const _NetworkDetailSheet({required this.network});

  final NetworkDto network;

  @override
  ConsumerState<_NetworkDetailSheet> createState() =>
      _NetworkDetailSheetState();
}

class _NetworkDetailSheetState extends ConsumerState<_NetworkDetailSheet> {
  String? _inspectContent;
  Object? _inspectError;
  bool _loadingInspect = true;

  @override
  void initState() {
    super.initState();
    _loadInspect();
  }

  Future<void> _loadInspect() async {
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      final content = await repo.inspect(
        id: widget.network.name,
        type: 'network',
        detail: '',
      );
      if (!mounted) return;
      setState(() {
        _inspectContent = content;
        _inspectError = null;
        _loadingInspect = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _inspectError = error;
        _loadingInspect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final network = widget.network;
    final visual = networkVisualFor(context, network.name);

    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      maxHeightFactor: 0.86,
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: visual.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(visual.icon, size: 30, color: visual.color),
          ),
        ),
        title: network.name,
        subtitle: network.driver.isEmpty
            ? context.l10n.containers_defaultDriver
            : network.driver,
        trailing: _NetworkKindBadge(visual: visual),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loadingInspect)
            const _InspectLoading()
          else if (_inspectError != null)
            _InspectLoadError(error: _inspectError!)
          else
            _NetworkInspectContent(
              network: network,
              content: _inspectContent ?? '',
            ),
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.containers_operationGeneric,
            icon: TablerIcons.settings,
          ),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.trash,
                iconColor: CupertinoColors.systemRed,
                title: context.l10n.common_delete,
                subtitle: Text(
                  network.isSystem
                      ? context.l10n.containers_systemNetworkCannotDelete
                      : context.l10n.containers_deleteNetworkSubtitle,
                ),
                enabled: !network.isSystem,
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(networkControllerProvider.notifier).deleteNetworks(
                    context,
                    [network.name],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkInspectContent extends StatelessWidget {
  const _NetworkInspectContent({required this.network, required this.content});

  final NetworkDto network;
  final String content;

  @override
  Widget build(BuildContext context) {
    final data = _decodeInspectJson(content);
    final ipam = _mapValue(data?['IPAM']);
    final ipamConfigs = _listOfMaps(ipam?['Config']);
    final firstIpamConfig = ipamConfigs.isEmpty ? null : ipamConfigs.first;
    final containers = _mapValue(data?['Containers']) ?? const {};
    final labels = _stringPairs(data?['Labels']);
    final options = _stringPairs(data?['Options']);

    if (data == null) return _InspectParseError(content: content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: context.l10n.containers_inspectOverview,
          icon: TablerIcons.info_circle,
        ),
        _InfoGroup(
          children: [
            _InfoRow(
              icon: TablerIcons.fingerprint,
              label: context.l10n.containers_networkId,
              value: _shortValue(_stringValue(data['Id'])),
              monospace: true,
            ),
            _InfoRow(
              icon: TablerIcons.plug_connected,
              label: context.l10n.containers_driver,
              value: _stringValue(data['Driver']),
            ),
            _InfoRow(
              icon: TablerIcons.layers_linked,
              label: 'Scope',
              value: _stringValue(data['Scope']),
            ),
            _InfoRow(
              icon: TablerIcons.calendar_time,
              label: context.l10n.containers_createdAt,
              value: _formatInspectTime(context, data['Created']),
            ),
            _InfoRow(
              icon: TablerIcons.lock,
              label: 'Internal',
              value: _boolText(context, data['Internal']),
            ),
            _InfoRow(
              icon: TablerIcons.link,
              label: 'Attachable',
              value: _boolText(context, data['Attachable']),
            ),
            _InfoRow(
              icon: TablerIcons.world,
              label: 'Ingress',
              value: _boolText(context, data['Ingress']),
            ),
            _InfoRow(
              icon: TablerIcons.route,
              label: 'IPv6',
              value: _boolText(context, data['EnableIPv6']),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const AppSectionHeader(title: 'IPAM', icon: TablerIcons.route),
        _InfoGroup(
          children: [
            _InfoRow(
              icon: TablerIcons.server,
              label: context.l10n.containers_driver,
              value: _stringValue(ipam?['Driver']),
            ),
            _InfoRow(
              icon: TablerIcons.network,
              label: context.l10n.containers_subnet,
              value: _stringValue(firstIpamConfig?['Subnet']),
              monospace: true,
            ),
            _InfoRow(
              icon: TablerIcons.router,
              label: context.l10n.containers_gateway,
              value: _stringValue(firstIpamConfig?['Gateway']),
              monospace: true,
            ),
            _InfoRow(
              icon: TablerIcons.route_2,
              label: 'IP Range',
              value: _stringValue(firstIpamConfig?['IPRange']),
              monospace: true,
            ),
          ],
        ),
        if (containers.isNotEmpty) ...[
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.containers_containers,
            icon: TablerIcons.box_multiple,
          ),
          _ContainerList(containers: containers),
        ],
        if (labels.isNotEmpty) ...[
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.containers_labels,
            icon: TablerIcons.tags,
          ),
          _LabelWrap(labels: labels),
        ],
        if (options.isNotEmpty) ...[
          const SizedBox(height: 18),
          const AppSectionHeader(
            title: 'Options',
            icon: TablerIcons.adjustments,
          ),
          _LabelWrap(labels: options),
        ],
      ],
    );
  }
}

class _NetworkKindBadge extends StatelessWidget {
  const _NetworkKindBadge({required this.visual});

  final NetworkVisual visual;

  @override
  Widget build(BuildContext context) {
    final systemColor = CupertinoColors.systemGrey.resolveFrom(context);
    final color = visual.isSystem ? systemColor : visual.color;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            visual.isSystem ? TablerIcons.cpu : visual.icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            visual.isSystem ? visual.label : context.l10n.containers_custom,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectLoading extends StatelessWidget {
  const _InspectLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(height: 12),
            Text(
              context.l10n.containers_readingNetworkDetails,
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

class _InspectLoadError extends StatelessWidget {
  const _InspectLoadError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return _InfoGroup(
      children: [
        _InfoRow(
          icon: TablerIcons.alert_circle,
          label: context.l10n.containers_readFailed,
          value: error.toString(),
        ),
      ],
    );
  }
}

class _InspectParseError extends StatelessWidget {
  const _InspectParseError({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return _InfoGroup(
      children: [
        _InfoRow(
          icon: TablerIcons.alert_circle,
          label: context.l10n.containers_parseFailed,
          value: content.isEmpty ? '-' : content,
        ),
      ],
    );
  }
}

class _ContainerList extends StatelessWidget {
  const _ContainerList({required this.containers});

  final Map<String, dynamic> containers;

  @override
  Widget build(BuildContext context) {
    final entries = containers.entries.toList();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: entries.asMap().entries.map((entry) {
          final container = _mapValue(entry.value.value) ?? const {};
          final name = _stringValue(
            container['Name'],
            fallback: entry.value.key,
          );
          final ipv4 = _stringValue(container['IPv4Address']);
          final ipv6 = _stringValue(container['IPv6Address']);
          final mac = _stringValue(container['MacAddress']);
          final isLast = entry.key == entries.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemPurple
                            .resolveFrom(context)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        TablerIcons.box,
                        size: 16,
                        color: CupertinoColors.systemPurple.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.label(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (ipv4.isNotEmpty && ipv4 != '-') ipv4,
                              if (ipv6.isNotEmpty && ipv6 != '-') ipv6,
                              if (mac.isNotEmpty && mac != '-') mac,
                            ].join('  ·  '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.25,
                              color: AppColors.secondaryLabel(context),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 54),
                  child: Container(
                    height: 0.5,
                    color: AppColors.separator(context).withValues(alpha: 0.3),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

Map<String, dynamic>? _decodeInspectJson(String content) {
  try {
    final decoded = jsonDecode(content);
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      return first is Map<String, dynamic> ? first : null;
    }
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _mapValue(Object? value) {
  return value is Map<String, dynamic> ? value : null;
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}

String _stringValue(Object? value, {String fallback = '-'}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String _shortValue(String value) {
  if (value == '-' || value.length <= 12) return value;
  return value.substring(0, 12);
}

String _boolText(BuildContext context, Object? value) {
  if (value is bool) {
    return value ? context.l10n.common_yes : context.l10n.common_no;
  }
  if (value == null) return '-';
  return value.toString();
}

String _formatInspectTime(BuildContext context, Object? value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return formatLocalDateTime(_stringValue(value, fallback: ''), locale: locale);
}

List<String> _stringPairs(Object? value) {
  if (value is Map) {
    return value.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .where((entry) => entry.trim().isNotEmpty)
        .toList();
  }
  if (value is List) {
    return value
        .map((entry) => entry.toString())
        .where((entry) => entry.trim().isNotEmpty)
        .toList();
  }
  return const [];
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 54),
                  child: Container(
                    height: 0.5,
                    color: AppColors.separator(context).withValues(alpha: 0.3),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen
                  .resolveFrom(context)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 16,
              color: CupertinoColors.systemGreen.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 30),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label(context),
                    fontFamily: monospace ? 'monospace' : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelWrap extends StatelessWidget {
  const _LabelWrap({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: labels.asMap().entries.map((entry) {
          final isLast = entry.key == labels.length - 1;
          return Column(
            children: [
              _LabelRow(label: entry.value),
              if (!isLast)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.only(left: 40),
                  color: AppColors.separator(context).withValues(alpha: 0.3),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final parts = label.split('=');
    final key = parts.first.trim();
    final value = parts.length > 1 ? parts.sublist(1).join('=').trim() : '';
    final color = CupertinoColors.systemGreen.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(TablerIcons.tag, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key.isEmpty ? label : key,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                  ),
                ),
                if (value.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
