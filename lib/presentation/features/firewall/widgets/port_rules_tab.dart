import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/firewall/firewall_base_info_dto.dart';
import '../../../../data/dto/firewall/rule_info_dto.dart';
import '../../../../data/repositories_impl/firewall_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/skeleton_item.dart';
import '../../process/widgets/process_detail_sheet.dart';
import '../providers/firewall_provider.dart';
import 'port_rule_form_sheet.dart';

part 'port_rules_tab_actions.dart';
part 'port_rules_tab_cards.dart';
part 'port_rules_tab_import.dart';

class PortRulesTab extends ConsumerStatefulWidget {
  const PortRulesTab({super.key, required this.baseInfo, this.controller});

  final FirewallBaseInfoDto? baseInfo;
  final PortRulesTabController? controller;

  @override
  ConsumerState<PortRulesTab> createState() => _PortRulesTabState();
}

class PortRulesTabController extends ChangeNotifier {
  _PortRulesTabDelegate? _delegate;

  bool selectionMode = false;
  int selectedCount = 0;
  int totalCount = 0;
  bool canExport = false;
  bool canDeleteSelected = false;
  bool importing = false;
  bool exporting = false;

  void createRule() => _delegate?.createRule();

  void importRules() => _delegate?.importRules();

  void exportSelected() => _delegate?.exportSelected();

  void deleteSelected() => _delegate?.deleteSelected();

  void selectAll() => _delegate?.selectAll();

  void toggleSelectionMode() => _delegate?.toggleSelectionMode();

  void clearSelection() => _delegate?.clearSelection();

  void _attach(_PortRulesTabDelegate delegate) {
    _delegate = delegate;
  }

  void _detach(_PortRulesTabDelegate delegate) {
    if (_delegate == delegate) _delegate = null;
  }

  void _sync({
    required bool selectionMode,
    required int selectedCount,
    required int totalCount,
    required bool canExport,
    required bool importing,
    required bool exporting,
  }) {
    final nextCanDeleteSelected = selectedCount > 0;
    if (this.selectionMode == selectionMode &&
        this.selectedCount == selectedCount &&
        this.totalCount == totalCount &&
        this.canExport == canExport &&
        canDeleteSelected == nextCanDeleteSelected &&
        this.importing == importing &&
        this.exporting == exporting) {
      return;
    }

    this.selectionMode = selectionMode;
    this.selectedCount = selectedCount;
    this.totalCount = totalCount;
    this.canExport = canExport;
    canDeleteSelected = nextCanDeleteSelected;
    this.importing = importing;
    this.exporting = exporting;
    notifyListeners();
  }
}

abstract interface class _PortRulesTabDelegate {
  void createRule();

  void importRules();

  void exportSelected();

  void deleteSelected();

  void selectAll();

  void toggleSelectionMode();

  void clearSelection();
}

class _PortRulesTabState extends ConsumerState<PortRulesTab> {
  final _selectedKeys = <String>{};
  bool _selectionMode = false;
  bool _exporting = false;
  bool _importing = false;

