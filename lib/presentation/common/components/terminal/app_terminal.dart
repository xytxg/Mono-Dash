import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xterm/xterm.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/network/app_user_agent.dart';
import '../../../../core/network/web_socket_connector.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/storage_service.dart';
import '../frosted_header.dart';
import '../frosted_overlay_menu.dart';
import '../../../features/server_detail/providers/active_server_provider.dart';

Future<void> showAppTerminal(
  BuildContext context, {
  required String containerId,
  String user = 'root',
  required String command,
  String source = 'container',
  String? databaseType,
  String? databaseName,
}) {
  final container = ProviderScope.containerOf(context);
  return Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => UncontrolledProviderScope(
        container: container,
        child: _AppTerminalScreen(
          containerId: containerId,
          user: user,
          command: command,
          source: source,
          databaseType: databaseType,
          databaseName: databaseName,
        ),
      ),
    ),
  );
}

class _AppTerminalScreen extends ConsumerStatefulWidget {
  const _AppTerminalScreen({
    required this.containerId,
    required this.user,
    required this.command,
    required this.source,
    this.databaseType,
    this.databaseName,
  });

  final String containerId;
  final String user;
  final String command;
  final String source;
  final String? databaseType;
  final String? databaseName;

  @override
  ConsumerState<_AppTerminalScreen> createState() => _AppTerminalScreenState();
}

