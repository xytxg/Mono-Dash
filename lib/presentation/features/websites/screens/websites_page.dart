import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/router/sheet_dismiss_refresh_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../../app_store/screens/app_store_page.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/websites_provider.dart';
import '../widgets/website_list_item.dart';

class WebsitesPage extends ConsumerStatefulWidget {
  const WebsitesPage({super.key, this.isActive = true});

  final bool isActive;

  @override
  ConsumerState<WebsitesPage> createState() => _WebsitesPageState();
}

class _WebsitesPageState extends ConsumerState<WebsitesPage>
    with SheetDismissRefreshMixin {
  final _scrollController = ScrollController();
  late final TapGestureRecognizer _appStoreRecognizer;

  @override
  void onAllSheetsClosed() {
    if (widget.isActive) {
      ref.read(websitesControllerProvider.notifier).refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _appStoreRecognizer = TapGestureRecognizer()
      ..onTap = () {
        final serverId = ref.read(activeServerIdProvider);
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => AppStorePage(serverId: serverId)),
        );
      };
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _appStoreRecognizer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(websitesControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(websitesControllerProvider);

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () =>
              ref.read(websitesControllerProvider.notifier).refresh(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: FrostedScaffold.contentTopPadding(context) + 8,
          ),
        ),
        asyncState.when(
          data: (state) {
            // OpenResty is not installed.
            if (state.isOpenRestyInstalled == false) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.cube_box,
                        size: 48,
                        color: AppColors.tertiaryLabel(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.websites_openRestyNotInstalled,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryLabel(context),
                            fontFamily: '.AppleSystemUIFont',
                          ),
                          children: [
                            TextSpan(
                              text:
                                  context.l10n.websites_installOpenRestyPrefix,
                            ),
                            TextSpan(
                              text: context.l10n.websites_appStore,
                              style: TextStyle(
                                color: CupertinoColors.activeBlue.resolveFrom(
                                  context,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: _appStoreRecognizer,
                            ),
                            TextSpan(
                              text:
                                  context.l10n.websites_installOpenRestySuffix,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // OpenResty is stopped.
            if (state.openRestyStatus == 'Stopped') {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.pause_circle,
                        size: 48,
                        color: AppColors.tertiaryLabel(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.websites_openRestyStopped,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.websites_startOpenRestyFromServiceMenu,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.websites.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: state.searchText.isEmpty
                      ? CupertinoIcons.globe
                      : CupertinoIcons.search,
                  title: state.searchText.isEmpty
                      ? context.l10n.websites_noWebsites
                      : context.l10n.websites_noMatchingWebsites,
                  subtitle: state.searchText.isEmpty
                      ? context.l10n.websites_createFirstWebsiteHint
                      : context.l10n.websites_tryAnotherKeyword,
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 132),
              sliver: SliverList.builder(
                itemCount: state.websites.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.websites.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  }
                  final website = state.websites[index];
                  return WebsiteListItem(website: website);
                },
              ),
            );
          },
          loading: () => SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 132),
            sliver: SliverList.list(
              children: List.generate(
                6,
                (index) => const WebsiteListItem(
                  website: WebsiteDto(
                    id: 0,
                    primaryDomain: '',
                    status: '',
                    type: '',
                    protocol: '',
                    expireDate: '',
                    sslExpireDate: '',
                    remark: '',
                    createdAt: '',
                    updatedAt: '',
                    siteDir: '',
                    sitePath: '',
                    runtimeName: '',
                    websiteRuntimeType: '',
                    dbID: 0,
                    dbType: '',
                  ),
                  loading: true,
                ),
              ),
            ),
          ),
          error: (err, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              title: context.l10n.websites_loadWebsitesFailed,
              error: err,
              onRetry: () =>
                  ref.read(websitesControllerProvider.notifier).refresh(),
            ),
          ),
        ),
      ],
    );
  }
}
