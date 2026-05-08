import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/app/app_detail_dto.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/app_meta_chip.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/thin_divider.dart';
import 'app_icon_view.dart';
import 'app_version_picker_dialog.dart';

/// 显示应用详情 BottomSheet
Future<void> showAppDetailSheet(
  BuildContext context,
  int serverId,
  String appKey, {
  bool? installed,
  int? limit,
}) {
  return showActionSheet(
    context: context,
    builder: (_) => ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: _AppDetailSheet(
        appKey: appKey,
        initialInstalled: installed,
        initialLimit: limit,
      ),
    ),
  );
}

class _AppDetailSheet extends ConsumerStatefulWidget {
  const _AppDetailSheet({
    required this.appKey,
    this.initialInstalled,
    this.initialLimit,
  });

  final String appKey;
  final bool? initialInstalled;
  final int? initialLimit;

  @override
  ConsumerState<_AppDetailSheet> createState() => _AppDetailSheetState();
}

class _AppDetailSheetState extends ConsumerState<_AppDetailSheet> {
  AppDetailDto? _detail;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      final detail = await repo.getAppDetail(widget.appKey);
      if (mounted) {
        setState(() {
          _detail = detail;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_error != null) {
      return ActionSheetScaffold(
        infoCard: const SizedBox.shrink(),
        child: AppErrorState(
          title: context.l10n.appStore_loadDetailsFailed,
          error: _error!,
          onRetry: () {
            setState(() {
              _loading = true;
              _error = null;
            });
            _load();
          },
        ),
      );
    }

    final detail = _detail!;

    return ActionSheetScaffold(
      infoCard: ActionSheetInfoCard(
        leading: AppIconView(
          iconName: detail.key,
          // Compatibility: 1Panel v2.0.0 returns a base64 icon directly
          inlineIcon: detail.icon,
          size: 60,
          borderRadius: 16,
        ),
        title: detail.name,
        subtitle: '',
        trailing: _buildInstallButton(context, ref, detail),
        chips: [
          for (final tag in detail.tags)
            AppMetaChip(
              label: tag.name,
              color: CupertinoColors.systemTeal.resolveFrom(context),
            ),
          AppMetaChip(
            label: detail.type,
            color: CupertinoColors.systemBlue.resolveFrom(context),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoGrid(detail),
          const SizedBox(height: 20),
          _buildLinks(detail),
          const SizedBox(height: 28),
          Text(
            context.l10n.appStore_intro,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.label(context),
            ),
          ),
          const SizedBox(height: 12),
          MarkdownBody(
            data: detail.readMe,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: AppColors.label(context),
              ),
              h1: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.label(context),
              ),
              h2: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.label(context),
              ),
              code: TextStyle(
                backgroundColor: AppColors.secondaryBackground(context),
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              codeblockDecoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(AppDetailDto detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _InfoRow(label: context.l10n.appStore_appKey, value: detail.key),
          const ThinDivider(indent: 0),
          _InfoRow(
            label: context.l10n.appStore_architectures,
            value: detail.architectures,
          ),
          const ThinDivider(indent: 0),
          _InfoRow(
            label: context.l10n.appStore_gpuSupport,
            value: detail.gpuSupport
                ? context.l10n.appStore_supported
                : context.l10n.appStore_notSupported,
            valueColor: detail.gpuSupport ? CupertinoColors.systemGreen : null,
          ),
          const ThinDivider(indent: 0),
          _InfoRow(
            label: context.l10n.appStore_latestVersion,
            value: detail.versions.isNotEmpty ? detail.versions.first : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildLinks(AppDetailDto detail) {
    return Row(
      children: [
        if (detail.website.isNotEmpty)
          Expanded(
            child: _LinkButton(
              label: context.l10n.appStore_officialWebsite,
              icon: TablerIcons.world,
              url: detail.website,
            ),
          ),
        if (detail.github.isNotEmpty) ...[
          if (detail.website.isNotEmpty) const SizedBox(width: 10),
          Expanded(
            child: _LinkButton(
              label: 'GitHub',
              icon: TablerIcons.brand_github,
              url: detail.github,
            ),
          ),
        ],
        if (detail.document.isNotEmpty) ...[
          if (detail.website.isNotEmpty || detail.github.isNotEmpty)
            const SizedBox(width: 10),
          Expanded(
            child: _LinkButton(
              label: context.l10n.appStore_documentation,
              icon: TablerIcons.file_text,
              url: detail.document,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInstallButton(
    BuildContext context,
    WidgetRef ref,
    AppDetailDto detail,
  ) {
    // Compatibility: Use passed values to ensure accurate status even if detail API is stale
    final bool installed = widget.initialInstalled ?? detail.installed;
    final int limit = widget.initialLimit ?? detail.limit;
    final bool isLimitOneAndInstalled = limit == 1 && installed;
    final accent = CupertinoColors.activeBlue.resolveFrom(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isLimitOneAndInstalled
          ? null
          : () => showAppVersionPickerDialog(
              context: context,
              serverId: ref.read(activeServerIdProvider),
              appId: detail.id,
              appKey: detail.key,
              appName: detail.name,
              versions: detail.versions,
            ),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isLimitOneAndInstalled ? 0.06 : 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          context.l10n.appStore_install,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: accent.withValues(alpha: isLimitOneAndInstalled ? 0.45 : 1),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryLabel(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor is CupertinoDynamicColor
                    ? (valueColor as CupertinoDynamicColor).resolveFrom(context)
                    : (valueColor ?? AppColors.label(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoColors.activeBlue.resolveFrom(context);
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
