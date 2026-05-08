import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/frosted_action_popup_menu.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/overlay_menu_mixin.dart';
import '../../../common/components/skeleton_item.dart';
import '../../app_store/screens/app_store_page.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/database_provider.dart';
import '../widgets/database_card.dart';
import '../widgets/database_placeholders.dart';
import '../widgets/database_remote_create_sheet.dart';
import '../widgets/database_type_icon.dart';
import 'mysql_management_page.dart';
import 'redis_management_page.dart';

/// 显示数据库实例列表 Sheet。
Future<void> showDatabaseSheet(BuildContext context, int serverId) async {
  await showActionSheet(
    context: context,
    builder: (context) => ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: DatabaseSheet(serverId: serverId),
    ),
  );
}

class DatabaseSheet extends ConsumerStatefulWidget {
  const DatabaseSheet({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<DatabaseSheet> createState() => _DatabaseSheetState();
}

class _DatabaseSheetState extends ConsumerState<DatabaseSheet>
    with OverlayMenuMixin {
  late final TapGestureRecognizer _appStoreRecognizer;
  late final TapGestureRecognizer _remoteRecognizer;

  @override
  void initState() {
    super.initState();
    _appStoreRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => AppStorePage(serverId: widget.serverId),
          ),
        );
      };
    _remoteRecognizer = TapGestureRecognizer()
      ..onTapDown = (details) {
        _showRemoteMenu(context, details.globalPosition);
      };
  }

  void _showRemoteMenu(BuildContext context, Offset tapOffset) {
    if (isOverlayMenuOpen) return;

    final items = [
      FrostedMenuItem(
        text: context.l10n.databases_remoteMysqlInstance,
        iconWidget: const DatabaseTypeIcon(type: 'mysql', size: 18),
        action: () {
          showDatabaseRemoteCreateSheet(
            context,
            dbType: 'mysql',
            onSuccess: () {
              ref.read(databaseControllerProvider.notifier).refresh();
            },
          );
        },
      ),
      FrostedMenuItem(
        text: context.l10n.databases_remoteMariadbInstance,
        iconWidget: const DatabaseTypeIcon(type: 'mariadb', size: 18),
        action: () {
          showDatabaseRemoteCreateSheet(
            context,
            dbType: 'mariadb',
            onSuccess: () {
              ref.read(databaseControllerProvider.notifier).refresh();
            },
          );
        },
      ),
      FrostedMenuItem(
        text: context.l10n.databases_remotePostgresqlInstance,
        iconWidget: const DatabaseTypeIcon(type: 'postgresql', size: 18),
        action: () {
          showDatabaseRemoteCreateSheet(
            context,
            dbType: 'postgresql',
            onSuccess: () {
              ref.read(databaseControllerProvider.notifier).refresh();
            },
          );
        },
      ),
      // FrostedMenuItem(
      //   text: 'Remote Redis Instance',
      //   iconWidget: const DatabaseTypeIcon(type: 'redis', size: 18),
      //   action: () {
      //     showDatabaseRemoteCreateSheet(
      //       context,
      //       dbType: 'redis',
      //       onSuccess: () {
      //         ref.read(databaseControllerProvider.notifier).refresh();
      //       },
      //     );
      //   },
      // ),
    ];

    showOverlayMenu(
      contentBuilder: (ctx) {
        const menuWidth = 220.0;
        final menuHeight = items.length * 48.0;
        final pos = OverlayMenuMixin.computeTapOffsetPosition(
          tapOffset: tapOffset,
          screenSize: MediaQuery.sizeOf(ctx),
          menuWidth: menuWidth,
          menuHeight: menuHeight,
          horizontalBias: -110,
        );
        return [
          Positioned(
            top: pos.top,
            left: pos.left,
            child: FrostedActionPopupMenu(
              width: menuWidth,
              items: items,
              alignment: pos.showAbove
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              onSelect: (action) {
                hideOverlayMenu();
                action();
              },
            ),
          ),
        ];
      },
      dismissBuilder: (ctx, onDismiss) => Positioned.fill(
        child: GestureDetector(
          onTap: onDismiss,
          behavior: HitTestBehavior.translucent,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _appStoreRecognizer.dispose();
    _remoteRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(databaseControllerProvider);
    final hasData = state.maybeWhen(
      data: (data) => data.instances.isNotEmpty,
      orElse: () => false,
    );

    return ActionSheetScaffold(
      title: context.l10n.databases_instances,
      isAdaptive: true,
      trailing: hasData
          ? Builder(
              builder: (buttonContext) => CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                onPressed: () {
                  final box = buttonContext.findRenderObject() as RenderBox;
                  final offset = box.localToGlobal(Offset.zero);
                  _showRemoteMenu(
                    context,
                    offset + Offset(box.size.width / 2, box.size.height),
                  );
                },
                child: Icon(
                  TablerIcons.plus,
                  size: 22,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                ),
              ),
            )
          : null,
      child: state.when(
        loading: () => _buildLoading(context),
        error: (e, _) => _buildError(context, ref, e),
        data: (data) {
          // 暂时过滤掉远程 Redis 实例
          final filteredInstances = data.instances.where((inst) {
            final isRedis = inst.type.contains('redis');
            final isRemote = inst.from == 'remote';
            return !(isRedis && isRemote);
          }).toList();

          final filteredState = data.copyWith(instances: filteredInstances);
          final grouped = filteredState.groupedByType;

          if (filteredInstances.isEmpty) {
            return _buildEmpty(context);
          }
          if (grouped.isEmpty) {
            return _buildNoLocal(context);
          }
          return _buildList(context, grouped);
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12, top: 12, bottom: 8),
          child: SkeletonItem.text(width: 54, height: 12),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.separator(context).withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                const _DatabaseInstanceCardSkeleton(),
                if (i < 2)
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Container(
                      height: 0.5,
                      color: AppColors.separator(
                        context,
                      ).withValues(alpha: 0.08),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: DatabaseErrorPlaceholder(
        error: error,
        padding: EdgeInsets.zero,
        onRetry: () => ref.invalidate(databaseControllerProvider),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.database_off,
              size: 64,
              color: CupertinoColors.systemGrey
                  .resolveFrom(context)
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.databases_noAvailableDatabases,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.secondaryLabel(context),
                  fontFamily: '.AppleSystemUIFont',
                ),
                children: [
                  TextSpan(text: context.l10n.databases_emptyInstallPrefix),
                  TextSpan(
                    text: context.l10n.appStore_title,
                    style: TextStyle(
                      color: CupertinoColors.activeBlue.resolveFrom(context),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: _appStoreRecognizer,
                  ),
                  TextSpan(text: context.l10n.databases_emptyInstallMiddle),
                  TextSpan(
                    text: context.l10n.databases_addRemoteInstance,
                    style: TextStyle(
                      color: CupertinoColors.activeBlue.resolveFrom(context),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: _remoteRecognizer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLocal(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.cloud,
              size: 64,
              color: CupertinoColors.systemGrey
                  .resolveFrom(context)
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.databases_onlyRemoteDatabases,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.databases_noLocalRemoteComingSoon,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    Map<String, List<DatabaseInstanceDto>> grouped,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildGroupedCards(context, grouped),
    );
  }

  List<Widget> _buildGroupedCards(
    BuildContext context,
    Map<String, List<DatabaseInstanceDto>> grouped,
  ) {
    final widgets = <Widget>[];
    final typeLabels = {
      'mysql': 'MySQL',
      'mariadb': 'MariaDB',
      'mysql-cluster': 'MySQL Cluster',
      'postgresql': 'PostgreSQL',
      'postgresql-cluster': 'PostgreSQL Cluster',
      'redis': 'Redis',
      'redis-cluster': 'Redis Cluster',
    };

    for (final entry in grouped.entries) {
      final type = entry.key;
      final instances = entry.value;
      final label = typeLabels[type] ?? type.toUpperCase();

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 12, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryLabel(context).withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );

      widgets.add(
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.separator(context).withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          child: Column(
            children: instances.asMap().entries.map((instanceEntry) {
              final index = instanceEntry.key;
              final instance = instanceEntry.value;
              final isLast = index == instances.length - 1;

              return Column(
                children: [
                  DatabaseInstanceCard(
                    instance: instance,
                    onTap: () {
                      Navigator.of(context).pop();
                      final isRedis = instance.type.contains('redis');
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => isRedis
                              ? RedisManagementPage(
                                  serverId: widget.serverId,
                                  dbType: instance.type,
                                  dbName: instance.database,
                                  dbVersion: instance.version,
                                  dbId: instance.id,
                                  dbFrom: instance.from,
                                )
                              : MysqlManagementPage(
                                  serverId: widget.serverId,
                                  dbType: instance.type,
                                  dbName: instance.database,
                                  dbVersion: instance.version,
                                  dbId: instance.id,
                                  dbFrom: instance.from,
                                ),
                        ),
                      );
                    },
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Container(
                        height: 0.5,
                        color: AppColors.separator(
                          context,
                        ).withValues(alpha: 0.08),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }

    return widgets;
  }
}

class _DatabaseInstanceCardSkeleton extends StatelessWidget {
  const _DatabaseInstanceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SkeletonItem.text(width: 36, height: 36, borderRadius: 10),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonItem.text(width: 130, height: 15),
                SizedBox(height: 7),
                SkeletonItem.text(width: 96, height: 11),
              ],
            ),
          ),
          SizedBox(width: 8),
          SkeletonItem.text(width: 44, height: 22, borderRadius: 8),
          SizedBox(width: 10),
          SkeletonItem.text(width: 14, height: 14, borderRadius: 7),
        ],
      ),
    );
  }
}
