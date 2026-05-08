import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/router/sheet_dismiss_refresh_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/dto/website/website_acme_account_dto.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../providers/ssl_manage_provider.dart';
import '../widgets/ssl_manage_card.dart';
import '../widgets/ssl_detail_sheet.dart';
import '../widgets/ssl_create_sheet.dart';
import '../widgets/ssl_upload_sheet.dart';
import '../widgets/acme_account_sheet.dart';
import '../widgets/dns_account_sheet.dart';
import '../widgets/ca_manage_sheet.dart';

class SslManagePage extends StatelessWidget {
  const SslManagePage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _SslManageContent(),
    );
  }
}

class _SslManageContent extends ConsumerStatefulWidget {
  const _SslManageContent();

  @override
  ConsumerState<_SslManageContent> createState() => _SslManageContentState();
}

class _SslManageContentState extends ConsumerState<_SslManageContent>
    with SheetDismissRefreshMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void onAllSheetsClosed() {
    ref.read(sslManageControllerProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openCreateSheet(BuildContext context) async {
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final results = await Future.wait([
        repo.searchAcmeAccounts(),
        repo.searchDnsAccounts(const {'page': 1, 'pageSize': 200}),
      ]);
      if (!context.mounted) return;
      final acmeAccounts = results[0] as List<WebsiteAcmeAccountDto>;
      final dnsAccounts = (results[1] as PageResult<DnsAccountDto>).items;
      showSslCreateSheet(
        context,
        acmeAccounts: acmeAccounts,
        dnsAccounts: dnsAccounts,
        onSubmit: (req) async {
          await repo.createSsl(req);
          ref.read(sslManageControllerProvider.notifier).refresh();
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppErrorToast(
        context.l10n.websites_loadDataFailed,
        description: e.toString(),
      );
    }
  }

  Future<void> _openUploadSheet(BuildContext context) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    if (!mounted || !context.mounted) return;
    showSslUploadSheet(
      context,
      onSubmit: (certificate, privateKey, {sslID, description}) async {
        await repo.uploadSsl(
          type: 'paste',
          certificate: certificate,
          privateKey: privateKey,
          description: description,
          websiteSSLId: sslID,
        );
        ref.read(sslManageControllerProvider.notifier).refresh();
      },
    );
  }

  Future<void> _openUploadServerFileSheet(BuildContext context) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    if (!mounted || !context.mounted) return;
    showSslUploadServerFileSheet(
      context,
      onSubmit: (certificatePath, privateKeyPath, {sslID, description}) async {
        await repo.uploadSsl(
          type: 'local',
          certificatePath: certificatePath,
          privateKeyPath: privateKeyPath,
          description: description,
          websiteSSLId: sslID,
        );
        ref.read(sslManageControllerProvider.notifier).refresh();
      },
    );
  }

  Future<void> _openUploadLocalFileSheet(BuildContext context) async {
    final repo = await ref.read(websiteRepositoryProvider.future);
    if (!mounted || !context.mounted) return;
    showSslUploadLocalFileSheet(
      context,
      onSubmit: (certificatePath, privateKeyPath, {sslID, description}) async {
        await repo.uploadSslByFile(
          certificatePath: certificatePath,
          privateKeyPath: privateKeyPath,
          description: description,
          websiteSSLId: sslID,
        );
        ref.read(sslManageControllerProvider.notifier).refresh();
      },
    );
  }

  Future<void> _openAcmeSheet(BuildContext context) async {
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final data = await repo.searchAcmeAccountsPaged(const {
        'page': 1,
        'pageSize': 200,
      });
      if (!context.mounted) return;
      showAcmeAccountSheet(
        context,
        accounts: data.items,
        onCreate: (req) async {
          await repo.createAcmeAccount(req);
        },
        onUpdate: (id, req) async {
          await repo.updateAcmeAccount({'id': id, ...req});
        },
        onDelete: (id) async {
          await repo.deleteAcmeAccount(id);
        },
        onRefresh: () => _openAcmeSheet(context),
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppErrorToast(
        context.l10n.websites_loadDataFailed,
        description: e.toString(),
      );
    }
  }

  Future<void> _openDnsSheet(BuildContext context) async {
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final data = await repo.searchDnsAccounts(const {
        'page': 1,
        'pageSize': 200,
      });
      if (!context.mounted) return;
      showDnsAccountSheet(
        context,
        accounts: data.items,
        onCreate: (req) async {
          await repo.createDnsAccount(req);
        },
        onUpdate: (id, req) async {
          await repo.updateDnsAccount({'id': id, ...req});
        },
        onDelete: (id) async {
          await repo.deleteDnsAccount(id);
        },
        onRefresh: () => _openDnsSheet(context),
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppErrorToast(
        context.l10n.websites_loadDataFailed,
        description: e.toString(),
      );
    }
  }

  Future<void> _openCaSheet(BuildContext context) async {
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final data = await repo.searchCaAccounts(const {
        'page': 1,
        'pageSize': 200,
      });
      if (!context.mounted) return;
      showCaManageSheet(
        context,
        accounts: data.items,
        onCreate: (req) async {
          await repo.createCa(req);
        },
        onObtain: (req) async {
          await repo.obtainCa(req);
        },
        onDetail: (id) async {
          return repo.getCaDetail(id);
        },
        onDelete: (id) async {
          await repo.deleteCa(id);
        },
        onDownload: (id) async {
          return repo.downloadCa(id);
        },
        onRefresh: () => _openCaSheet(context),
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppErrorToast(
        context.l10n.websites_loadDataFailed,
        description: e.toString(),
      );
    }
  }

  void _openDetailSheet(BuildContext context, SslManageDto ssl) {
    showSslDetailSheet(
      context,
      ssl: ssl,
      onDelete: (id) => ref
          .read(sslManageControllerProvider.notifier)
          .deleteSsl(context, [id]),
      onObtain: (id) =>
          ref.read(sslManageControllerProvider.notifier).obtainSsl(context, id),
      onRefresh: (id) async {
        final repo = await ref.read(websiteRepositoryProvider.future);
        return repo.getSsl(id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(sslManageControllerProvider);
    final notifier = ref.read(sslManageControllerProvider.notifier);
    final l10n = context.l10n;

    return FrostedScaffold(
      title: _isSearching ? '' : l10n.websites_certificateManagement,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: l10n.websites_searchCertificates,
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
          label: l10n.common_menu,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: l10n.websites_applyCertificate,
              icon: TablerIcons.plus,
              action: () => _openCreateSheet(context),
            ),
            FrostedMenuItem(
              text: l10n.websites_uploadCertificate,
              icon: TablerIcons.upload,
              action: () {},
              children: [
                FrostedMenuItem(
                  text: l10n.websites_importFromText,
                  icon: TablerIcons.file_text,
                  action: () => _openUploadSheet(context),
                ),
                FrostedMenuItem(
                  text: l10n.websites_selectServerFile,
                  icon: TablerIcons.server,
                  action: () => _openUploadServerFileSheet(context),
                ),
                FrostedMenuItem(
                  text: l10n.websites_uploadFromLocal,
                  icon: TablerIcons.device_mobile,
                  action: () => _openUploadLocalFileSheet(context),
                ),
              ],
            ),
            FrostedMenuItem(
              text: l10n.websites_acmeAccount,
              icon: TablerIcons.user_circle,
              action: () => _openAcmeSheet(context),
            ),
            FrostedMenuItem(
              text: l10n.websites_dnsAccount,
              icon: TablerIcons.world,
              action: () => _openDnsSheet(context),
            ),
            FrostedMenuItem(
              text: l10n.websites_selfSignedCa,
              icon: TablerIcons.shield_lock,
              action: () => _openCaSheet(context),
            ),
            FrostedMenuItem(
              text: l10n.websites_searchCertificatesAction,
              icon: TablerIcons.search,
              action: () {
                setState(() => _isSearching = true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocusNode.requestFocus();
                });
              },
            ),
            FrostedMenuItem(
              text: l10n.websites_refreshList,
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
                onRefresh: () =>
                    ref.read(sslManageControllerProvider.notifier).refresh(),
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
                          return SslManageCard(
                            item: item,
                            onTap: () => _openDetailSheet(context, item),
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
                    icon: TablerIcons.certificate,
                    title: state.searchQuery.isNotEmpty
                        ? l10n.websites_noCertificateFound
                        : l10n.websites_noCertificates,
                    subtitle: state.searchQuery.isNotEmpty
                        ? l10n.websites_tryAnotherKeyword
                        : l10n.websites_noSslCertificates,
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
                  title: l10n.websites_loadCertificateListFailed,
                  error: err,
                  onRetry: () =>
                      ref.read(sslManageControllerProvider.notifier).refresh(),
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
          color: AppColors.separator(context).withValues(alpha: 0.1),
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
                        width: 140 + (index % 3) * 30.0,
                        height: 17,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 6),
                      SkeletonItem(
                        width: 80 + (index % 2) * 20.0,
                        height: 12,
                        borderRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SkeletonItem(width: 48, height: 20, borderRadius: 6),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                SkeletonItem(width: 60, height: 18, borderRadius: 6),
                SizedBox(width: 8),
                SkeletonItem(width: 40, height: 18, borderRadius: 6),
                Spacer(),
                SkeletonItem(width: 80, height: 12, borderRadius: 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
