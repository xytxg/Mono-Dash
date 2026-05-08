import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../providers/files_provider.dart';
import '../models/files_view_state.dart';

class FileDisplayOptionsSheet extends ConsumerWidget {
  const FileDisplayOptionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showActionSheet(
      context: context,
      builder: (context) => const FileDisplayOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(filesControllerProvider);
    final state = asyncState.valueOrNull ?? const FilesViewState();

    return ActionSheetScaffold(
      showHandle: false, // 移除拖拽手柄以保持紧凑
      isAdaptive: true, // 自适应高度
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.files_displayOptionsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.label(context),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.l10n.common_done,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSection(
            context,
            title: context.l10n.files_sortByTitle,
            children: [
              _buildOption(
                context,
                label: context.l10n.files_sortName,
                isSelected: state.sortBy == 'name',
                onTap: () => ref
                    .read(filesControllerProvider.notifier)
                    .updateSort('name', state.sortOrder),
              ),
              _buildOption(
                context,
                label: context.l10n.files_sortSize,
                isSelected: state.sortBy == 'size',
                onTap: () => ref
                    .read(filesControllerProvider.notifier)
                    .updateSort('size', state.sortOrder),
              ),
              _buildOption(
                context,
                label: context.l10n.files_sortModifiedTime,
                isSelected: state.sortBy == 'modTime',
                onTap: () => ref
                    .read(filesControllerProvider.notifier)
                    .updateSort('modTime', state.sortOrder),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: context.l10n.files_sortOrderTitle,
            children: [
              _buildOption(
                context,
                label: context.l10n.files_sortAscending,
                isSelected: state.sortOrder == 'ascending',
                onTap: () => ref
                    .read(filesControllerProvider.notifier)
                    .updateSort(state.sortBy, 'ascending'),
              ),
              _buildOption(
                context,
                label: context.l10n.files_sortDescending,
                isSelected: state.sortOrder == 'descending',
                onTap: () => ref
                    .read(filesControllerProvider.notifier)
                    .updateSort(state.sortBy, 'descending'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryLabel(context).withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(
                        height: 0.5,
                        color: AppColors.separator(
                          context,
                        ).withValues(alpha: 0.1),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: AppColors.label(context)),
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark,
                size: 18,
                color: CupertinoColors.activeBlue,
              ),
          ],
        ),
      ),
    );
  }
}
