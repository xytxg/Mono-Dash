import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/router/sheet_dismiss_refresh_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/compose_template_provider.dart';
import '../widgets/compose_template_card.dart';
import '../widgets/compose_template_action_sheet.dart';
import '../widgets/compose_template_create_sheet.dart';
import '../widgets/compose_template_import_sheet.dart';

class ComposeTemplatePage extends StatelessWidget {
  const ComposeTemplatePage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _ComposeTemplateContent(),
    );
  }
}

class _ComposeTemplateContent extends ConsumerStatefulWidget {
  const _ComposeTemplateContent();

  @override
  ConsumerState<_ComposeTemplateContent> createState() =>
      _ComposeTemplateContentState();
}

class _ComposeTemplateContentState
    extends ConsumerState<_ComposeTemplateContent>
    with SheetDismissRefreshMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void onAllSheetsClosed() {
    ref.read(composeTemplateControllerProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(composeTemplateControllerProvider);
    final notifier = ref.read(composeTemplateControllerProvider.notifier);

    return FrostedScaffold(
      title: _isSearching ? '' : context.l10n.containers_composeTemplates,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: context.l10n.containers_searchTemplates,
            onChanged: notifier.search,
            onClear: () => notifier.search(''),
            onCancel: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              notifier.search('');
            },
          );
        }

        return FrostedOverlayMenuButton(
          label: context.l10n.containers_more,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: context.l10n.containers_createTemplate,
              icon: TablerIcons.plus,
              action: () => showComposeTemplateCreateSheet(context),
            ),
            FrostedMenuItem(
              text: context.l10n.containers_searchTemplates,
              icon: TablerIcons.search,
              action: () {
                setState(() => _isSearching = true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocusNode.requestFocus();
                });
              },
            ),
            FrostedMenuItem(
              text: context.l10n.containers_importTemplate,
              icon: TablerIcons.file_import,
              action: () => importComposeTemplates(context, ref),
            ),
            FrostedMenuItem(
              text: context.l10n.containers_exportAll,
              icon: TablerIcons.file_export,
              action: () => _exportAll(context),
            ),
            FrostedMenuItem(
              text: context.l10n.containers_refreshList,
              icon: TablerIcons.refresh,
              action: notifier.refresh,
            ),
          ],
        );
      },
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () => ref
                    .read(composeTemplateControllerProvider.notifier)
                    .refresh(),
              ),
              asyncState.when(
                skipLoadingOnRefresh: true,
                skipLoadingOnReload: true,
                data: (state) {
                  if (state.items.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      FrostedScaffold.contentTopPadding(context) + 12,
                      16,
                      40,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.items.length) {
                            if (state.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }
                          final item = state.items[index];
                          return ComposeTemplateCard(
                            item: item,
                            onTap: () =>
                                showComposeTemplateActionSheet(context, item),
                          );
                        },
                        childCount:
                            state.items.length + (state.isLoadingMore ? 1 : 0),
                      ),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    FrostedScaffold.contentTopPadding(context) + 12,
                    16,
                    40,
                  ),
                  sliver: SliverList.builder(
                    itemCount: 5,
                    itemBuilder: _buildSkeletonItem,
                  ),
                ),
                error: (err, _) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            ],
          ),
          asyncState.when(
            data: (state) {
              if (state.items.isNotEmpty || state.isLoadingMore) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: FrostedScaffold.contentTopPadding(context),
                  ),
                  child: AppEmptyState(
                    icon: TablerIcons.template,
                    title: state.searchQuery.isNotEmpty
                        ? context.l10n.containers_noTemplateFound
                        : context.l10n.containers_noTemplate,
                    subtitle: state.searchQuery.isNotEmpty
                        ? context.l10n.containers_tryAnotherKeyword
                        : context.l10n.containers_noTemplateSubtitle,
                    useCardStyle: false,
                    padding: const EdgeInsets.only(bottom: 40),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, _) => Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: FrostedScaffold.contentTopPadding(context),
                ),
                child: AppErrorState(
                  title: context.l10n.containers_loadTemplateListFailed,
                  error: err,
                  onRetry: () => ref
                      .read(composeTemplateControllerProvider.notifier)
                      .refresh(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonItem(width: 40, height: 40, borderRadius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonItem(
                        width: 100 + (index % 3) * 30.0,
                        height: 17,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 6),
                      SkeletonItem(
                        width: 80 + (index % 2) * 40.0,
                        height: 12,
                        borderRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                SkeletonItem(width: 14, height: 14, borderRadius: 3),
                SizedBox(width: 6),
                SkeletonItem(width: 50, height: 12, borderRadius: 3),
                SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SkeletonItem(width: 80, height: 12, borderRadius: 3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAll(BuildContext context) async {
    final state = ref.read(composeTemplateControllerProvider).valueOrNull;
    if (state == null || state.items.isEmpty) {
      showAppErrorToast(context.l10n.containers_noTemplatesToExport);
      return;
    }

    final exportData = state.items
        .map(
          (t) => {
            'name': t.name,
            'description': t.description,
            'content': t.content,
          },
        )
        .toList();

    final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);
    final now = DateTime.now();
    final ts =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    final fileName = '1panel-docker-compose-template-$ts.json';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonStr);

    await SharePlus.instance.share(
      ShareParams(
        title: fileName,
        subject: fileName,
        files: [XFile(file.path, mimeType: 'application/json')],
        fileNameOverrides: [fileName],
      ),
    );
  }
}
