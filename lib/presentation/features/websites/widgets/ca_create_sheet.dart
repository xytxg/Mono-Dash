import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_picker.dart';

const _keyTypeOptions = [
  AppPickerOption(value: 'P256', label: 'P256'),
  AppPickerOption(value: 'P384', label: 'P384'),
  AppPickerOption(value: '2048', label: '2048'),
  AppPickerOption(value: '4096', label: '4096'),
];

/// Shows the self-signed CA creation sheet.
Future<void> showCaCreateSheet(
  BuildContext context, {
  required Future<void> Function(CaCreateReq req) onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _CaCreateSheet(onSubmit: onSubmit),
  );
}

class _CaCreateSheet extends StatefulWidget {
  const _CaCreateSheet({required this.onSubmit});

  final Future<void> Function(CaCreateReq req) onSubmit;

  @override
  State<_CaCreateSheet> createState() => _CaCreateSheetState();
}

class _CaCreateSheetState extends State<_CaCreateSheet> {
  final _nameController = TextEditingController();
  final _commonNameController = TextEditingController();
  final _countryController = TextEditingController(text: 'CN');
  final _organizationController = TextEditingController();
  final _organizationUnitController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  String _keyType = 'P256';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commonNameController.dispose();
    _countryController.dispose();
    _organizationController.dispose();
    _organizationUnitController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final commonName = _commonNameController.text.trim();
    if (name.isEmpty || commonName.isEmpty) {
      showAppErrorToast(context.l10n.websites_caNameRequired);
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        CaCreateReq(
          name: name,
          commonName: commonName,
          country: _countryController.text.trim(),
          organization: _organizationController.text.trim(),
          organizationUnit: _organizationUnitController.text.trim(),
          province: _provinceController.text.trim(),
          city: _cityController.text.trim(),
          keyType: _keyType,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_createFailed,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                context.l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Text(
                context.l10n.websites_createCa,
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
                      context.l10n.common_create,
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
              title: context.l10n.websites_basicInfo,
              icon: TablerIcons.info_circle,
            ),
            _buildTextField(
              controller: _nameController,
              label: context.l10n.websites_caName,
              placeholder: context.l10n.websites_caNamePlaceholder,
              icon: TablerIcons.tag,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _commonNameController,
              label: context.l10n.websites_commonName,
              placeholder: context.l10n.websites_commonNamePlaceholder,
              icon: TablerIcons.certificate,
            ),
            const SizedBox(height: 12),
            _buildPickerSection(
              icon: TablerIcons.key,
              label: context.l10n.websites_keyAlgorithm,
              value: _keyType,
              options: _keyTypeOptions,
              onChanged: (v) => setState(() => _keyType = v),
            ),
            const SizedBox(height: 18),
            AppSectionHeader(
              title: context.l10n.websites_organizationInfo,
              icon: TablerIcons.building,
            ),
            _buildTextField(
              controller: _countryController,
              label: context.l10n.websites_countryRegion,
              placeholder: context.l10n.websites_countryRegionPlaceholder,
              icon: TablerIcons.flag,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _organizationController,
              label: context.l10n.websites_organizationName,
              placeholder: context.l10n.websites_organizationNamePlaceholder,
              icon: TablerIcons.building,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _organizationUnitController,
              label: context.l10n.websites_organizationUnit,
              placeholder: context.l10n.websites_organizationUnitPlaceholder,
              icon: TablerIcons.users_group,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _provinceController,
              label: context.l10n.websites_provinceState,
              placeholder: context.l10n.websites_provincePlaceholder,
              icon: TablerIcons.map_pin,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _cityController,
              label: context.l10n.websites_city,
              placeholder: context.l10n.websites_cityPlaceholder,
              icon: TablerIcons.building_community,
            ),
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
