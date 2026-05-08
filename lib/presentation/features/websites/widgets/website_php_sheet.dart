import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../../common/components/app_picker.dart';
import '../providers/website_detail_provider.dart';
import '../providers/websites_provider.dart';
import 'website_modal_sheet.dart';

part 'website_php_sheet.g.dart';

Future<void> showWebsitePhpSheet(
  BuildContext context, {
  required int websiteId,
  required String title,
}) async {
  await showWebsiteModalSheet<void>(
    context: context,
    child: _WebsitePhpSheet(websiteId: websiteId, title: title),
  );
}

class _WebsitePhpSheet extends StatelessWidget {
  const _WebsitePhpSheet({required this.websiteId, required this.title});

  final int websiteId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return WebsiteAsyncModalSheet<WebsiteDetailDto>(
      provider: websiteDetailProvider(websiteId),
      errorTitle: context.l10n.websites_loadWebsiteDetailsFailed,
      headerBuilder: (context, ref, detailAsync) => _PhpHeader(title: title),
      dataBuilder: (context, detail) => _PhpContent(detail: detail),
      onRetry: (ref) => ref.invalidate(websiteDetailProvider(websiteId)),
    );
  }
}

class _PhpHeader extends StatelessWidget {
  const _PhpHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CupertinoColors.systemPurple
                  .resolveFrom(context)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              TablerIcons.brand_php,
              size: 22,
              color: CupertinoColors.systemPurple.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.websites_phpSettings,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
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
        ],
      ),
    );
  }
}

class _PhpContent extends ConsumerStatefulWidget {
  const _PhpContent({required this.detail});

  final WebsiteDetailDto detail;

  @override
  ConsumerState<_PhpContent> createState() => _PhpContentState();
}

class _PhpContentState extends ConsumerState<_PhpContent> {
  bool _saving = false;

  bool get _isPhpWebsite {
    final website = widget.detail.website;
    return website.type == 'runtime' &&
        website.websiteRuntimeType.toLowerCase() == 'php';
  }

  @override
  Widget build(BuildContext context) {
    final runtimesAsync = ref.watch(_phpRuntimesProvider);

    return runtimesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 46),
        child: CupertinoActivityIndicator(),
      ),
      error: (error, _) => _ErrorState(
        error: error,
        onRetry: () => ref.invalidate(_phpRuntimesProvider),
      ),
      data: (runtimes) => _buildContent(context, runtimes),
    );
  }

  Widget _buildContent(BuildContext context, List<RuntimeDto> runtimes) {
    final website = widget.detail.website;
    final isPhp = _isPhpWebsite;
    final l10n = context.l10n;

    // The first option is a static website, followed by PHP runtimes.
    final options = <AppPickerOption<int>>[
      AppPickerOption<int>(value: 0, label: l10n.websites_staticSite),
      ...runtimes.map(
        (runtime) => AppPickerOption<int>(
          value: runtime.id,
          label: '${runtime.name} (PHP ${runtime.version})',
        ),
      ),
    ];

    // Resolve the current selected value.
    int selectedValue = 0;
    if (isPhp && website.runtimeName.isNotEmpty) {
      final matchedRuntime = runtimes.where(
        (r) => r.name == website.runtimeName,
      );
      if (matchedRuntime.isNotEmpty) {
        selectedValue = matchedRuntime.first.id;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionCard(
          icon: TablerIcons.server,
          title: l10n.websites_currentStatus,
          child: _StatusRow(isPhp: isPhp, runtimeName: website.runtimeName),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: TablerIcons.switch_horizontal,
          title: l10n.websites_switchRuntime,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.websites_selectStaticOrPhpRuntime,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
              const SizedBox(height: 12),
              AppInlinePicker<int>(
                options: options,
                value: selectedValue,
                onChanged: (newValue) => _onChanged(
                  context,
                  newValue,
                  currentValue: selectedValue,
                  runtimes: runtimes,
                ),
                enabled: !_saving,
                selectedColor: CupertinoColors.systemPurple.resolveFrom(
                  context,
                ),
              ),
            ],
          ),
        ),
        if (_saving) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(),
              const SizedBox(width: 8),
              Text(
                l10n.websites_switching,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _onChanged(
    BuildContext context,
    int newValue, {
    required int currentValue,
    required List<RuntimeDto> runtimes,
  }) async {
    if (newValue == currentValue) return;

    final l10n = context.l10n;
    // Resolve the target name.
    String targetName;
    if (newValue == 0) {
      targetName = l10n.websites_staticSite;
    } else {
      final runtime = runtimes.where((r) => r.id == newValue);
      targetName = runtime.isNotEmpty
          ? '${runtime.first.name} (PHP ${runtime.first.version})'
          : l10n.websites_phpRuntime;
    }

    // Show confirmation dialog.
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => AppConfirmSheet(
        title: l10n.websites_switchRuntime,
        content: l10n.websites_switchRuntimeConfirm(targetName),
        icon: TablerIcons.alert_triangle,
        iconColor: CupertinoColors.systemOrange,
        confirmText: l10n.websites_confirmSwitch,
        confirmColor: CupertinoColors.systemPurple,
      ),
    );

    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.switchPhpVersion(widget.detail.website.id, newValue);

      if (!mounted) return;

      // Refresh related data.
      ref.invalidate(websiteDetailProvider(widget.detail.website.id));
      ref.invalidate(websitesControllerProvider);

      showAppSuccessToast(l10n.websites_switchedTo(targetName));
      if (context.mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      final message = error is AppNetworkException
          ? error.message
          : error.toString();
      showAppErrorToast(l10n.websites_switchFailed, description: message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.isPhp, required this.runtimeName});

  final bool isPhp;
  final String runtimeName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                (isPhp
                        ? CupertinoColors.systemPurple
                        : CupertinoColors.systemGrey)
                    .resolveFrom(context)
                    .withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPhp ? TablerIcons.brand_php : TablerIcons.file_type_html,
            size: 18,
            color:
                (isPhp
                        ? CupertinoColors.systemPurple
                        : CupertinoColors.systemGrey)
                    .resolveFrom(context),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPhp
                    ? context.l10n.websites_phpWebsite
                    : context.l10n.websites_staticSite,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isPhp
                    ? (runtimeName.isEmpty
                          ? context.l10n.websites_unknownRuntime
                          : runtimeName)
                    : context.l10n.websites_staticFileService,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: AppColors.secondaryLabel(context)),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
            context.l10n.websites_loadPhpRuntimesFailed,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryLabel(context),
            ),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: CupertinoColors.systemBlue.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
            onPressed: onRetry,
            child: Text(
              context.l10n.common_retry,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PHP runtime list provider.
@Riverpod(dependencies: [runtimeRepository])
Future<List<RuntimeDto>> _phpRuntimes(_PhpRuntimesRef ref) async {
  final repo = await ref.watch(runtimeRepositoryProvider.future);
  final result = await repo.searchRuntimes({
    'page': 1,
    'pageSize': 200,
    'type': 'php',
  });
  return result.items;
}
