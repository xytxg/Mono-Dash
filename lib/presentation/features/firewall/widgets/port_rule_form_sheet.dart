import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/firewall/rule_info_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_picker.dart';
import '../../../common/components/cupertino_grouped_form.dart';
import '../providers/firewall_provider.dart';

Future<void> showPortRuleFormSheet(
  BuildContext context, {
  RuleInfoDto? existingRule,
  VoidCallback? onSuccess,
}) async {
  await showActionSheet<void>(
    context: context,
    builder: (_) =>
        _PortRuleFormSheet(existingRule: existingRule, onSuccess: onSuccess),
  );
}

class _PortRuleFormSheet extends ConsumerStatefulWidget {
  const _PortRuleFormSheet({this.existingRule, this.onSuccess});

  final RuleInfoDto? existingRule;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<_PortRuleFormSheet> createState() => _PortRuleFormSheetState();
}

class _PortRuleFormSheetState extends ConsumerState<_PortRuleFormSheet> {
  late final TextEditingController _portController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;

  String _protocol = 'tcp';
  String _strategy = 'accept';
  String _source = 'anyWhere';
  bool _isLoading = false;
  bool _pickerExpanded = false;

  bool get _isEdit => widget.existingRule != null;

  @override
  void initState() {
    super.initState();
    final rule = widget.existingRule;
    _portController = TextEditingController(text: rule?.port ?? '');
    _addressController = TextEditingController(
      text:
          (rule?.address == null ||
              rule?.address == 'Anywhere' ||
              rule?.address == '0.0.0.0/0')
          ? ''
          : rule!.address!,
    );
    _descriptionController = TextEditingController(
      text: rule?.description ?? '',
    );
    _source = (rule == null || rule.isAnyAddress) ? 'anyWhere' : 'address';

    if (rule?.protocol != null) {
      switch (rule!.protocol!) {
        case 'tcp':
          _protocol = 'tcp';
          break;
        case 'udp':
          _protocol = 'udp';
          break;
        case 'tcp/udp':
          _protocol = 'tcp/udp';
          break;
      }
    }
    if (rule?.strategy != null) {
      _strategy = rule!.strategy!.toLowerCase() == 'drop' ? 'drop' : 'accept';
    }
  }

