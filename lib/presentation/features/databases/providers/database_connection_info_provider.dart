/// 连接信息数据模型。
class ConnectionInfoState {
  const ConnectionInfoState({
    this.containerName = '',
    this.port = '',
    this.password = '',
    this.isRunning = false,
    this.systemIP = '',
    this.remoteAccess = false,
    this.remoteAddress = '',
    this.remotePort = '',
    this.remoteUsername = '',
    this.remotePassword = '',
    required this.isRemote,
  });

  final String containerName;
  final String port;
  final String password;
  final bool isRunning;
  final String systemIP;
  final bool remoteAccess;
  final String remoteAddress;
  final String remotePort;
  final String remoteUsername;
  final String remotePassword;
  final bool isRemote;
 
  ConnectionInfoState copyWith({
    String? containerName,
    String? port,
    String? password,
    bool? isRunning,
    String? systemIP,
    bool? remoteAccess,
    String? remoteAddress,
    String? remotePort,
    String? remoteUsername,
    String? remotePassword,
    bool? isRemote,
  }) {
    return ConnectionInfoState(
      containerName: containerName ?? this.containerName,
      port: port ?? this.port,
      password: password ?? this.password,
      isRunning: isRunning ?? this.isRunning,
      systemIP: systemIP ?? this.systemIP,
      remoteAccess: remoteAccess ?? this.remoteAccess,
      remoteAddress: remoteAddress ?? this.remoteAddress,
      remotePort: remotePort ?? this.remotePort,
      remoteUsername: remoteUsername ?? this.remoteUsername,
      remotePassword: remotePassword ?? this.remotePassword,
      isRemote: isRemote ?? this.isRemote,
    );
  }
}
