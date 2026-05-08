import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/frosted_header.dart';
import '../models/database_state.dart';
import '../providers/database_provider.dart';
import '../widgets/database_placeholders.dart';
import '../widgets/mysql_status_widgets.dart';

/// 状态 Tab。
class StatusTab extends ConsumerWidget {
  const StatusTab({
    super.key,
    required this.dbType,
    required this.dbName,
    required this.checkState,
  });

  final String dbType;
  final String dbName;
  final AsyncValue<DatabaseManagementState> checkState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return checkState.when(
      loading: () => _buildLoading(context),
      error: (e, _) => _buildError(context, e),
      data: (data) {
        if (!data.isRunning) {
          return _buildNotRunning(context, data);
        }
        final statusState = ref.watch(
          mysqlStatusProvider((dbType: dbType, dbName: dbName)),
        );
        return statusState.when(
          loading: () => _buildLoading(context),
          error: (e, _) => _buildError(context, e),
          data: (status) => _buildContent(
            context,
            DatabaseManagementState(
              checkResult: data.checkResult,
              status: status,
            ),
          ),
        );
      },
    );
  }

  bool get _isPg => dbType.contains('postgresql');

  Widget _buildLoading(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        FrostedHeader.headerHeight + MediaQuery.paddingOf(context).top + 8,
        16,
        132,
      ),
      children: [
        MysqlInfoCard(
          state: const DatabaseManagementState(),
          type: dbType,
          loading: true,
        ),
        const SizedBox(height: 12),
        if (_isPg)
          const PgStatusCard(status: {}, loading: true)
        else ...[
          const MysqlBasicStatsCard(status: {}, loading: true),
          const SizedBox(height: 12),
          const MysqlPerformanceCard(status: {}, loading: true),
        ],
      ],
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.alert_triangle,
            size: 48,
            color: CupertinoColors.systemOrange.resolveFrom(context),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.common_loadingFailed,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotRunning(BuildContext context, DatabaseManagementState data) {
    return const DatabaseNotRunningPlaceholder();
  }

  Widget _buildContent(BuildContext context, DatabaseManagementState data) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height:
                FrostedHeader.headerHeight +
                MediaQuery.paddingOf(context).top +
                8,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                MysqlInfoCard(state: data, type: dbType),
                const SizedBox(height: 12),
                if (_isPg)
                  PgStatusCard(status: data.status)
                else ...[
                  MysqlBasicStatsCard(status: data.status),
                  const SizedBox(height: 12),
                  MysqlPerformanceCard(status: data.status),
                ],
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 132)),
      ],
    );
  }
}
