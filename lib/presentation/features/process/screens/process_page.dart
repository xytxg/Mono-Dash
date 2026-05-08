import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/api/process_api.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/floating_tab_bar.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/more_info_card.dart';
import '../../../common/utils/display_utils.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../widgets/network_item.dart';
import '../widgets/process_detail_sheet.dart';
import '../widgets/process_item.dart';
import '../widgets/process_overlay_menu.dart';

class ProcessPage extends StatelessWidget {
  const ProcessPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _ProcessContent(),
    );
  }
}

class _ProcessContent extends ConsumerStatefulWidget {
  const _ProcessContent();

  @override
  ConsumerState<_ProcessContent> createState() => _ProcessContentState();
}

class _ProcessContentState extends ConsumerState<_ProcessContent> {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _timer;

  // Tab state
  int _tabIndex = 0; // 0 = 进程, 1 = 网络

  // Data
  List<Map<String, dynamic>> _processItems = const [];
  List<Map<String, dynamic>> _networkItems = const [];

  // Connection state
  bool _connecting = true;
  Object? _error;
  String _pendingType = 'ps';

  // Sort state
  ProcessSortKey _sortKey = ProcessSortKey.pid;
  bool _sortAsc = true;

  // Search state
  bool _isSearchMode = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final storage = ref.read(storageServiceProvider);
      final server = await storage.getServer(serverId);
      final apiKey = await storage.getApiKey(serverId) ?? '';
      if (server == null) {
        throw StateError(
          ref.read(appLocalizationsProvider).process_serverMissing,
        );
      }

