import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/network/api_response_parser.dart';
import '../../core/network/app_user_agent.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/web_socket_connector.dart';

/// 进程管理 API（对应 1Panel `/process` 相关接口）。
class ProcessApi {
  ProcessApi(this._client);

  final DioClient _client;

  /// POST /api/v2/process/stop
  Future<void> stopProcess(int pid) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/process/stop',
      data: {'PID': pid},
    );
  }

  /// GET /api/v2/process/:pid
  Future<Map<String, dynamic>> getProcessByPID(int pid) async {
    final resp = await _client.get<dynamic>('/api/v2/process/$pid');
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/process/listening
  Future<List<Map<String, dynamic>>> getListeningProcesses() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/process/listening',
    );
    final data = ApiResponseParser.primitive<List<dynamic>>(resp);
    return data
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);
  }

  /// WebSocket /api/v2/process/ws?operateNode=...
  static Future<WebSocketChannel> connectProcessWebSocket({
    required String baseUrl,
    required String apiKey,
    bool allowInsecureConnections = false,
    String? operateNode = 'local',
  }) async {
    final uri = Uri.parse(baseUrl);
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final token = md5
        .convert(utf8.encode('1panel$apiKey$timestamp'))
        .toString();
    final wsUrl = Uri(
      scheme: uri.scheme == 'https' ? 'wss' : 'ws',
      host: uri.host,
      port: uri.port,
      path: '${uri.path}/api/v2/process/ws'.replaceAll('//', '/'),
      queryParameters: operateNode == null
          ? null
          : {'operateNode': operateNode},
    );
    final userAgent = await AppUserAgent.value;

    return connectAppWebSocket(
      wsUrl,
      headers: {
        '1Panel-Token': token,
        '1Panel-Timestamp': timestamp,
        HttpHeaders.userAgentHeader: userAgent,
      },
      allowInsecureConnections: allowInsecureConnections,
    );
  }
}
