import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_picker.dart';

/// DNS provider types and their authorization field definitions.
const Map<String, List<_AuthField>> _providerAuthFields = {
  'AliYun': [
    _AuthField(key: 'accessKey', label: 'AccessKey', icon: TablerIcons.key),
    _AuthField(key: 'secretKey', label: 'SecretKey', icon: TablerIcons.lock),
  ],
  'AliESA': [
    _AuthField(key: 'accessKey', label: 'AccessKey', icon: TablerIcons.key),
    _AuthField(key: 'secretKey', label: 'SecretKey', icon: TablerIcons.lock),
  ],
  'AWSRoute53': [
    _AuthField(
      key: 'accessKeyId',
      label: 'AccessKey ID',
      icon: TablerIcons.key,
    ),
    _AuthField(
      key: 'secretAccessKey',
      label: 'SecretAccessKey',
      icon: TablerIcons.lock,
    ),
  ],
  'TencentCloud': [
    _AuthField(key: 'secretId', label: 'SecretId', icon: TablerIcons.id),
    _AuthField(key: 'secretKey', label: 'SecretKey', icon: TablerIcons.lock),
  ],
  'HuaweiCloud': [
    _AuthField(key: 'accessKey', label: 'AccessKey', icon: TablerIcons.key),
    _AuthField(key: 'secretKey', label: 'SecretKey', icon: TablerIcons.lock),
  ],
  'Godaddy': [
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
    _AuthField(key: 'apiSecret', label: 'API Secret', icon: TablerIcons.lock),
  ],
  'CloudFlare': [
    _AuthField(key: 'email', label: 'Email', icon: TablerIcons.mail),
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
  ],
  'Vercel': [_AuthField(key: 'token', label: 'Token', icon: TablerIcons.key)],
  'CloudDns': [
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
  ],
  'NameSilo': [
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
  ],
  'NameCheap': [
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
    _AuthField(key: 'userName', label: 'Username', icon: TablerIcons.user),
  ],
  'NameCom': [
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
    _AuthField(key: 'userName', label: 'Username', icon: TablerIcons.user),
  ],
  'Dynu': [_AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key)],
  'RegRu': [
    _AuthField(key: 'userName', label: 'Username', icon: TablerIcons.user),
    _AuthField(key: 'password', label: 'Password', icon: TablerIcons.lock),
  ],
  'FreeMyIP': [
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
  ],
  'BaiduCloud': [
    _AuthField(key: 'accessKey', label: 'AccessKey', icon: TablerIcons.key),
    _AuthField(key: 'secretKey', label: 'SecretKey', icon: TablerIcons.lock),
  ],
  'RainYun': [
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
  ],
  'WestCN': [
    _AuthField(key: 'userName', label: 'Username', icon: TablerIcons.user),
    _AuthField(key: 'password', label: 'Password', icon: TablerIcons.lock),
  ],
  'ClouDNS': [
    _AuthField(key: 'userId', label: 'User ID', icon: TablerIcons.user),
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
  ],
  'Spaceship': [
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
    _AuthField(key: 'apiSecret', label: 'API Secret', icon: TablerIcons.lock),
  ],
  'Ovh': [
    _AuthField(key: 'endpoint', label: 'Endpoint', icon: TablerIcons.link),
    _AuthField(
      key: 'applicationKey',
      label: 'Application Key',
      icon: TablerIcons.key,
    ),
    _AuthField(
      key: 'applicationSecret',
      label: 'Application Secret',
      icon: TablerIcons.lock,
    ),
    _AuthField(
      key: 'consumerKey',
      label: 'Consumer Key',
      icon: TablerIcons.shield,
    ),
  ],
  'AcmeDNS': [
    _AuthField(key: 'serverUrl', label: 'Server URL', icon: TablerIcons.link),
    _AuthField(key: 'userName', label: 'Username', icon: TablerIcons.user),
    _AuthField(key: 'password', label: 'Password', icon: TablerIcons.lock),
  ],
  'Volcengine': [
    _AuthField(key: 'accessKey', label: 'AccessKey', icon: TablerIcons.key),
    _AuthField(key: 'secretKey', label: 'SecretKey', icon: TablerIcons.lock),
  ],
  'PorkBun': [
    _AuthField(key: 'apiKey', label: 'API Key', icon: TablerIcons.key),
    _AuthField(
      key: 'apiSecretKey',
      label: 'API Secret Key',
      icon: TablerIcons.lock,
    ),
  ],
  'DnsPod': [
    _AuthField(key: 'id', label: 'ID', icon: TablerIcons.id),
    _AuthField(key: 'token', label: 'Token', icon: TablerIcons.key),
  ],
  'Technitium': [
    _AuthField(key: 'serverUrl', label: 'Server URL', icon: TablerIcons.link),
    _AuthField(key: 'userName', label: 'Username', icon: TablerIcons.user),
    _AuthField(key: 'password', label: 'Password', icon: TablerIcons.lock),
  ],
};

