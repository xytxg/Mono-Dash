import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../models/panel_settings_view_state.dart';
import '../providers/panel_settings_provider.dart';

/// 显示 API 接口配置弹窗。
Future<void> showApiInterfaceSheet(
  BuildContext context, {
  required PanelSettingsViewState state,
}) {
  return showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (_) => _ApiInterfaceSheet(initialState: state),
  );
}

class _ApiInterfaceSheet extends ConsumerStatefulWidget {
  const _ApiInterfaceSheet({required this.initialState});

  final PanelSettingsViewState initialState;

  @override
  ConsumerState<_ApiInterfaceSheet> createState() => _ApiInterfaceSheetState();
}

class _ApiInterfaceSheetState extends ConsumerState<_ApiInterfaceSheet> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _whitelistController;
  late final TextEditingController _validityController;
  late bool _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialState.apiEnabled;
    _apiKeyController = TextEditingController(text: widget.initialState.apiKey);
    _whitelistController = TextEditingController(
      text: widget.initialState.ipWhiteList,
    );
    _validityController = TextEditingController(
      text: '${widget.initialState.apiKeyValidityTime}',
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _whitelistController.dispose();
    _validityController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final controller = ref.read(panelSettingsControllerProvider.notifier);
      await controller.updateApiConfig(
        apiKey: _apiKeyController.text,
        ipWhiteList: _whitelistController.text,
        apiInterfaceStatus: _enabled ? 'Enable' : 'Disable',
        apiKeyValidityTime:
            int.tryParse(_validityController.text) ??
            widget.initialState.apiKeyValidityTime,
      );
      if (mounted) {
        showAppSuccessToast(context.l10n.common_saved);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.panelSettings_saveFailed,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      isFloating: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  TablerIcons.api,
                  size: 24,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.panelSettings_apiInterface,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.label(context),
                  ),
                ),
              ],
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGeneralSection(),
          const SizedBox(height: 24),
          _buildKeySection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: _saving ? null : _handleSave,
              child: _saving
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    )
                  : Text(
                      context.l10n.panelSettings_saveSettings,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: context.l10n.panelSettings_general,
          icon: TablerIcons.settings_automation,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              title: context.l10n.panelSettings_enableApi,
              subtitle: Text(context.l10n.panelSettings_enableApiSubtitle),
              trailing: CupertinoSwitch(
                value: _enabled,
                onChanged: (val) => setState(() => _enabled = val),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: context.l10n.panelSettings_credentials,
          icon: TablerIcons.key,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              title: context.l10n.panelSettings_apiKey,
              subtitle: Text(
                _apiKeyController.text,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: _apiKeyController.text));
                showAppSuccessToast(context.l10n.panelSettings_keyCopied);
              },
              trailing: const Icon(
                TablerIcons.copy,
                size: 18,
                color: CupertinoColors.activeBlue,
              ),
            ),
            AppActionRow(
              title: context.l10n.panelSettings_resetKey,
              subtitle: Text(context.l10n.panelSettings_resetKeySubtitle),
              onTap: _onResetKey,
              trailing: Icon(
                TablerIcons.refresh,
                size: 18,
                color: CupertinoColors.systemRed.resolveFrom(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: context.l10n.panelSettings_securitySettings,
          icon: TablerIcons.shield_check,
        ),
        AppActionGroup(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.panelSettings_ipWhitelist,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _whitelistController,
                    placeholder:
                        context.l10n.panelSettings_apiWhitelistPlaceholder,
                    maxLines: 3,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: const BoxDecoration(),
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.label(context),
                    ),
                  ),
                ],
              ),
            ),
            AppActionRow(
              title: context.l10n.panelSettings_validityMinutes,
              subtitle: Text(context.l10n.panelSettings_apiValiditySubtitle),
              trailing: SizedBox(
                width: 80,
                child: CupertinoTextField(
                  controller: _validityController,
                  placeholder: context.l10n.panelSettings_minutesPlaceholder,
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.number,
                  padding: EdgeInsets.zero,
                  decoration: const BoxDecoration(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label(context),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            context.l10n.panelSettings_apiSecurityTip,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryLabel(context).withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  void _onResetKey() async {
    final confirmed = await showActionSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AppConfirmSheet(
        title: context.l10n.panelSettings_resetApiKeyTitle,
        content: context.l10n.panelSettings_resetApiKeyContent,
        confirmText: context.l10n.panelSettings_confirmReset,
        confirmColor: CupertinoColors.systemRed,
        icon: TablerIcons.alert_triangle,
        iconColor: CupertinoColors.systemRed,
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final controller = ref.read(panelSettingsControllerProvider.notifier);
      final newKey = await controller.generateApiKey();
      if (mounted) {
        _apiKeyController.text = newKey;
        showAppSuccessToast(context.l10n.panelSettings_keyReset);
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.panelSettings_resetFailed,
          description: e.toString(),
        );
      }
    }
  }
}