  bool get _canOperate {
    final info = widget.baseInfo;
    if (info == null) return false;
    final needsBind = info.name.toLowerCase() == 'iptables';
    return info.isExist &&
        info.isInit &&
        info.isActive &&
        (!needsBind || info.isBind);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_ControllerDelegate(this));
  }

  @override
  void didUpdateWidget(covariant PortRulesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._delegate = null;
      widget.controller?._attach(_ControllerDelegate(this));
    }
  }

  @override
  void dispose() {
    final delegate = widget.controller?._delegate;
    if (delegate is _ControllerDelegate && delegate.state == this) {
      widget.controller?._detach(delegate);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseInfo = widget.baseInfo;
    if (baseInfo == null) return _buildLoading(context);
    if (!_canOperate) return _buildBlocked(context, baseInfo);

    final state = ref.watch(firewallPortRulesControllerProvider);
    return state.when(
      loading: () => _buildLoading(context),
      error: (e, _) => _buildError(context, e),
      data: (data) {
        final rules = data.rules;
        _dropStaleSelections(rules);
        _syncControllerAfterBuild(rules);
        return rules.isEmpty
            ? _buildEmpty(context)
            : _buildRuleList(context, rules);
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.separator(context).withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const SkeletonItem.text(
                      width: 30,
                      height: 30,
                      borderRadius: 9,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonItem.text(
                            width: 116 + (i % 2) * 34,
                            height: 18,
                          ),
                          const SizedBox(height: 7),
                          SkeletonItem.text(
                            width: 92 + (i % 3) * 22,
                            height: 11,
                          ),
                        ],
                      ),
                    ),
                    const SkeletonItem.text(
                      width: 54,
                      height: 22,
                      borderRadius: 8,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    height: 0.5,
                    color: AppColors.separator(context).withValues(alpha: 0.1),
                  ),
                ),
                const SkeletonItem.text(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                SkeletonItem.text(width: 220 + (i % 2) * 32, height: 12),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBlocked(BuildContext context, FirewallBaseInfoDto info) {
    final title = !info.isExist
        ? context.l10n.firewall_notDetected
        : !info.isInit
        ? context.l10n.firewall_notInitialized
        : !info.isActive
        ? context.l10n.firewall_notStarted
        : context.l10n.firewall_basicChainUnbound;
    final subtitle = !info.isActive
        ? context.l10n.firewall_portRulesNeedActive
        : info.name.toLowerCase() == 'iptables' && !info.isBind
        ? context.l10n.firewall_iptablesUnboundSubtitle
        : context.l10n.firewall_initializeFirst;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: AppEmptyState(
        icon: TablerIcons.shield_x,
        title: title,
        subtitle: subtitle,
        actionLabel: context.l10n.firewall_refreshStatus,
        onAction: () => ref.invalidate(firewallBaseInfoProvider),
        useCardStyle: false,
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: AppEmptyState(
        icon: TablerIcons.alert_circle,
        title: context.l10n.common_loadingFailed,
        subtitle: error.toString(),
        actionLabel: context.l10n.common_retry,
        onAction: () =>
            ref.read(firewallPortRulesControllerProvider.notifier).refresh(),
        useCardStyle: false,
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return AppEmptyState(
      icon: TablerIcons.plug_off,
      title: context.l10n.firewall_noPortRules,
      subtitle: context.l10n.firewall_noPortRulesSubtitle,
      actionLabel: context.l10n.firewall_createRule,
      onAction: _createRule,
      useCardStyle: false,
    );
  }

  Widget _buildRuleList(BuildContext context, List<RuleInfoDto> rules) {
    return Column(
      children: rules.map((rule) {
        final key = _ruleKey(rule);
        final selected = _selectedKeys.contains(key);
        return _PortRuleCard(
          rule: rule,
          selectionMode: _selectionMode,
          selected: selected,
          onTap: () {
            if (_selectionMode) {
              _toggleSelected(key);
            } else {
              _showRuleActions(rule);
            }
          },
          onSelect: () => _toggleSelected(key),
          onProcessTap: rule.processInfo == null
              ? null
              : () => _showProcess(rule.processInfo!),
        );
      }).toList(),
    );
  }

  Future<void> _createRule() async {
    await showPortRuleFormSheet(context);
  }

  Future<void> _editRule(RuleInfoDto rule) async {
    await showPortRuleFormSheet(context, existingRule: rule);
  }

  Future<void> _toggleStrategy(RuleInfoDto rule) async {
    final l10n = context.l10n;
    final next = rule.isAccept ? 'drop' : 'accept';
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: l10n.firewall_switchStrategyTitle,
        content: l10n.firewall_switchPortStrategyContent(
          rule.port ?? '-',
          next.toUpperCase(),
        ),
        confirmText: l10n.firewall_switchAction,
        confirmColor: next == 'accept'
            ? CupertinoColors.systemGreen
            : CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(firewallPortRulesControllerProvider.notifier)
          .updateRule(
            oldRule: rule.toPortRuleJson(operation: 'remove'),
            newRule: rule
                .copyWith(strategy: next)
                .toPortRuleJson(operation: 'add'),
          );
      showAppSuccessToast(l10n.firewall_strategyUpdated);
    } catch (e) {
      showAppErrorToast(l10n.firewall_strategyUpdateFailed, description: '$e');
    }
  }

  Future<void> _deleteRule(RuleInfoDto rule) async {
    final l10n = context.l10n;
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: l10n.firewall_deletePortRule,
        content: l10n.firewall_deletePortRuleContent(
          rule.port ?? '-',
          rule.displayProtocol,
        ),
        confirmText: l10n.common_delete,
        confirmColor: CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(firewallPortRulesControllerProvider.notifier)
          .removeRule(rule.toPortRuleJson(operation: 'remove'));
      _selectedKeys.remove(_ruleKey(rule));
      _syncController(_currentRules);
      showAppSuccessToast(l10n.firewall_ruleDeleted);
    } catch (e) {
      showAppErrorToast(l10n.firewall_deleteFailed, description: '$e');
    }
  }

  Future<void> _deleteSelected(List<RuleInfoDto> rules) async {
    final l10n = context.l10n;
    final selected = rules
        .where((rule) => _selectedKeys.contains(_ruleKey(rule)))
        .toList(growable: false);
    if (selected.isEmpty) return;
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: l10n.firewall_batchDeleteTitle,
        content: l10n.firewall_batchDeleteContent(selected.length),
        confirmText: l10n.common_delete,
        confirmColor: CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(firewallPortRulesControllerProvider.notifier)
          .removeRules(
            selected
                .map((rule) => rule.toPortRuleJson(operation: 'remove'))
                .toList(growable: false),
          );
      setState(() {
        _selectedKeys.clear();
        _selectionMode = false;
      });
      _syncController(_currentRules);
      showAppSuccessToast(l10n.firewall_batchDeleteSubmitted);
    } catch (e) {
      showAppErrorToast(l10n.firewall_batchDeleteFailed, description: '$e');
    }
  }

  Future<void> _exportRules(List<RuleInfoDto> rules) async {
    final l10n = context.l10n;
    final selected = rules
        .where((rule) => _selectedKeys.contains(_ruleKey(rule)))
        .toList(growable: false);
    if (selected.isEmpty) {
      showAppWarningToast(l10n.firewall_selectRulesToExport);
      setState(() => _selectionMode = true);
      _syncController(rules);
      return;
    }

    setState(() => _exporting = true);
    _syncController(rules);
    try {
      final data = selected
          .map(
            (rule) => {
              'family': rule.family ?? '',
              'address': rule.isAnyAddress ? '' : (rule.address ?? ''),
              'port': rule.port ?? '',
              'protocol': rule.protocol ?? '',
              'strategy': rule.strategy ?? '',
              'description': rule.description ?? '',
            },
          )
          .toList(growable: false);
      final fileName = '1panel-firewall-port-${_timestamp()}.json';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );
      await SharePlus.instance.share(
        ShareParams(
          title: fileName,
          subject: fileName,
          files: [XFile(file.path, mimeType: 'application/json')],
          fileNameOverrides: [fileName],
        ),
      );
    } on MissingPluginException {
      showAppErrorToast(
        l10n.taskLog_sharePluginMissing,
        description: l10n.taskLog_sharePluginMissingDescription,
      );
    } catch (e) {
      showAppErrorToast(l10n.firewall_exportFailed, description: '$e');
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
        _syncController(_currentRules);
      }
    }
  }

  Future<void> _importRules() async {
    final l10n = context.l10n;
    setState(() => _importing = true);
    _syncController(_currentRules);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.single;
      final content = file.bytes != null
          ? utf8.decode(file.bytes!)
          : await File(file.path!).readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! List) {
        showAppErrorToast(
          l10n.firewall_importFailed,
          description: l10n.firewall_jsonRootMustBeArray,
        );
        return;
      }

      final repo = await ref.read(firewallRepositoryProvider.future);
      final existing = await repo.searchRules(
        type: 'port',
        page: 1,
        pageSize: 10000,
      );
      final candidates = _buildImportCandidates(decoded, existing.items);
      if (!mounted) return;
      await showActionSheet<void>(
        context: context,
        builder: (_) => _ImportPreviewSheet(candidates: candidates),
      );
    } catch (e) {
      showAppErrorToast(l10n.firewall_importFailed, description: '$e');
    } finally {
      if (mounted) {
        setState(() => _importing = false);
        _syncController(_currentRules);
      }
    }
  }

  List<_ImportCandidate> _buildImportCandidates(
    List<dynamic> raw,
    List<RuleInfoDto> existing,
  ) {
    final exactKeys = existing.map(_ruleCompareKey).toSet();
    final strategyByIdentity = {
      for (final rule in existing) _ruleIdentityKey(rule): rule.strategy ?? '',
    };

    return raw
        .map((item) {
          if (item is! Map) {
            return _ImportCandidate.invalid(
              context.l10n.firewall_importItemNotObject,
            );
          }
          final json = item.cast<String, dynamic>();
          final port = (json['port'] ?? '').toString().trim();
          final protocol = (json['protocol'] ?? '').toString().trim();
          final strategy = (json['strategy'] ?? '').toString().trim();
          final address = (json['address'] ?? '').toString().trim();
          final description = (json['description'] ?? '').toString();
          if (port.isEmpty || protocol.isEmpty || strategy.isEmpty) {
            return _ImportCandidate.invalid(
              context.l10n.firewall_missingPortProtocolStrategy,
            );
          }
          if (!const {'tcp', 'udp', 'tcp/udp'}.contains(protocol)) {
            return _ImportCandidate.invalid(
              context.l10n.firewall_unsupportedProtocol(protocol),
            );
          }
          if (!const {'accept', 'drop'}.contains(strategy)) {
            return _ImportCandidate.invalid(
              context.l10n.firewall_unsupportedStrategy(strategy),
            );
          }

          final body = {
            'operation': 'add',
            'address': _isAnyAddress(address) ? '' : address,
            'port': port,
            'protocol': protocol,
            'strategy': strategy,
            'description': description,
          };
          final compareKey = _bodyCompareKey(body);
          if (exactKeys.contains(compareKey)) {
            return _ImportCandidate(
              body: body,
              status: _ImportStatus.duplicate,
            );
          }
          final existingStrategy = strategyByIdentity[_bodyIdentityKey(body)];
          if (existingStrategy != null && existingStrategy != strategy) {
            return _ImportCandidate(
              body: body,
              status: _ImportStatus.conflict,
              existingStrategy: existingStrategy,
            );
          }
          return _ImportCandidate(body: body, status: _ImportStatus.newRule);
        })
        .toList(growable: false);
  }

  void _showRuleActions(RuleInfoDto rule) {
    showActionSheet<void>(
      context: context,
      builder: (_) => _PortRuleActionSheet(
        rule: rule,
        onEdit: () => _editRule(rule),
        onToggleStrategy: () => _toggleStrategy(rule),
        onDelete: () => _deleteRule(rule),
        onShowProcess: rule.processInfo == null
            ? null
            : () => _showProcess(rule.processInfo!),
      ),
    );
  }

  void _showProcess(Map<String, dynamic> process) {
    final pid = int.tryParse(
      (process['PID'] ?? process['pid'] ?? '').toString(),
    );
    if (pid == null) return;
    final name = (process['Name'] ?? process['name'] ?? '').toString();
    showProcessDetailSheet(
      context,
      pid: pid,
      ref: ref,
      summary: {...process, 'name': name},
    );
  }

  void _toggleSelected(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
      _selectionMode = _selectionMode || _selectedKeys.isNotEmpty;
      _syncController(_currentRules);
    });
  }

  void _dropStaleSelections(List<RuleInfoDto> rules) {
    final keys = rules.map(_ruleKey).toSet();
    _selectedKeys.removeWhere((key) => !keys.contains(key));
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) _selectedKeys.clear();
      _syncController(_currentRules);
    });
  }

  void _selectAll() {
    final rules = _currentRules;
    if (rules.isEmpty) return;
    setState(() {
      _selectionMode = true;
      _selectedKeys
        ..clear()
        ..addAll(rules.map(_ruleKey));
      _syncController(rules);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectionMode = false;
      _selectedKeys.clear();
      _syncController(_currentRules);
    });
  }

  List<RuleInfoDto> get _currentRules =>
      ref.read(firewallPortRulesControllerProvider).valueOrNull?.rules ??
      const <RuleInfoDto>[];

  void _syncController(List<RuleInfoDto> rules) {
    widget.controller?._sync(
      selectionMode: _selectionMode,
      selectedCount: _selectedKeys.length,
      totalCount: rules.length,
      canExport: rules.isNotEmpty,
      importing: _importing,
      exporting: _exporting,
    );
  }

  void _syncControllerAfterBuild(List<RuleInfoDto> rules) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncController(rules);
    });
  }

  String _ruleKey(RuleInfoDto rule) =>
      '${rule.chain}|${rule.address}|${rule.port}|${rule.protocol}|${rule.strategy}';

  String _ruleCompareKey(RuleInfoDto rule) =>
      '${_normalizeAddress(rule.address ?? '')}:${rule.port}:${rule.protocol}:${rule.strategy}';

  String _ruleIdentityKey(RuleInfoDto rule) =>
      '${_normalizeAddress(rule.address ?? '')}:${rule.port}:${rule.protocol}';

  String _bodyCompareKey(Map<String, dynamic> body) =>
      '${_normalizeAddress(body['address']?.toString() ?? '')}:${body['port']}:${body['protocol']}:${body['strategy']}';

  String _bodyIdentityKey(Map<String, dynamic> body) =>
      '${_normalizeAddress(body['address']?.toString() ?? '')}:${body['port']}:${body['protocol']}';

  String _normalizeAddress(String address) =>
      _isAnyAddress(address) ? 'Anywhere' : address.trim();

  bool _isAnyAddress(String address) =>
      address.isEmpty ||
      address == 'Anywhere' ||
      address == '0.0.0.0/0' ||
      address == '::/0';

  String _timestamp() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }
}

class _ControllerDelegate implements _PortRulesTabDelegate {
  const _ControllerDelegate(this.state);

  final _PortRulesTabState state;

  @override
  void clearSelection() => state._clearSelection();

  @override
  void createRule() => state._createRule();

  @override
  void deleteSelected() => state._deleteSelected(state._currentRules);

  @override
  void exportSelected() => state._exportRules(state._currentRules);

  @override
  void importRules() => state._importRules();

  @override
  void selectAll() => state._selectAll();

  @override
  void toggleSelectionMode() => state._toggleSelectionMode();
}
