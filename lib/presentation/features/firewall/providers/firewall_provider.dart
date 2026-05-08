import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../data/dto/firewall/firewall_base_info_dto.dart';
import '../../../../data/dto/firewall/rule_info_dto.dart';
import '../../../../data/repositories_impl/firewall_repository_impl.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../models/firewall_state.dart';

part 'firewall_provider.g.dart';

@Riverpod(dependencies: [firewallRepository, activeServerId])
Future<FirewallBaseInfoDto> firewallBaseInfo(Ref ref) async {
  final repo = await ref.watch(firewallRepositoryProvider.future);
  return repo.getBaseInfo();
}

@Riverpod(dependencies: [firewallRepository, activeServerId])
class FirewallPortRulesController extends _$FirewallPortRulesController {
  String _info = '';
  String _strategy = '';
  int _page = 1;
  int _refreshToken = 0;
  final int _pageSize = 50;

  @override
  Future<FirewallPortRulesState> build() async {
    return _load(watchRepository: true);
  }

  Future<FirewallPortRulesState> _load({bool watchRepository = false}) async {
    final repo = await (watchRepository
        ? ref.watch(firewallRepositoryProvider.future)
        : ref.read(firewallRepositoryProvider.future));
    final result = await repo.searchRules(
      type: 'port',
      page: _page,
      pageSize: _pageSize,
      info: _info,
      strategy: _strategy,
    );
    final rules = await _withListeningProcesses(result.items);
    return FirewallPortRulesState(
      rules: rules,
      total: result.total,
      page: _page,
      pageSize: _pageSize,
      info: _info,
      strategy: _strategy,
    );
  }

  Future<void> refresh({
    bool silent = false,
    Map<String, String> orderAliases = const {},
  }) async {
    final token = ++_refreshToken;
    final current = state;
    if (current.isLoading && !current.hasValue) {
      ref.invalidateSelf();
      try {
        await future;
      } catch (_) {}
      return;
    }

    final previousRules = silent ? current.valueOrNull?.rules : null;
    if (!silent && !current.isLoading) {
      state = const AsyncLoading<FirewallPortRulesState>().copyWithPrevious(
        current,
      );
    }
    final nextState = await AsyncValue.guard(() async {
      final next = await _load();
      if (previousRules == null || previousRules.isEmpty) return next;
      return next.copyWith(
        rules: _preserveRuleOrder(
          next.rules,
          previousRules,
          _portRuleOrderKey,
          orderAliases,
        ),
      );
    });
    if (token != _refreshToken) return;
    state = nextState;
  }

  Future<void> search({String? info, String? strategy}) async {
    _info = info ?? _info;
    _strategy = strategy ?? _strategy;
    _page = 1;
    await refresh();
  }

  Future<void> addRule(Map<String, dynamic> body) async {
    final repo = await ref.read(firewallRepositoryProvider.future);
    await repo.operatePortRule(body);
    await refresh(silent: true);
  }

  Future<void> removeRule(Map<String, dynamic> body) async {
    await removeRules([body]);
  }

  Future<void> removeRules(List<Map<String, dynamic>> rules) async {
    if (rules.isEmpty) return;
    final repo = await ref.read(firewallRepositoryProvider.future);
    await repo.batchOperate({'type': 'port', 'rules': rules});
    await refresh(silent: true);
  }

  Future<void> updateRule({
    required Map<String, dynamic> oldRule,
    required Map<String, dynamic> newRule,
  }) async {
    final repo = await ref.read(firewallRepositoryProvider.future);
    await repo.updatePortRule({'oldRule': oldRule, 'newRule': newRule});
    await refresh(
      silent: true,
      orderAliases: {_bodyPortOrderKey(newRule): _bodyPortOrderKey(oldRule)},
    );
  }

  Future<void> updateDescription(Map<String, dynamic> body) async {
    final repo = await ref.read(firewallRepositoryProvider.future);
    await repo.updateDescription(body);
    await refresh(silent: true);
  }

