import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel connectAppWebSocket(
  Uri url, {
  Map<String, dynamic>? headers,
  bool allowInsecureConnections = false,
}) {
  final client = allowInsecureConnections
      ? (HttpClient()..badCertificateCallback = (_, _, _) => true)
      : null;

  final socket = WebSocket.connect(
    url.toString(),
    headers: headers,
    customClient: client,
  ).whenComplete(() => client?.close(force: true));

  return IOWebSocketChannel(socket);
}
