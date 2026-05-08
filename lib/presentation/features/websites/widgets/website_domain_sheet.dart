import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../common/app_toast.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/dto/website/website_domain_req.dart';
import '../providers/website_domains_provider.dart';
import 'domain/domain_card.dart';
import 'domain/inline_add_domain_card.dart';
import 'website_modal_sheet.dart';

void showWebsiteDomainSheet(
  BuildContext context, {
  required int websiteId,
  required String title,
}) {
  showWebsiteModalSheet<void>(
    context: context,
    child: _WebsiteDomainSheet(websiteId: websiteId, title: title),
  );
}

class _WebsiteDomainSheet extends StatelessWidget {
  const _WebsiteDomainSheet({required this.websiteId, required this.title});

  final int websiteId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return WebsiteAsyncModalSheet<List<WebsiteDomainDto>>(
      provider: websiteDomainsControllerProvider(websiteId),
      maxHeightFactor: 0.84,
      backgroundAlpha: 0.9,
      errorTitle: context.l10n.websites_loadDomainsFailed,
      headerBuilder: (context, ref, domainsAsync) => _DomainHeader(
        title: title,
        count: domainsAsync?.valueOrNull?.length,
        onAdd: () =>
            ref.read(_inlineAddVisibleProvider(websiteId).notifier).state =
                true,
      ),
      dataBuilder: (context, domains) =>
          _DomainList(websiteId: websiteId, domains: domains),
      onRetry: (ref) =>
          ref.invalidate(websiteDomainsControllerProvider(websiteId)),
    );
  }
}

final _inlineAddVisibleProvider = StateProvider.autoDispose.family<bool, int>(
  (ref, websiteId) => false,
);

class _DomainHeader extends StatelessWidget {
  const _DomainHeader({
    required this.title,
    required this.count,
    required this.onAdd,
  });

  final String title;
  final int? count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final domainCount = count;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue
                  .resolveFrom(context)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              TablerIcons.at,
              size: 22,
              color: CupertinoColors.activeBlue.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.websites_domainSettings,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  domainCount == null
                      ? title
                      : context.l10n.websites_domainCountTitle(
                          title,
                          domainCount,
                        ),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryLabel(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(40),
            onPressed: onAdd,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue
                    .resolveFrom(context)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                TablerIcons.plus,
                size: 20,
                color: CupertinoColors.activeBlue.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DomainList extends ConsumerWidget {
  const _DomainList({required this.websiteId, required this.domains});

  final int websiteId;
  final List<WebsiteDomainDto> domains;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdding = ref.watch(_inlineAddVisibleProvider(websiteId));
    if (domains.isEmpty) {
      if (!isAdding) return const _EmptyState();
    }

    return Column(
      children: [
        for (int i = 0; i < domains.length + (isAdding ? 1 : 0); i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildItem(context, ref, i, isAdding),
        ],
      ],
    );
  }

  Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    bool isAdding,
  ) {
    if (isAdding && index == 0) {
      return InlineAddDomainCard(
        onCancel: () =>
            ref.read(_inlineAddVisibleProvider(websiteId).notifier).state =
                false,
        onSave: (input) async {
          final notifier = ref.read(
            websiteDomainsControllerProvider(websiteId).notifier,
          );
          try {
            await notifier.addDomain(
              WebsiteDomainReq(
                domain: input.domain,
                host: input.domain,
                port: input.port,
                ssl: input.ssl,
              ),
            );
            ref.read(_inlineAddVisibleProvider(websiteId).notifier).state =
                false;
          } on AppNetworkException catch (error) {
            if (context.mounted) showAppErrorToast(error.message);
            rethrow;
          } catch (error) {
            if (context.mounted) showAppErrorToast('$error');
            rethrow;
          }
        },
        onInvalidInput: showAppWarningToast,
      );
    }
    final domainIndex = isAdding ? index - 1 : index;
    final domain = domains[domainIndex];
    return DomainCard(
      domain: domain,
      canDelete: domains.length > 1,
      onVisit: () => _openDomain(context, domain),
      onSslChanged: (ssl) => ref
          .read(websiteDomainsControllerProvider(websiteId).notifier)
          .updateSsl(domain, ssl),
      onDelete: () => _confirmDelete(context, ref, websiteId, domain),
    );
  }

  Future<void> _openDomain(
    BuildContext context,
    WebsiteDomainDto domain,
  ) async {
    final uri = _domainUri(domain);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      showAppErrorToast(context.l10n.websites_openBrowserFailed);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int websiteId,
    WebsiteDomainDto domain,
  ) async {
    if (domains.length <= 1) {
      showAppWarningToast(context.l10n.websites_keepAtLeastOneDomain);
      return;
    }

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(context.l10n.websites_removeDomain),
        content: Text(
          context.l10n.websites_removeDomainConfirm(
            '${domain.domain}:${domain.port}',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.common_cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.websites_remove),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref
        .read(websiteDomainsControllerProvider(websiteId).notifier)
        .deleteDomain(domain);
  }

  Uri? _domainUri(WebsiteDomainDto domain) {
    final value = domain.domain.trim();
    if (value.isEmpty) return null;
    if (value.contains('://')) return Uri.tryParse(value);

    final scheme = domain.ssl ? 'https' : 'http';
    final port = domain.port > 0 ? ':${domain.port}' : '';
    return Uri.tryParse('$scheme://$value$port');
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 56),
      child: Column(
        children: [
          Icon(
            TablerIcons.world_off,
            size: 36,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.websites_noDomains,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.websites_addDomainFromTopRight,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }
}
