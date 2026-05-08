import '../../../../data/dto/firewall/firewall_base_info_dto.dart';
import '../../../../data/dto/firewall/rule_info_dto.dart';

class FirewallState {
  const FirewallState({
    this.baseInfo,
    this.isBaseLoading = false,
    this.baseError,
  });

  final FirewallBaseInfoDto? baseInfo;
  final bool isBaseLoading;
  final Object? baseError;

  FirewallState copyWith({
    FirewallBaseInfoDto? baseInfo,
    bool? isBaseLoading,
    Object? baseError,
  }) {
    return FirewallState(
      baseInfo: baseInfo ?? this.baseInfo,
      isBaseLoading: isBaseLoading ?? this.isBaseLoading,
      baseError: baseError,
    );
  }
}

class FirewallPortRulesState {
  const FirewallPortRulesState({
    this.rules = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 50,
    this.info = '',
    this.strategy = '',
    this.isLoading = false,
    this.error,
  });

  final List<RuleInfoDto> rules;
  final int total;
  final int page;
  final int pageSize;
  final String info;
  final String strategy;
  final bool isLoading;
  final Object? error;

  FirewallPortRulesState copyWith({
    List<RuleInfoDto>? rules,
    int? total,
    int? page,
    int? pageSize,
    String? info,
    String? strategy,
    bool? isLoading,
    Object? error,
  }) {
    return FirewallPortRulesState(
      rules: rules ?? this.rules,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      info: info ?? this.info,
      strategy: strategy ?? this.strategy,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FirewallIpRulesState {
  const FirewallIpRulesState({
    this.rules = const [],
    this.total = 0,
    this.page = 1,
    this.isLoading = false,
    this.error,
  });

  final List<RuleInfoDto> rules;
  final int total;
  final int page;
  final bool isLoading;
  final Object? error;

  FirewallIpRulesState copyWith({
    List<RuleInfoDto>? rules,
    int? total,
    int? page,
    bool? isLoading,
    Object? error,
  }) {
    return FirewallIpRulesState(
      rules: rules ?? this.rules,
      total: total ?? this.total,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
