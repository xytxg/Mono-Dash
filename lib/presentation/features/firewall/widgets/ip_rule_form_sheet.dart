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

Future<void> showIpRuleFormSheet(
  BuildContext context, {
  RuleInfoDto? existingRule,
  VoidCallback? onSuccess,
}) async {
  await showActionSheet<void>(
    context: context,
    builder: (_) =>
        _IpRuleFormSheet(existingRule: existingRule, onSuccess: onSuccess),
  );
}

class _IpRuleFormSheet extends ConsumerStatefulWidget {
  const _IpRuleFormSheet({this.existingRule, this.onSuccess});

  final RuleInfoDto? existingRule;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<_IpRuleFormSheet> createState() => _IpRuleFormSheetState();
}

class _IpRuleFormSheetState extends ConsumerState<_IpRuleFormSheet> {
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;

  String _strategy = 'accept';
  bool _isLoading = false;
  bool _pickerExpanded = false;

  bool get _isEdit => widget.existingRule != null;

  @override
  void initState() {
    super.initState();
    final rule = widget.existingRule;
    _addressController = TextEditingController(
      text: (rule?.address == null || rule?.address == 'Anywhere')
          ? ''
          : rule!.address!,
    );
    _descriptionController = TextEditingController(
      text: rule?.description ?? '',
    );

    if (rule?.strategy != null) {
      _strategy = rule!.strategy!.toLowerCase() == 'drop' ? 'drop' : 'accept';
    }
  }

  @override
  void dispose() {
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
                  ? context.l10n.firewall_editIpRule
                  : context.l10n.firewall_newIpRule,
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
                label: context.l10n.firewall_ipAddress,
                child: _isEdit
                    ? _ReadOnlyValue(value: _addressController.text)
                    : _PlainTextField(
                        controller: _addressController,
                        placeholder: context.l10n.firewall_ipAddressPlaceholder,
                      ),
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
                  ? context.l10n.firewall_editIpHint
                  : context.l10n.firewall_createIpHint,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tertiaryLabel(context),
              ),
            ),
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

  Future<void> _submit() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      showAppErrorToast(context.l10n.firewall_ipRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final description = _descriptionController.text.trim();

      if (_isEdit) {
        final oldRule = widget.existingRule!;
        final oldBody = {
          'operation': 'remove',
          'address': oldRule.address,
          'strategy': oldRule.strategy,
          'description': oldRule.description ?? '',
        };
        final newBody = {
          'operation': 'add',
          'address': address,
          'strategy': _strategy,
          'description': description,
        };
        await ref
            .read(firewallIpRulesControllerProvider.notifier)
            .updateRule(oldRule: oldBody, newRule: newBody);
      } else {
        final body = {
          'operation': 'add',
          'address': address,
          'strategy': _strategy,
          'description': description,
        };
        await ref
            .read(firewallIpRulesControllerProvider.notifier)
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
}

class _PlainTextField extends StatelessWidget {
  const _PlainTextField({required this.controller, required this.placeholder});

  final TextEditingController controller;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(fontSize: 15, color: AppColors.label(context)),
        decoration: const BoxDecoration(),
        autocorrect: false,
        enableSuggestions: false,
      ),
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
