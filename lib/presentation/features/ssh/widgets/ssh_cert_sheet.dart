import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/host/ssh_cert_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_picker.dart';
import '../../../common/components/app_action_picker_sheet.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../providers/ssh_cert_provider.dart';

// ── 入口 ────────────────────────────────────────────────────────────────────

/// 打开 SSH 密钥管理 sheet。
Future<void> showSshCertSheet(BuildContext context) {
  return showActionSheet<void>(
    context: context,
    builder: (_) => const _SshCertSheet(),
  );
}

// ── 主列表 ──────────────────────────────────────────────────────────────────

class _SshCertSheet extends ConsumerWidget {
  const _SshCertSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(sshCertControllerProvider);

    return ActionSheetScaffold(
      maxHeightFactor: 0.85,
      isAdaptive: false,
      showHandle: false,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Icon(
              TablerIcons.key,
              size: 22,
              color: CupertinoColors.systemGreen.resolveFrom(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.ssh_certManageTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
              onPressed: () => _showCertForm(context, ref),
              child: Icon(
                TablerIcons.plus,
                size: 22,
                color: CupertinoColors.activeBlue.resolveFrom(context),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
              onPressed: () => _syncCert(context, ref),
              child: Icon(
                TablerIcons.refresh,
                size: 20,
                color: CupertinoColors.activeBlue.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
      child: certsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CupertinoActivityIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(40),
          child: AppEmptyState(
            icon: TablerIcons.alert_triangle,
            title: context.l10n.common_loadingFailed,
            subtitle: e.toString(),
            actionLabel: context.l10n.common_retry,
            onAction: () =>
                ref.read(sshCertControllerProvider.notifier).refresh(),
          ),
        ),
        data: (certs) {
          if (certs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 60),
              child: AppEmptyState(
                icon: TablerIcons.key,
                title: context.l10n.ssh_certEmptyTitle,
                subtitle: context.l10n.ssh_certEmptySubtitle,
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            itemCount: certs.length,
            itemBuilder: (context, index) => _CertListItem(cert: certs[index]),
          );
        },
      ),
    );
  }

  Future<void> _syncCert(BuildContext context, WidgetRef ref) async {
    final confirmed = await showActionSheet<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: context.l10n.ssh_certSyncTitle,
        content: context.l10n.ssh_certSyncContent,
        confirmText: context.l10n.ssh_certSyncAction,
      ),
    );
    if (confirmed == true) {
      await ref.read(sshCertControllerProvider.notifier).syncCert();
    }
  }
}

// ── 列表项 ──────────────────────────────────────────────────────────────────

class _CertListItem extends StatelessWidget {
  const _CertListItem({required this.cert});

  final SshCertDto cert;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCertActions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGreen
                    .resolveFrom(context)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                TablerIcons.key,
                size: 18,
                color: CupertinoColors.systemGreen.resolveFrom(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cert.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      cert.encryptionMode.toUpperCase(),
                      if (cert.description.isNotEmpty) cert.description,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              TablerIcons.chevron_right,
              size: 16,
              color: AppColors.tertiaryLabel(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCertActions(BuildContext context) async {
    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(cert.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'view'),
            child: Text(context.l10n.common_view),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'edit'),
            child: Text(context.l10n.common_edit),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, 'delete'),
            child: Text(context.l10n.common_delete),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.l10n.common_cancel),
        ),
      ),
    );

    if (!context.mounted) return;

    switch (action) {
      case 'view':
        _showCertDetail(context);
        break;
      case 'edit':
        _showCertForm(context, existing: cert);
        break;
      case 'delete':
        // Delete is handled via ConsumerWidget pattern in parent
        break;
    }
  }

  void _showCertDetail(BuildContext context) {
    showActionSheet<void>(
      context: context,
      builder: (_) => _CertDetailSheet(cert: cert),
    );
  }

  void _showCertForm(BuildContext context, {SshCertDto? existing}) {
    showActionSheet<void>(
      context: context,
      builder: (_) => _CertFormSheet(existing: existing),
    );
  }
}

// ── 详情 ────────────────────────────────────────────────────────────────────

class _CertDetailSheet extends StatelessWidget {
  const _CertDetailSheet({required this.cert});

