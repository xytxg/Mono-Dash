import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/frosted_header.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../models/database_state.dart';
import '../providers/database_provider.dart';
import '../widgets/database_action_sheet.dart';
import '../widgets/database_card.dart';
import '../widgets/database_placeholders.dart';

/// 数据库列表 Tab。
class DatabaseListTab extends ConsumerWidget {
  const DatabaseListTab({
    super.key,
    required this.dbType,
    required this.dbName,
    required this.checkState,
    required this.onRefresh,
    this.isPg = false,
    this.isRemote = false,
  });

  final String dbType;
  final String dbName;
  final AsyncValue<DatabaseManagementState> checkState;
  final VoidCallback onRefresh;
  final bool isPg;
  final bool isRemote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return checkState.when(
      loading: () => _buildLoading(context),
      error: (e, _) => _buildError(context, e),
      data: (data) {
        if (!isRemote && !data.isRunning) {
          return _buildNotRunning(context, data);
        }
        final listState = ref.watch(
          isPg
              ? pgDatabaseListProvider((dbType: dbType, dbName: dbName))
              : mysqlDatabaseListProvider((dbType: dbType, dbName: dbName)),
        );
        return listState.when(
          loading: () => _buildLoading(context),
          error: (e, _) => _buildError(context, e),
          data: (databases) {
            if (databases.isEmpty) {
              return _buildEmpty(context);
            }
            return _buildList(context, databases);
          },
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
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
        SliverList.builder(
          itemCount: 4,
          itemBuilder: (context, index) => _DatabaseCardSkeleton(index: index),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 132)),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return DatabaseErrorPlaceholder(error: error);
  }

  Widget _buildNotRunning(BuildContext context, DatabaseManagementState data) {
    return DatabaseNotRunningPlaceholder(
      status: data.checkResult?.status ?? context.l10n.common_unknown,
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.database_off,
            size: 48,
            color: CupertinoColors.systemGrey
                .resolveFrom(context)
                .withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.databases_emptyTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.databases_emptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<DatabaseSearchItemDto> databases,
  ) {
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
        SliverList(
          delegate: SliverChildListDelegate(
            databases.map<Widget>((db) {
              return DatabaseCard(
                database: db,
                type: dbType,
                onTap: () => showDatabaseActionSheet(
                  context,
                  db,
                  dbType,
                  onRefresh: onRefresh,
                ),
              );
            }).toList(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 132)),
      ],
    );
  }
}

class _DatabaseCardSkeleton extends StatelessWidget {
  const _DatabaseCardSkeleton({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final titleWidth = 110.0 + (index % 3) * 24.0;
    final metaWidth = 118.0 + (index % 2) * 20.0;
    final descriptionWidth = 140.0 + (index % 3) * 26.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.14),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonItem.text(width: 26, height: 26, borderRadius: 8),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonItem.text(width: titleWidth, height: 18),
                    const SizedBox(height: 7),
                    SkeletonItem.text(width: metaWidth, height: 11),
                  ],
                ),
              ),
              const SkeletonItem.text(width: 44, height: 22, borderRadius: 8),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 0.5,
              color: AppColors.separator(context).withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                _DatabaseInfoRowSkeleton(valueWidth: 88 + (index % 2) * 18),
                const SizedBox(height: 12),
                _DatabaseInfoRowSkeleton(valueWidth: 74 + (index % 3) * 12),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonItem.text(
                      width: 14,
                      height: 14,
                      borderRadius: 7,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SkeletonItem.text(
                        width: descriptionWidth,
                        height: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatabaseInfoRowSkeleton extends StatelessWidget {
  const _DatabaseInfoRowSkeleton({required this.valueWidth});

  final double valueWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SkeletonItem.text(width: 14, height: 14, borderRadius: 7),
        const SizedBox(width: 10),
        const SkeletonItem.text(width: 44, height: 12),
        const Spacer(),
        SkeletonItem.text(width: valueWidth, height: 14),
        const SizedBox(width: 8),
        const SkeletonItem.text(width: 16, height: 16, borderRadius: 8),
      ],
    );
  }
}