  Future<({int success, int failed})> importRules(
    List<Map<String, dynamic>> rules,
  ) async {
    final repo = await ref.read(firewallRepositoryProvider.future);
    var success = 0;
    var failed = 0;
    for (final rule in rules) {
      try {
        await repo.operatePortRule(rule);
        success++;
      } catch (_) {
        failed++;
      }
    }
    await refresh(silent: true);
    return (success: success, failed: failed);
  }

  Future<List<RuleInfoDto>> _withListeningProcesses(
    List<RuleInfoDto> rules,
  ) async {
    if (rules.isEmpty) return rules;
    final singlePortRules = rules.where(_canMatchListeningProcess).toList();
    if (singlePortRules.isEmpty) return rules;

    try {
      final repo = await ref.read(firewallRepositoryProvider.future);
      final processes = await repo.getListeningProcesses();
      return rules
          .map((rule) {
            if (!_canMatchListeningProcess(rule)) return rule;
            final port = int.tryParse(rule.port ?? '');
            if (port == null) return rule;
            Map<String, dynamic>? process;
            for (final item in processes) {
              if (_matchesListeningProcess(item, rule, port)) {
                process = item;
                break;
              }
            }
            if (process == null) return rule;
            final name = (process['Name'] ?? process['name'] ?? '').toString();
            return rule.copyWith(
              usedStatus: name.isEmpty
                  ? ref.read(appLocalizationsProvider).firewall_occupied
                  : name,
              processInfo: process,
            );
          })
          .toList(growable: false);
    } catch (_) {
      return rules;
    }
  }

  bool _canMatchListeningProcess(RuleInfoDto rule) {
    final port = rule.port ?? '';
    final protocol = rule.protocol ?? '';
    return port.isNotEmpty &&
        !port.contains('-') &&
        !port.contains(':') &&
        !port.contains(',') &&
        (protocol == 'tcp' || protocol == 'udp');
  }

  bool _matchesListeningProcess(
    Map<String, dynamic> process,
    RuleInfoDto rule,
    int port,
  ) {
    final protocol = rule.protocol ?? '';
    final procProtocol = process['Protocol'] ?? process['protocol'];
    if (!_protocolMatches(procProtocol, protocol)) return false;
    return _processPorts(
      process['Port'] ?? process['port'],
      protocol,
    ).contains(port);
  }

  bool _protocolMatches(dynamic value, String protocol) {
    if (value == null) return true;
    if (value is int) {
      return (protocol == 'tcp' && value == 1) ||
          (protocol == 'udp' && value == 2);
    }
    final text = value.toString().toLowerCase();
    if (text == '1') return protocol == 'tcp';
    if (text == '2') return protocol == 'udp';
    return text == protocol;
  }

  Set<int> _processPorts(dynamic value, String protocol) {
    final ports = <int>{};
    void add(dynamic item) {
      if (item is int) {
        ports.add(item);
      } else {
        final parsed = int.tryParse(item?.toString() ?? '');
        if (parsed != null) ports.add(parsed);
      }
    }

    if (value is Map) {
      final candidates = [
        value[protocol],
        value[protocol.toUpperCase()],
        value[protocol == 'tcp' ? '1' : '2'],
        value[protocol == 'tcp' ? 1 : 2],
      ];
      for (final candidate in candidates) {
        if (candidate is Iterable) {
          for (final item in candidate) {
            add(item);
          }
        } else {
          add(candidate);
        }
      }
      return ports;
    }
    if (value is Iterable) {
      for (final item in value) {
        add(item);
      }
    } else {
      add(value);
    }
    return ports;
  }
}

@Riverpod(dependencies: [firewallRepository, activeServerId])
class FirewallIpRulesController extends _$FirewallIpRulesController {
  String _info = '';
  String _strategy = '';
  int _page = 1;
  int _refreshToken = 0;
  final int _pageSize = 50;

  @override
  Future<FirewallIpRulesState> build() async {
    return _load(watchRepository: true);
  }

  Future<FirewallIpRulesState> _load({bool watchRepository = false}) async {
    final repo = await (watchRepository
        ? ref.watch(firewallRepositoryProvider.future)
        : ref.read(firewallRepositoryProvider.future));
    final result = await repo.searchRules(
      type: 'address',
      page: _page,
      pageSize: _pageSize,
      info: _info,
      strategy: _strategy,
    );
    return FirewallIpRulesState(
      rules: result.items,
      total: result.total,
      page: _page,
    );
  }

