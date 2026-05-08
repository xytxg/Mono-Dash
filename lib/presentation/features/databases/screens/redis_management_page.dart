import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/floating_tab_bar.dart';
import '../../../common/components/frosted_header.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/terminal/app_terminal.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../models/database_state.dart';
import '../providers/database_provider.dart';
import '../widgets/database_connection_info_sheet.dart';
import '../widgets/redis_settings_tab.dart';
import '../widgets/redis_status_tab.dart';

/// Redis 数据库管理页面（3 Tab：状态 / 终端 / 设置）。
class RedisManagementPage extends StatelessWidget {
  const RedisManagementPage({
    super.key,
    required this.serverId,
    required this.dbType,
    required this.dbName,
    required this.dbVersion,
    required this.dbId,
    required this.dbFrom,
  });

  final int serverId;
  final String dbType;
  final String dbName;
  final String dbVersion;
  final int dbId;
  final String dbFrom;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: _RedisManagementContent(
        dbType: dbType,
        dbName: dbName,
        dbVersion: dbVersion,
        dbId: dbId,
        dbFrom: dbFrom,
      ),
    );
  }
}

class _RedisManagementContent extends ConsumerStatefulWidget {
  const _RedisManagementContent({
    required this.dbType,
    required this.dbName,
    required this.dbVersion,
    required this.dbId,
    required this.dbFrom,
  });

  final String dbType;
  final String dbName;
  final String dbVersion;
  final int dbId;
  final String dbFrom;

  @override
  ConsumerState<_RedisManagementContent> createState() =>
      _RedisManagementPageState();
}

class _RedisManagementPageState extends ConsumerState<_RedisManagementContent> {
  List<FloatingTabItemData> _tabItems(BuildContext context) => [
    FloatingTabItemData(
      icon: TablerIcons.chart_area_line,
      activeIcon: TablerIcons.chart_area_line,
      label: context.l10n.nav_status,
      nativeSymbol: 'chart.line.uptrend.xyaxis',
    ),
    FloatingTabItemData(
      icon: TablerIcons.terminal_2,
      activeIcon: TablerIcons.terminal_2,
      label: context.l10n.nav_terminal,
      nativeSymbol: 'terminal',
    ),
    FloatingTabItemData(
      icon: TablerIcons.settings,
      activeIcon: TablerIcons.settings,
      label: context.l10n.nav_settings,
      nativeSymbol: 'gearshape.fill',
    ),
  ];

  int _selectedIndex = 0;
  bool _isOverlapping = false;
  bool _terminalOpened = false;

  @override
  Widget build(BuildContext context) {
    final tabItems = _tabItems(context);
    final state = ref.watch(
      databaseManagementControllerProvider(widget.dbType, widget.dbName),
    );

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.depth != 0) return false;
              final isOverlapping = notification.metrics.pixels > 10;
              if (isOverlapping != _isOverlapping) {
                setState(() => _isOverlapping = isOverlapping);
              }
              return false;
            },
            child: _buildSelectedTab(state),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FrostedHeader(
              title: widget.dbName,
              onBack: () => Navigator.of(context).maybePop(),
              isOverlapping: _isOverlapping,
              trailingBuilder: (isDark, isOverlapping) =>
                  FrostedOverlayMenuButton(
                    label: context.l10n.databases_manage,
                    isDark: isDark,
                    isOverlapping: isOverlapping,
                    items: [
                      FrostedMenuItem(
                        text: context.l10n.databases_viewConnectionInfo,
                        icon: TablerIcons.link,
                        action: () => showDatabaseConnectionInfoSheet(
                          context,
                          dbType: widget.dbType,
                          dbName: widget.dbName,
                          dbId: widget.dbId,
                          dbFrom: widget.dbFrom,
                          isRemote: widget.dbFrom == 'remote',
                        ),
                      ),
                    ],
                  ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingTabBar(
              items: tabItems,
              selectedIndex: _selectedIndex,
              onTabSelected: (index) {
                if (index == 1) {
                  _openTerminal();
                  return;
                }
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openTerminal() {
    if (_terminalOpened) return;
    _terminalOpened = true;

    showAppTerminal(
      context,
      containerId: widget.dbName,
      command: 'bash',
      source: 'database',
      databaseType: widget.dbType,
      databaseName: widget.dbName,
    ).then((_) {
      _terminalOpened = false;
    });
  }

  Widget _buildSelectedTab(AsyncValue<DatabaseManagementState> state) {
    return switch (_selectedIndex) {
      0 => RedisStatusTab(
        dbType: widget.dbType,
        dbName: widget.dbName,
        checkState: state,
      ),
      _ => RedisSettingsTab(
        dbType: widget.dbType,
        dbName: widget.dbName,
        checkState: state,
      ),
    };
  }
}