class _AppTerminalScreenState extends ConsumerState<_AppTerminalScreen> {
  late final Terminal _terminal;
  final TerminalController _terminalController = TerminalController();
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _terminal = Terminal(maxLines: 10000);
    _connect();
  }

  Future<void> _connect() async {
    final l10n = ref.read(appLocalizationsProvider);
    try {
      final serverId = ref.read(activeServerIdProvider);
      final storage = ref.read(storageServiceProvider);
      final server = await storage.getServer(serverId);
      final apiKey = await storage.getApiKey(serverId) ?? '';

      if (server == null) {
        if (!mounted) return;
        setState(() {
          _statusMessage = l10n.terminal_serverInfoFailed;
        });
        return;
      }

      final baseUrl = server.baseUrl.toString();
      final uri = Uri.parse(baseUrl);
      final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';

      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();
      final tokenRaw = '1panel$apiKey$timestamp';
      final token = md5.convert(utf8.encode(tokenRaw)).toString();
      final userAgent = await AppUserAgent.value;

      final isDatabase = widget.source == 'database';
      final isRedis =
          isDatabase && (widget.databaseType?.contains('redis') ?? false);
      final wsUrl = Uri(
        scheme: wsScheme,
        host: uri.host,
        port: uri.port,
        path: widget.source == 'host'
            ? '${uri.path}/api/v2/hosts/terminal'.replaceAll('//', '/')
            : '${uri.path}/api/v2/containers/exec'.replaceAll('//', '/'),
        queryParameters: {
          'cols': _terminal.viewWidth.toString(),
          'rows': _terminal.viewHeight.toString(),
          if (isRedis) ...{
            'source': 'redis',
            'name': widget.databaseName ?? '',
            'from': 'local',
          } else if (isDatabase) ...{
            'source': 'database',
            'databaseType': widget.databaseType ?? '',
            'database': widget.databaseName ?? '',
          } else ...{
            'source': widget.source,
            'containerid': widget.containerId,
            'user': widget.user,
            'command': widget.command,
          },
          'operateNode': 'local',
        },
      );

      _channel = connectAppWebSocket(
        wsUrl,
        headers: {
          '1Panel-Token': token,
          '1Panel-Timestamp': timestamp,
          HttpHeaders.userAgentHeader: userAgent,
        },
        allowInsecureConnections: server.allowInsecureConnections,
      );

      _subscription = _channel!.stream.listen(
        (data) {
          if (!_isConnected) {
            if (!mounted) return;
            setState(() {
              _isConnected = true;
              _statusMessage = '';
            });
          }

          try {
            final Map<String, dynamic> msg = jsonDecode(data.toString());
            final type = msg['type'];
            final payload = msg['data'];

            if (type == 'cmd' && payload is String) {
              final decoded = utf8.decode(
                base64Decode(payload),
                allowMalformed: true,
              );
              _terminal.write(decoded);
            }
          } catch (e) {
            // If not JSON or other error, fallback to raw write if it's a string
            if (data is String) {
              _terminal.write(data);
            }
          }
        },
        onError: (e) {
          _terminal.write(
            '\r\n${l10n.terminal_connectionErrorWithDetail('$e')}\r\n',
          );
          if (!mounted) return;
          setState(() {
            _isConnected = false;
            _statusMessage = l10n.terminal_connectionError;
          });
        },
        onDone: () {
          _terminal.write('\r\n${l10n.terminal_disconnectedOutput}\r\n');
          if (!mounted) return;
          setState(() {
            _isConnected = false;
            _statusMessage = l10n.terminal_disconnected;
          });
        },
      );

      _terminal.onOutput = (data) {
        if (_isConnected) {
          final payload = jsonEncode({
            'type': 'cmd',
            'data': base64Encode(utf8.encode(data)),
          });
          _channel?.sink.add(payload);
        }
      };

      _terminal.onResize = (w, h, pw, ph) {
        if (_isConnected) {
          final payload = jsonEncode({'type': 'resize', 'cols': w, 'rows': h});
          _channel?.sink.add(payload);
        }
      };
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = l10n.terminal_initializationFailed('$e');
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    _terminalController.dispose();
    super.dispose();
  }

  Future<void> _copySelectionOrAll() async {
    final selection = _terminalController.selection;
    final text = selection != null
        ? _terminal.buffer.getText(selection)
        : _terminal.buffer.getText();
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    _terminal.paste(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    // 明亮模式下终端配色
    final brightTheme = TerminalTheme(
      cursor: const Color(0xFF000000),
      selection: const Color(0x44000000),
      foreground: const Color(0xFF000000),
      background: AppColors.background(context),
      black: const Color(0xFF000000),
      red: const Color(0xFFCD3131),
      green: const Color(0xFF0DBC79),
      yellow: const Color(0xFF949400),
      blue: const Color(0xFF0451A5),
      magenta: const Color(0xFFBC05BC),
      cyan: const Color(0xFF0598BC),
      white: const Color(0xFF555555),
      brightBlack: const Color(0xFF666666),
      brightRed: const Color(0xFFCD3131),
      brightGreen: const Color(0xFF14CE14),
      brightYellow: const Color(0xFFB5BA00),
      brightBlue: const Color(0xFF0451A5),
      brightMagenta: const Color(0xFFBC05BC),
      brightCyan: const Color(0xFF0598BC),
      brightWhite: const Color(0xFFA5A5A5),
      searchHitBackground: const Color(0xFFFFFF00),
      searchHitBackgroundCurrent: const Color(0xFFFF9600),
      searchHitForeground: const Color(0xFF000000),
    );

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top:
                  MediaQuery.paddingOf(context).top +
                  FrostedHeader.headerHeight,
            ),
            child: Column(
              children: [
                if (!_isConnected && _statusMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: CupertinoColors.systemRed.withValues(alpha: 0.2),
                    child: Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CupertinoColors.systemRed,
                        fontSize: 13,
                      ),
                    ),
                  ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: TerminalView(
                        _terminal,
                        controller: _terminalController,
                        textStyle: const TerminalStyle(
                          fontSize: 14,
                          fontFamily: 'Menlo',
                        ),
                        theme: isDark
                            ? TerminalThemes.defaultTheme
                            : brightTheme,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FrostedHeader(
              title: widget.source == 'host'
                  ? context.l10n.terminal_hostTitle
                  : widget.source == 'database'
                  ? context.l10n.terminal_databaseTitle(
                      widget.databaseName ?? '',
                    )
                  : context.l10n.terminal_containerTitle(widget.containerId),
              onBack: () => Navigator.of(context).maybePop(),
              trailingBuilder: (isDark, isOverlapping) =>
                  FrostedOverlayMenuButton(
                    label: _isConnected
                        ? context.l10n.common_menu
                        : context.l10n.terminal_connecting,
                    isDark: isDark,
                    isOverlapping: isOverlapping,
                    items: [
                      FrostedMenuItem(
                        text: context.l10n.terminal_copySelection,
                        icon: CupertinoIcons.doc_on_doc,
                        action: _copySelectionOrAll,
                      ),
                      FrostedMenuItem(
                        text: context.l10n.terminal_pasteToTerminal,
                        icon: CupertinoIcons.doc_on_clipboard,
                        action: _pasteFromClipboard,
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