  Future<void> refresh({
    bool silent = false,
    Map<String, String> orderAliases = const {},
  }) async {
    final token = ++_refreshToken;
    final current = state;
    if (current.isLoading && !current.hasValue) {
      ref.invalidateSelf();
      try {
        await future;
      } catch (_) {}
      return;
    }

    final previousRules = silent ? current.valueOrNull?.rules : null;
    if (!silent && !current.isLoading) {
      state = const AsyncLoading<FirewallIpRulesState>().copyWithPrevious(
        current,
      );
    }
    final nextState = await AsyncValue.guard(() async {
      final next = await _load();
      if (previousRules == null || previousRules.isEmpty) return next;
      return next.copyWith(
        rules: _preserveRuleOrder(
          next.rules,
          previousRules,
          _ipRuleOrderKey,
          orderAliases,
        ),
      );
    });
    if (token != _refreshToken) return;
    state = nextState;
  }

  Future<void> search({String? info, String? strategy}) async {
    _info = info ?? _info;
    _strategy = strategy ?? _strategy;
    _page = 1;
    await refresh();
  }

  Future<void> addRule(Map<String, dynamic> body) async {
    final repo = await ref.read(firewallRepositoryProvider.future);
    await repo.operateIpRule(body);
    await refresh(silent: true);
  }

  Future<void> removeRule(Map<String, dynamic> body) async {
    final repo = await ref.read(firewallRepositoryProvider.future);
    await repo.batchOperate({
      'type': 'address',
      'rules': [body],
    });
    await refresh(silent: true);
  }

  Future<void> updateRule({
    required Map<String, dynamic> oldRule,
    required Map<String, dynamic> newRule,
  }) async {
    final repo = await ref.read(firewallRepositoryProvider.future);
    await repo.updateAddrRule({'oldRule': oldRule, 'newRule': newRule});
    await refresh(
      silent: true,
      orderAliases: {_bodyIpOrderKey(newRule): _bodyIpOrderKey(oldRule)},
    );
  }
}

List<RuleInfoDto> _preserveRuleOrder(
  List<RuleInfoDto> next,
  List<RuleInfoDto> previous,
  String Function(RuleInfoDto rule) keyOf,
  Map<String, String> aliases,
) {
  final order = <String, int>{};
  for (var i = 0; i < previous.length; i++) {
    order[keyOf(previous[i])] = i;
  }

  int rank(RuleInfoDto rule, int index) {
    final key = keyOf(rule);
    final alias = aliases[key];
    return order[key] ??
        (alias == null ? null : order[alias]) ??
        previous.length + index;
  }

  final indexed = [
    for (var i = 0; i < next.length; i++) (index: i, rule: next[i]),
  ];
  indexed.sort(
    (a, b) => rank(a.rule, a.index).compareTo(rank(b.rule, b.index)),
  );
  return indexed.map((item) => item.rule).toList(growable: false);
}

String _portRuleOrderKey(RuleInfoDto rule) => [
  rule.chain ?? '',
  _normalizeRuleAddress(rule.address ?? ''),
  rule.port ?? '',
  rule.protocol ?? '',
].join('|');

String _ipRuleOrderKey(RuleInfoDto rule) =>
    _normalizeRuleAddress(rule.address ?? '');

String _bodyPortOrderKey(Map<String, dynamic> body) => [
  body['chain']?.toString() ?? '',
  _normalizeRuleAddress(body['address']?.toString() ?? ''),
  body['port']?.toString() ?? '',
  body['protocol']?.toString() ?? '',
].join('|');

String _bodyIpOrderKey(Map<String, dynamic> body) =>
    _normalizeRuleAddress(body['address']?.toString() ?? '');

String _normalizeRuleAddress(String address) {
  final value = address.trim();
  if (value.isEmpty ||
      value == 'Anywhere' ||
      value == '0.0.0.0/0' ||
      value == '::/0') {
    return 'Anywhere';
  }
  return value;
}