  final SshCertDto cert;

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      maxHeightFactor: 0.85,
      isAdaptive: false,
      showHandle: false,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Icon(
              TablerIcons.key,
              size: 22,
              color: CupertinoColors.systemGreen.resolveFrom(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                cert.name,
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
                context.l10n.common_close,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: context.l10n.ssh_encryptionMode,
              value: cert.encryptionMode.toUpperCase(),
            ),
            if (cert.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailRow(
                label: context.l10n.common_description,
                value: cert.description,
              ),
            ],
            const SizedBox(height: 12),
            _DetailRow(
              label: context.l10n.ssh_passphrase,
              value: _tryDecode(context, cert.passPhrase),
              canCopy: true,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: context.l10n.ssh_publicKey,
              value: _tryDecode(context, cert.publicKey),
              canCopy: true,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: context.l10n.ssh_privateKey,
              value: _tryDecode(context, cert.privateKey),
              canCopy: true,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  static String _tryDecode(BuildContext context, String base64Str) {
    if (base64Str.isEmpty) return '-';
    if (base64Str == '<UN-SET>') return context.l10n.ssh_unsynced;
    try {
      return utf8.decode(base64.decode(base64Str));
    } catch (_) {
      return base64Str;
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.canCopy = false,
    this.maxLines = 2,
  });

  final String label;
  final String value;
  final bool canCopy;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
              if (canCopy &&
                  value != '-' &&
                  value != context.l10n.ssh_unsynced) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    showAppSuccessToast(context.l10n.common_copiedToClipboard);
                  },
                  child: Icon(
                    TablerIcons.copy,
                    size: 14,
                    color: CupertinoColors.activeBlue.resolveFrom(context),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.separator(context).withValues(alpha: 0.18),
                width: 0.5,
              ),
            ),
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: AppColors.label(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 创建/编辑表单 ───────────────────────────────────────────────────────────

Future<void> _showCertForm(
  BuildContext context,
  WidgetRef ref, {
  SshCertDto? existing,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (_) => _CertFormSheet(existing: existing),
  );
}

class _CertFormSheet extends ConsumerStatefulWidget {
  const _CertFormSheet({this.existing});

  final SshCertDto? existing;

  @override
  ConsumerState<_CertFormSheet> createState() => _CertFormSheetState();
}

class _CertFormSheetState extends ConsumerState<_CertFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _passphraseController;
  late final TextEditingController _publicKeyController;
  late final TextEditingController _privateKeyController;
  late final TextEditingController _descriptionController;

  String _encryptionMode = 'ed25519';
  String _mode = 'generate';
  bool _isLoading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final cert = widget.existing;
    _nameController = TextEditingController(text: cert?.name ?? '');
    _passphraseController = TextEditingController(
      text: cert != null ? _tryDecode(cert.passPhrase) : '',
    );
    _publicKeyController = TextEditingController(
      text: cert != null ? _tryDecode(cert.publicKey) : '',
    );
    _privateKeyController = TextEditingController(
      text: cert != null ? _tryDecode(cert.privateKey) : '',
    );
    _descriptionController = TextEditingController(
      text: cert?.description ?? '',
    );
    if (cert != null) {
      _encryptionMode = cert.encryptionMode;
    }
  }