      _channel = await ProcessApi.connectProcessWebSocket(
        baseUrl: server.baseUrl.toString(),
        apiKey: apiKey,
        allowInsecureConnections: server.allowInsecureConnections,
      );
      _subscription = _channel!.stream.listen(
        (event) {
          final decoded = jsonDecode(event.toString());
          final next = decoded is List
              ? decoded
                    .whereType<Map>()
                    .map((e) => e.cast<String, dynamic>())
                    .toList()
              : <Map<String, dynamic>>[];
          if (!mounted) return;
          setState(() {
            if (_pendingType == 'ps') {
              _processItems = next;
            } else {
              _networkItems = next;
            }
            _connecting = false;
            _error = null;
          });
        },
        onError: (e) {
          if (!mounted) return;
          setState(() {
            _error = e;
            _connecting = false;
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() => _connecting = false);
        },
      );
      await _channel!.ready.timeout(const Duration(seconds: 15));
      if (!mounted) return;
      _sendCurrent();
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _sendCurrent(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _connecting = false;
      });
    }
  }

  void _sendPs() {
    _pendingType = 'ps';
    _channel?.sink.add(
      jsonEncode({
        'type': 'ps',
        'pid': null,
        'username': '',
        'name': _searchQuery,
      }),
    );
  }

  void _sendNet() {
    _pendingType = 'net';
    _channel?.sink.add(
      jsonEncode({
        'type': 'net',
        'processID': null,
        'processName': _searchQuery,
        'port': null,
      }),
    );
  }

  void _sendCurrent() {
    if (_tabIndex == 0) {
      _sendPs();
    } else {
      _sendNet();
    }
  }

  void _switchTab(int index) {
    if (index == _tabIndex) return;
    setState(() {
      _tabIndex = index;
      _searchQuery = '';
      _searchController.clear();
      _isSearchMode = false;
    });
    _sendCurrent();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery = value.trim();
      _sendCurrent();
    });
  }

  void _enterSearchMode() {
    setState(() => _isSearchMode = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _exitSearchMode() {
    setState(() {
      _isSearchMode = false;
      _searchQuery = '';
      _searchController.clear();
    });
    _sendCurrent();
  }

  List<Map<String, dynamic>> _sorted(List<Map<String, dynamic>> items) {
    final sorted = items.toList();
    sorted.sort((a, b) {
      final int cmp;
      switch (_sortKey) {
        case ProcessSortKey.cpu:
          cmp = _parseNum(a['cpuValue']).compareTo(_parseNum(b['cpuValue']));
        case ProcessSortKey.memory:
          cmp = _parseNum(a['rssValue']).compareTo(_parseNum(b['rssValue']));
        case ProcessSortKey.pid:
          cmp = _parseInt(a['PID']).compareTo(_parseInt(b['PID']));
        case ProcessSortKey.connections:
          cmp = _parseInt(
            a['numConnections'],
          ).compareTo(_parseInt(b['numConnections']));
      }
      return _sortAsc ? cmp : -cmp;
    });
    return sorted;
  }

  double _parseNum(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  int _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  Future<void> _stopProcess(Map<String, dynamic> item) async {
    final pid = intValue(item['PID'] ?? item['pid']);
    if (pid == null) return;
    final l10n = context.l10n;
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: l10n.process_stopTitle,
        content: l10n.process_stopContent(pid),
        confirmText: l10n.process_stopAction,
        confirmColor: CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true) return;
    try {
      final serverId = ref.read(activeServerIdProvider);
      final api = ProcessApi(
        await ref.read(dioClientProvider(serverId).future),
      );
      await api.stopProcess(pid);
      _sendCurrent();
      showAppSuccessToast(l10n.process_stopRequested);
    } catch (e) {
      showAppErrorToast(l10n.process_stopFailed, description: '$e');
    }
  }

  Widget _buildTrailing(bool isDark, bool isOverlapping) {
    if (_isSearchMode) {
      return AppHeaderSearchField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        placeholder: _tabIndex == 0
            ? context.l10n.process_searchNamePlaceholder
            : context.l10n.process_searchNameOrPortPlaceholder,
        onChanged: _onSearchChanged,
        onCancel: _exitSearchMode,
      );
    }
    return ProcessOverlayMenu(
      isDark: isDark,
      isOverlapping: isOverlapping,
      currentSort: _sortKey,
      onSortChanged: (key) {
        setState(() {
          if (_sortKey == key) {
            _sortAsc = !_sortAsc;
          } else {
            _sortKey = key;
            _sortAsc = true;
          }
        });
      },
      onSearchEnter: _enterSearchMode,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchDebounce?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FrostedScaffold(
      title: _isSearchMode ? '' : context.l10n.process_title,
      trailingBuilder: _buildTrailing,
      body: Stack(
        children: [
          _buildBody(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingTabBar(
              items: [
                FloatingTabItemData(
                  icon: TablerIcons.cpu,
                  activeIcon: TablerIcons.cpu,
                  label: context.l10n.nav_processes,
                  nativeSymbol: 'cpu',
                ),
                FloatingTabItemData(
                  icon: TablerIcons.network,
                  activeIcon: TablerIcons.network,
                  label: context.l10n.nav_network,
                  nativeSymbol: 'network',
                ),
              ],
              selectedIndex: _tabIndex,
              onTabSelected: _switchTab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_connecting && _processItems.isEmpty && _networkItems.isEmpty) {
      return _buildLoading();
    }
    if (_error != null && _processItems.isEmpty && _networkItems.isEmpty) {
      return AppErrorState(
        title: context.l10n.process_connectionFailed,
        error: _error!,
        onRetry: _connect,
      );
    }

    final items = _tabIndex == 0 ? _processItems : _networkItems;
    final sortedItems = _sorted(items);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: () async => _sendCurrent()),
        SliverToBoxAdapter(
          child: SizedBox(
            height: FrostedScaffold.contentTopPadding(context) + 8,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 132),
          sliver: SliverList.list(
            children: [
              const SizedBox(height: 12),
              // Empty state
              if (sortedItems.isEmpty)
                AppEmptyState(
                  icon: _tabIndex == 0 ? TablerIcons.cpu : TablerIcons.network,
                  title: _searchQuery.isNotEmpty
                      ? context.l10n.process_noResults
                      : context.l10n.process_noData,
                  subtitle: _searchQuery.isNotEmpty
                      ? context.l10n.process_noResultsSubtitle
                      : context.l10n.process_waitingData,
                ),
              // Items
              if (_tabIndex == 0)
                for (final item in sortedItems.take(80))
                  ProcessItem(
                    item: item,
                    onTap: () => showProcessDetailSheet(
                      context,
                      pid: intValue(item['PID'] ?? item['pid']) ?? 0,
                      ref: ref,
                      summary: item,
                    ),
                  )
              else
                for (final item in sortedItems.take(80))
                  NetworkItem(
                    item: item,
                    onTap: () {
                      final pid = intValue(item['PID'] ?? item['pid']);
                      if (pid != null) {
                        showProcessDetailSheet(
                          context,
                          pid: pid,
                          ref: ref,
                          summary: item,
                        );
                      }
                    },
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: moreCardDecoration(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(width: 12),
            Text(
              context.l10n.process_connecting,
              style: TextStyle(color: AppColors.secondaryLabel(context)),
            ),
          ],
        ),
      ),
    );
  }
}
