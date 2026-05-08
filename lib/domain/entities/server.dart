import 'package:isar/isar.dart';

part 'server.g.dart';

@collection
class Server {
  Id id = Isar.autoIncrement;

  String? name;

  late String host;

  late int port;

  bool isHttps = false;

  bool allowInsecureConnections = false;

  int sortIndex = 0;

  DateTime? createdAt;

  DateTime? lastUsedAt;

  @ignore
  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    return '$host:$port';
  }

  @ignore
  Uri get baseUrl {
    final scheme = isHttps ? 'https' : 'http';
    return Uri.parse('$scheme://$host:$port');
  }
}