List<AppPickerOption<String>> _providerOptions(BuildContext context) {
  final l10n = context.l10n;
  return [
    AppPickerOption(value: 'AliYun', label: l10n.websites_dnsProviderAliYun),
    AppPickerOption(value: 'AliESA', label: l10n.websites_dnsProviderAliEsa),
    AppPickerOption(
      value: 'AWSRoute53',
      label: l10n.websites_dnsProviderAwsRoute53,
    ),
    AppPickerOption(
      value: 'TencentCloud',
      label: l10n.websites_dnsProviderTencentCloud,
    ),
    AppPickerOption(
      value: 'HuaweiCloud',
      label: l10n.websites_dnsProviderHuaweiCloud,
    ),
    AppPickerOption(
      value: 'Volcengine',
      label: l10n.websites_dnsProviderVolcengine,
    ),
    AppPickerOption(
      value: 'BaiduCloud',
      label: l10n.websites_dnsProviderBaiduCloud,
    ),
    AppPickerOption(value: 'RainYun', label: l10n.websites_dnsProviderRainYun),
    AppPickerOption(value: 'WestCN', label: l10n.websites_dnsProviderWestCn),
    AppPickerOption(
      value: 'CloudFlare',
      label: l10n.websites_dnsProviderCloudflare,
    ),
    AppPickerOption(value: 'Godaddy', label: l10n.websites_dnsProviderGoDaddy),
    AppPickerOption(value: 'Vercel', label: l10n.websites_dnsProviderVercel),
    AppPickerOption(
      value: 'CloudDns',
      label: l10n.websites_dnsProviderCloudDns,
    ),
    AppPickerOption(
      value: 'NameSilo',
      label: l10n.websites_dnsProviderNameSilo,
    ),
    AppPickerOption(
      value: 'NameCheap',
      label: l10n.websites_dnsProviderNameCheap,
    ),
    AppPickerOption(value: 'NameCom', label: l10n.websites_dnsProviderNameCom),
    AppPickerOption(value: 'Dynu', label: l10n.websites_dnsProviderDynu),
    AppPickerOption(value: 'RegRu', label: l10n.websites_dnsProviderRegRu),
    AppPickerOption(
      value: 'FreeMyIP',
      label: l10n.websites_dnsProviderFreeMyIp,
    ),
    AppPickerOption(value: 'ClouDNS', label: l10n.websites_dnsProviderClouDns),
    AppPickerOption(
      value: 'Spaceship',
      label: l10n.websites_dnsProviderSpaceship,
    ),
    AppPickerOption(value: 'Ovh', label: l10n.websites_dnsProviderOvh),
    AppPickerOption(value: 'AcmeDNS', label: l10n.websites_dnsProviderAcmeDns),
    AppPickerOption(value: 'PorkBun', label: l10n.websites_dnsProviderPorkBun),
    AppPickerOption(
      value: 'DnsPod',
      label: l10n.websites_dnsProviderDnsPodDeprecated,
    ),
    AppPickerOption(
      value: 'Technitium',
      label: l10n.websites_dnsProviderTechnitium,
    ),
  ];
}

