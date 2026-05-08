import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../providers/ssh_info_provider.dart';

Future<void> showPortEditSheet(
  BuildContext context, {
  required String currentPort,
}) async {
  await showActionSheet<void>(
    context: context,
    builder: (_) => _PortEditSheet(currentPort: currentPort),
  );
}

class _PortEditSheet extends ConsumerStatefulWidget {
  const _PortEditSheet({required this.currentPort});

  final String currentPort;

  @override
  ConsumerState<_PortEditSheet> createState() => _PortEditSheetState();
}

class _PortEditSheetState extends ConsumerState<_PortEditSheet> {
  late final TextEditingController _controller;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPort);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String input) {
    if (input.isEmpty) return context.l10n.ssh_portRequired;
    final parts = input.split(',').map((s) => s.trim()).toList();
    final seen = <int>{};
    for (final p in parts) {
      if (p.isEmpty) return context.l10n.ssh_portInvalidFormat;
      final port = int.tryParse(p);
      if (port == null || port < 1 || port > 65535) {
        return context.l10n.ssh_portInvalidRange;
      }
      if (!seen.add(port)) return context.l10n.ssh_portDuplicate;
    }
    return null;
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    final err = _validate(text);
    if (err != null) {
      setState(() => _errorText = err);
      return;
    }

    setState(() => _isLoading = true);
    final ok = await ref
        .read(sshInfoControllerProvider.notifier)
        .updateConfig('Port', text);
    if (!mounted) return;
    if (ok) Navigator.of(context).pop();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Icon(
              TablerIcons.plug,
              size: 22,
              color: CupertinoColors.activeBlue.resolveFrom(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.ssh_editPort,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormItem(
            context,
            label: context.l10n.ssh_port,
            icon: TablerIcons.plug,
            child: SizedBox(
              height: 46,
              child: CupertinoTextField(
                controller: _controller,
                placeholder: context.l10n.ssh_portPlaceholder,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.separator(context).withValues(alpha: 0.18),
                    width: 0.5,
                  ),
                ),
                style: TextStyle(fontSize: 16, color: AppColors.label(context)),
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
              ),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemRed,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            context.l10n.ssh_portHint,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.tertiaryLabel(context),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: CupertinoColors.activeBlue.resolveFrom(context),
              borderRadius: BorderRadius.circular(14),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CupertinoActivityIndicator(
                      radius: 10,
                      color: CupertinoColors.white,
                    )
                  : Text(
                      context.l10n.common_save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.secondaryLabel(context)),
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
        ),
        child,
      ],
    );
  }
}