  @override
  void dispose() {
    _portController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      hasHorizontalPadding: true,
      contentPadding: EdgeInsets.zero,
      scrollPhysics: _pickerExpanded
          ? const NeverScrollableScrollPhysics()
          : null,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.l10n.common_cancel,
                  style: TextStyle(
                    color: AppColors.secondaryLabel(context),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Text(
              _isEdit
                  ? context.l10n.firewall_editPortRule
                  : context.l10n.firewall_newPortRule,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
                letterSpacing: -0.4,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CupertinoActivityIndicator(radius: 10)
                    : Text(
                        _isEdit
                            ? context.l10n.common_save
                            : context.l10n.common_create,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.activeBlue.resolveFrom(
                            context,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCupertinoSectionHeader(title: context.l10n.firewall_ruleInfo),
          AppCupertinoGroupedBox(
            children: [
              AppCupertinoFormTile(
                label: context.l10n.firewall_port,
                child: _isEdit
                    ? _ReadOnlyValue(value: _portController.text)
                    : _PlainTextField(
                        controller: _portController,
                        placeholder: context.l10n.firewall_portPlaceholder,
                      ),
              ),
              AppCupertinoFormTile(
                label: context.l10n.firewall_protocol,
                child: _buildProtocolPicker(context),
              ),
              AppCupertinoFormTile(
                label: context.l10n.firewall_strategy,
                isLast: true,
                child: _buildStrategyPicker(context),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(
              _isEdit
                  ? context.l10n.firewall_editPortHint
                  : context.l10n.firewall_createPortHint,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tertiaryLabel(context),
              ),
            ),
          ),

          const SizedBox(height: 24),
          AppCupertinoSectionHeader(title: context.l10n.firewall_source),
          AppCupertinoGroupedBox(
            children: [
              AppCupertinoFormTile(
                label: context.l10n.firewall_range,
                isLast: _source != 'address',
                child: _buildSourcePicker(context),
              ),
              if (_source == 'address')
                AppCupertinoFormTile(
                  label: context.l10n.firewall_address,
                  isLast: true,
                  child: _PlainTextField(
                    controller: _addressController,
                    placeholder: context.l10n.firewall_addressPlaceholder,
                    maxLines: 3,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),
          AppCupertinoSectionHeader(
            title: context.l10n.firewall_descriptionOptional,
          ),
          AppCupertinoGroupedBox(
            children: [
              AppCupertinoFormTile(
                label: context.l10n.common_description,
                isLast: true,
                child: _PlainTextField(
                  controller: _descriptionController,
                  placeholder: context.l10n.firewall_descriptionPlaceholder,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProtocolPicker(BuildContext context) {
    const options = [
      AppPickerOption(value: 'tcp', label: 'TCP'),
      AppPickerOption(value: 'udp', label: 'UDP'),
      AppPickerOption(value: 'tcp/udp', label: 'TCP/UDP'),
    ];
    return AppInlinePicker<String>(
      value: _protocol,
      anchorHeight: 44,
      backgroundColor: CupertinoColors.transparent,
      options: options,
      onChanged: (value) => setState(() => _protocol = value),
      onExpandChanged: (expanded) => setState(() => _pickerExpanded = expanded),
    );
  }

  Widget _buildStrategyPicker(BuildContext context) {
    final options = [
      AppPickerOption(
        value: 'accept',
        label: context.l10n.firewall_acceptLabel,
      ),
      AppPickerOption(value: 'drop', label: context.l10n.firewall_dropLabel),
    ];
    return AppInlinePicker<String>(
      value: _strategy,
      anchorHeight: 44,
      backgroundColor: CupertinoColors.transparent,
      options: options,
      onChanged: (value) => setState(() => _strategy = value),
      onExpandChanged: (expanded) => setState(() => _pickerExpanded = expanded),
    );
  }

  Widget _buildSourcePicker(BuildContext context) {
    return AppInlinePicker<String>(
      value: _source,
      anchorHeight: 44,
      backgroundColor: CupertinoColors.transparent,
      options: [
        AppPickerOption(
          value: 'anyWhere',
          label: context.l10n.firewall_allAddresses,
        ),
        AppPickerOption(
          value: 'address',
          label: context.l10n.firewall_specificAddress,
        ),
      ],
      onChanged: (value) => setState(() => _source = value),
      onExpandChanged: (expanded) => setState(() => _pickerExpanded = expanded),
    );
  }

  Future<void> _submit() async {
    final port = _portController.text.trim();
    if (port.isEmpty) {
      showAppErrorToast(context.l10n.firewall_portRequired);
      return;
    }
    final portError = _validatePortInput(port);
    if (portError != null) {
      showAppErrorToast(portError);
      return;
    }

    final address = _source == 'anyWhere' ? '' : _addressController.text.trim();
    if (_source == 'address') {
      if (address.isEmpty) {
        showAppErrorToast(context.l10n.firewall_sourceAddressRequired);
        return;
      }
      final addressError = _validateAddressInput(address);
      if (addressError != null) {
        showAppErrorToast(addressError);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final description = _descriptionController.text.trim();

      if (_isEdit) {
        // 更新规则：先删旧的，再加新的
        final oldRule = widget.existingRule!;
        final oldBody = oldRule.toPortRuleJson(operation: 'remove');
        final newBody = {
          'operation': 'add',
          'chain': oldRule.chain ?? '',
          'port': port,
          'protocol': _protocol,
          'strategy': _strategy,
          'address': address,
          'description': description,
        };
        await ref
            .read(firewallPortRulesControllerProvider.notifier)
            .updateRule(oldRule: oldBody, newRule: newBody);
      } else {
        // 添加新规则
        final body = {
          'operation': 'add',
          'port': port,
          'protocol': _protocol,
          'strategy': _strategy,
          'address': address,
          'description': description,
        };
        await ref
            .read(firewallPortRulesControllerProvider.notifier)
            .addRule(body);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSuccessToast(
        _isEdit
            ? context.l10n.firewall_ruleUpdated
            : context.l10n.firewall_ruleAdded,
      );
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppErrorToast(
        context.l10n.firewall_operationFailed,
        description: e.toString(),
      );
    }
  }

  String? _validatePortInput(String value) {
    if (value.contains('-') && value.contains(',')) {
      return context.l10n.firewall_portListRangeMixed;
    }
    final parts = value.contains(',') ? value.split(',') : [value];
    for (final rawPart in parts) {
      final part = rawPart.trim();
      if (part.isEmpty) return context.l10n.firewall_portInvalidFormat;
      if (part.contains('-')) {
        final range = part.split('-');
        if (range.length != 2) {
          return context.l10n.firewall_portRangeInvalidFormat;
        }
        final start = int.tryParse(range[0].trim());
        final end = int.tryParse(range[1].trim());
        if (!_isValidPort(start) || !_isValidPort(end) || start! > end!) {
          return context.l10n.firewall_portRangeInvalid;
        }
      } else {
        final port = int.tryParse(part);
        if (!_isValidPort(port)) {
          return context.l10n.firewall_portInvalidRange;
        }
      }
    }
    return null;
  }

  bool _isValidPort(int? port) => port != null && port >= 1 && port <= 65535;

  String? _validateAddressInput(String value) {
    for (final rawPart in value.split(',')) {
      final part = rawPart.trim();
      if (part.isEmpty) return context.l10n.firewall_addressInvalidFormat;
      if (!_isValidIpOrCidr(part)) {
        return context.l10n.firewall_addressInvalidValue(part);
      }
    }
    return null;
  }

  bool _isValidIpOrCidr(String value) {
    final pieces = value.split('/');
    if (pieces.length > 2 || pieces.first.isEmpty) return false;
    final ip = pieces.first;
    final isIpv4 = _canParseIp(ip, ipv6: false);
    final isIpv6 = _canParseIp(ip, ipv6: true);
    if (!isIpv4 && !isIpv6) return false;
    if (pieces.length == 1) return true;
    final mask = int.tryParse(pieces.last);
    if (mask == null) return false;
    return isIpv4 ? mask >= 0 && mask <= 32 : mask >= 0 && mask <= 128;
  }

  bool _canParseIp(String value, {required bool ipv6}) {
    try {
      if (ipv6) {
        Uri.parseIPv6Address(value);
      } else {
        Uri.parseIPv4Address(value);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _PlainTextField extends StatelessWidget {
  const _PlainTextField({
    required this.controller,
    required this.placeholder,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String placeholder;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final field = CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textAlignVertical: TextAlignVertical.center,
      maxLines: maxLines,
      minLines: 1,
      style: TextStyle(fontSize: 15, color: AppColors.label(context)),
      decoration: const BoxDecoration(),
      autocorrect: false,
      enableSuggestions: false,
    );

    if (maxLines == 1) {
      return SizedBox(height: 44, child: field);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: field,
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        value.isEmpty ? '-' : value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          color: AppColors.secondaryLabel(context),
        ),
      ),
    );
  }
}