class _AuthField {
  const _AuthField({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

/// Shows the DNS account create sheet.
Future<void> showDnsAccountCreateSheet(
  BuildContext context, {
  required Future<void> Function(DnsAccountCreateReq req) onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _DnsAccountFormSheet(onSubmit: onSubmit),
  );
}

/// Shows the DNS account edit sheet.
Future<void> showDnsAccountEditSheet(
  BuildContext context, {
  required DnsAccountDto account,
  required Future<void> Function(int id, Map<String, dynamic> req) onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) =>
        _DnsAccountFormSheet.edit(account: account, onEditSubmit: onSubmit),
  );
}

class _DnsAccountFormSheet extends StatefulWidget {
  // ignore: unused_element_parameter
  const _DnsAccountFormSheet({this.onSubmit, this.account, this.onEditSubmit});

  final Future<void> Function(DnsAccountCreateReq req)? onSubmit;
  final DnsAccountDto? account;
  final Future<void> Function(int id, Map<String, dynamic> req)? onEditSubmit;

  /// Edit mode constructor.
  const _DnsAccountFormSheet.edit({
    required DnsAccountDto this.account,
    required Future<void> Function(int id, Map<String, dynamic> req)
    this.onEditSubmit,
  }) : onSubmit = null;

  bool get isEdit => account != null;

  @override
  State<_DnsAccountFormSheet> createState() => _DnsAccountFormSheetState();
}

class _DnsAccountFormSheetState extends State<_DnsAccountFormSheet> {
  final _nameController = TextEditingController();
  late String _type;
  late Map<String, TextEditingController> _authControllers;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _type = account?.type ?? 'AliYun';
    _nameController.text = account?.name ?? '';
    _authControllers = _buildAuthControllers(_type, account?.authorization);
  }

  /// Builds authorization field controllers.
  ///
  /// Prefer predefined fields. In edit mode, unknown providers generate fields
  /// dynamically from existing authorization keys.
  Map<String, TextEditingController> _buildAuthControllers(
    String type,
    Map<String, dynamic>? existing,
  ) {
    final fields = _providerAuthFields[type];
    if (fields != null) {
      return {
        for (final field in fields)
          field.key: TextEditingController(
            text: existing?[field.key]?.toString() ?? '',
          ),
      };
    }
    // Unknown provider: generate fields from existing authorization data.
    if (existing != null && existing.isNotEmpty) {
      return {
        for (final entry in existing.entries)
          entry.key: TextEditingController(text: entry.value?.toString() ?? ''),
      };
    }
    return {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _authControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTypeChanged(String newType) {
    if (newType == _type) return;
    setState(() {
      _type = newType;
      for (final c in _authControllers.values) {
        c.dispose();
      }
      _authControllers = _buildAuthControllers(newType, null);
    });
  }

  Map<String, dynamic> _buildAuthorization() {
    return {
      for (final entry in _authControllers.entries)
        entry.key: entry.value.text.trim(),
    };
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppErrorToast(context.l10n.websites_dnsAccountNameRequired);
      return;
    }

    final auth = _buildAuthorization();
    for (final entry in auth.entries) {
      if (entry.value is String && (entry.value as String).isEmpty) {
        showAppErrorToast(context.l10n.websites_authFieldsRequired);
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      if (widget.isEdit) {
        await widget.onEditSubmit?.call(widget.account!.id, {
          'name': name,
          'type': _type,
          'authorization': auth,
        });
      } else {
        await widget.onSubmit?.call(
          DnsAccountCreateReq(name: name, type: _type, authorization: auth),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_operationFailed,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authFields = _providerAuthFields[_type] ?? [];
    return ActionSheetScaffold(
      isAdaptive: true,
      maxHeightFactor: 0.85,
      showHandle: false,
      contentPadding: EdgeInsets.zero,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
        child: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Text(
                widget.isEdit
                    ? l10n.websites_editDnsAccount
                    : l10n.websites_createDnsAccount,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const CupertinoActivityIndicator(radius: 10)
                  : Text(
                      widget.isEdit ? l10n.common_save : l10n.common_create,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: l10n.websites_basicInfo,
              icon: TablerIcons.info_circle,
            ),
            _buildTextField(
              controller: _nameController,
              label: l10n.websites_accountName,
              placeholder: l10n.websites_accountNameExample,
              icon: TablerIcons.tag,
            ),
            const SizedBox(height: 12),
            _buildPickerSection(
              icon: TablerIcons.cloud,
              label: l10n.websites_cloudProviderType,
              value: _type,
              options: _providerOptions(context),
              onChanged: _onTypeChanged,
            ),
            if (_authControllers.isNotEmpty) ...[
              const SizedBox(height: 18),
              AppSectionHeader(
                title: l10n.websites_authorizationInfo,
                icon: TablerIcons.shield_lock,
              ),
              for (int i = 0; i < _authControllers.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                () {
                  final key = _authControllers.keys.elementAt(i);
                  final predefined = authFields
                      .where((f) => f.key == key)
                      .firstOrNull;
                  return _buildTextField(
                    controller: _authControllers[key]!,
                    label: predefined?.label ?? key,
                    placeholder: l10n.websites_enterField(
                      predefined?.label ?? key,
                    ),
                    icon: predefined?.icon ?? TablerIcons.key,
                  );
                }(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.secondaryLabel(context)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            keyboardType: keyboardType,
            autocorrect: false,
            enableSuggestions: false,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.tertiaryBackground(
                context,
              ).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            style: TextStyle(color: AppColors.label(context), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerSection<T>({
    required IconData icon,
    required String label,
    required T value,
    required List<AppPickerOption<T>> options,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.secondaryLabel(context)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppInlinePicker<T>(
            options: options,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