  String _tryDecode(String base64Str) {
    if (base64Str.isEmpty) return '';
    try {
      return utf8.decode(base64.decode(base64Str));
    } catch (_) {
      return base64Str;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passphraseController.dispose();
    _publicKeyController.dispose();
    _privateKeyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      maxHeightFactor: 0.85,
      isAdaptive: false,
      showHandle: false,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _isEdit ? context.l10n.ssh_editKey : context.l10n.ssh_createKey,
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormItem(
              context,
              label: context.l10n.ssh_name,
              icon: TablerIcons.letter_case,
              child: SizedBox(
                height: 46,
                child: CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'my-key',
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.separator(
                        context,
                      ).withValues(alpha: 0.18),
                      width: 0.5,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.label(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFormItem(
              context,
              label: context.l10n.ssh_encryptionMode,
              icon: TablerIcons.lock,
              child: _buildEncryptionPicker(context),
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 20),
              _buildFormItem(
                context,
                label: context.l10n.ssh_createMode,
                icon: TablerIcons.adjustments,
                child: _buildModePicker(context),
              ),
            ],
            const SizedBox(height: 20),
            _buildFormItem(
              context,
              label: context.l10n.ssh_passphraseOptional,
              icon: TablerIcons.password,
              child: SizedBox(
                height: 46,
                child: CupertinoTextField(
                  controller: _passphraseController,
                  placeholder: context.l10n.ssh_passphrasePlaceholder,
                  obscureText: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.separator(
                        context,
                      ).withValues(alpha: 0.18),
                      width: 0.5,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.label(context),
                  ),
                ),
              ),
            ),
            if (_mode == 'input' || _isEdit) ...[
              const SizedBox(height: 20),
              _buildFormItem(
                context,
                label: context.l10n.ssh_publicKey,
                icon: TablerIcons.key,
                child: CupertinoTextField(
                  controller: _publicKeyController,
                  placeholder: context.l10n.ssh_pastePublicKey,
                  maxLines: 4,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.separator(
                        context,
                      ).withValues(alpha: 0.18),
                      width: 0.5,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    color: AppColors.label(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildFormItem(
                context,
                label: context.l10n.ssh_privateKey,
                icon: TablerIcons.key,
                child: CupertinoTextField(
                  controller: _privateKeyController,
                  placeholder: context.l10n.ssh_pastePrivateKey,
                  maxLines: 6,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.separator(
                        context,
                      ).withValues(alpha: 0.18),
                      width: 0.5,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    color: AppColors.label(context),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _buildFormItem(
              context,
              label: context.l10n.ssh_descriptionOptional,
              icon: TablerIcons.file_text,
              child: SizedBox(
                height: 46,
                child: CupertinoTextField(
                  controller: _descriptionController,
                  placeholder: context.l10n.ssh_remarksPlaceholder,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.separator(
                        context,
                      ).withValues(alpha: 0.18),
                      width: 0.5,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.label(context),
                  ),
                ),
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
                        _isEdit
                            ? context.l10n.common_save
                            : context.l10n.common_create,
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
      ),
    );
  }

  Widget _buildEncryptionPicker(BuildContext context) {
    const options = [
      AppPickerOption(value: 'ed25519', label: 'ED25519'),
      AppPickerOption(value: 'ecdsa', label: 'ECDSA'),
      AppPickerOption(value: 'rsa', label: 'RSA'),
      AppPickerOption(value: 'dsa', label: 'DSA'),
    ];
    final selected = options.firstWhere(
      (o) => o.value == _encryptionMode,
      orElse: () => options.first,
    );

    return GestureDetector(
      onTap: () async {
        final result = await showAppActionPickerSheet<String>(
          context,
          title: context.l10n.ssh_selectEncryptionMode,
          options: options,
          selectedValue: _encryptionMode,
        );
        if (result != null) setState(() => _encryptionMode = result);
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.18),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              selected.label,
              style: TextStyle(fontSize: 16, color: AppColors.label(context)),
            ),
            const Spacer(),
            Icon(
              TablerIcons.chevron_down,
              size: 16,
              color: AppColors.tertiaryLabel(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModePicker(BuildContext context) {
    final options = [
      AppPickerOption(
        value: 'generate',
        label: context.l10n.ssh_generateAutomatically,
      ),
      AppPickerOption(value: 'input', label: context.l10n.ssh_manualInput),
    ];
    final selected = options.firstWhere(
      (o) => o.value == _mode,
      orElse: () => options.first,
    );

    return GestureDetector(
      onTap: () async {
        final result = await showAppActionPickerSheet<String>(
          context,
          title: context.l10n.ssh_createMode,
          options: options,
          selectedValue: _mode,
        );
        if (result != null) setState(() => _mode = result);
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.18),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              selected.label,
              style: TextStyle(fontSize: 16, color: AppColors.label(context)),
            ),
            const Spacer(),
            Icon(
              TablerIcons.chevron_down,
              size: 16,
              color: AppColors.tertiaryLabel(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
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
      ),
    );
  }

  String _encodeBase64(String value) {
    if (value.isEmpty) return '';
    return base64.encode(utf8.encode(value));
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppErrorToast(context.l10n.ssh_enterName);
      return;
    }

    setState(() => _isLoading = true);

    final req = SshCertOperateReq(
      id: widget.existing?.id,
      name: name,
      encryptionMode: _encryptionMode,
      mode: _isEdit ? '' : _mode,
      passPhrase: _encodeBase64(_passphraseController.text),
      publicKey: _encodeBase64(_publicKeyController.text),
      privateKey: _encodeBase64(_privateKeyController.text),
      description: _descriptionController.text.trim(),
    );

    final notifier = ref.read(sshCertControllerProvider.notifier);
    final ok = _isEdit
        ? await notifier.editCert(req)
        : await notifier.createCert(req);

    if (!mounted) return;
    if (ok) Navigator.of(context).pop();
    setState(() => _isLoading = false);
  }
}
