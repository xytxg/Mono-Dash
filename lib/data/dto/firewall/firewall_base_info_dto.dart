class FirewallBaseInfoDto {
  const FirewallBaseInfoDto({
    required this.name,
    required this.isExist,
    required this.isActive,
    required this.isInit,
    required this.isBind,
    required this.version,
    required this.pingStatus,
  });

  factory FirewallBaseInfoDto.fromJson(Map<String, dynamic> json) {
    return FirewallBaseInfoDto(
      name: json['name'] as String? ?? '',
      isExist: json['isExist'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
      isInit: json['isInit'] as bool? ?? false,
      isBind: json['isBind'] as bool? ?? false,
      version: json['version'] as String? ?? '',
      pingStatus: json['pingStatus'] as String? ?? 'Disable',
    );
  }

  final String name;
  final bool isExist;
  final bool isActive;
  final bool isInit;
  final bool isBind;
  final String version;
  final String pingStatus;

  bool get isPingEnabled => pingStatus == 'Enable';
}
