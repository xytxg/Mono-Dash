import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/file_browser_picker_sheet.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';

enum _SslUploadMode { paste, local, upload }

/// Shows the SSL certificate upload sheet.
Future<void> showSslUploadSheet(
  BuildContext context, {
  int? sslID,
  required Future<void> Function(
    String certificate,
    String privateKey, {
    int? sslID,
    String? description,
  })
  onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _SslUploadSheet(
      mode: _SslUploadMode.paste,
      sslID: sslID,
      onTextSubmit: onSubmit,
    ),
  );
}

Future<void> showSslUploadServerFileSheet(
  BuildContext context, {
  int? sslID,
  required Future<void> Function(
    String certificatePath,
    String privateKeyPath, {
    int? sslID,
    String? description,
  })
  onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _SslUploadSheet(
      mode: _SslUploadMode.local,
      sslID: sslID,
      onPathSubmit: onSubmit,
    ),
  );
}

Future<void> showSslUploadLocalFileSheet(
  BuildContext context, {
  int? sslID,
  required Future<void> Function(
    String certificatePath,
    String privateKeyPath, {
    int? sslID,
    String? description,
  })
  onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _SslUploadSheet(
      mode: _SslUploadMode.upload,
      sslID: sslID,
      onPathSubmit: onSubmit,
    ),
  );
}

class _SslUploadSheet extends StatefulWidget {
  const _SslUploadSheet({
    required this.mode,
    this.sslID,
    this.onTextSubmit,
    this.onPathSubmit,
  });

  final _SslUploadMode mode;
  final int? sslID;
  final Future<void> Function(
    String certificate,
    String privateKey, {
    int? sslID,
    String? description,
  })?
  onTextSubmit;
  final Future<void> Function(
    String certificatePath,
    String privateKeyPath, {
    int? sslID,
    String? description,
  })?
  onPathSubmit;

  @override
  State<_SslUploadSheet> createState() => _SslUploadSheetState();
}

class _SslUploadSheetState extends State<_SslUploadSheet> {
  final _certController = TextEditingController();
  final _keyController = TextEditingController();
  final _descController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _certController.dispose();
    _keyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cert = _certController.text.trim();
    final key = _keyController.text.trim();
    final desc = _descController.text.trim();
    if (cert.isEmpty || key.isEmpty) return;

    setState(() => _submitting = true);
    try {
      if (widget.mode == _SslUploadMode.paste) {
        await widget.onTextSubmit?.call(
          cert,
          key,
          sslID: widget.sslID,
          description: desc.isEmpty ? null : desc,
        );
      } else {
        // Local and upload modes both submit file paths.
        await widget.onPathSubmit?.call(
          cert,
          key,
          sslID: widget.sslID,
          description: desc.isEmpty ? null : desc,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_uploadFailed,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickServerFile(
    TextEditingController controller,
    String title,
  ) async {
    final result = await FileBrowserPickerSheet.show(
      context,
      initialPath: _parentPath(controller.text.trim()),
      title: title,
      confirmText: context.l10n.common_select,
      selectionMode: FilePickerSelectionMode.files,
    );
    if (!mounted || result == null) return;
    controller.text = result.path;
  }

  Future<void> _pickLocalFile(TextEditingController controller) async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (!mounted || result == null || result.files.isEmpty) return;

    final path = result.files.first.path;
    if (path == null || path.isEmpty) return;
    controller.text = path;
  }

  String _parentPath(String path) {
    if (path.isEmpty || !path.startsWith('/')) return '/';
    final normalized = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
    final index = normalized.lastIndexOf('/');
    if (index <= 0) return '/';
    return normalized.substring(0, index);
  }

  String _title(BuildContext context) {
    return switch (widget.mode) {
      _SslUploadMode.paste => context.l10n.websites_importFromText,
      _SslUploadMode.local => context.l10n.websites_selectServerFile,
      _SslUploadMode.upload => context.l10n.websites_uploadFromLocal,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                _title(context),
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
                      l10n.websites_upload,
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
            ...switch (widget.mode) {
              _SslUploadMode.paste => _buildPemFields(),
              _SslUploadMode.local => _buildServerFileFields(),
              _SslUploadMode.upload => _buildLocalFileFields(),
            },
            const SizedBox(height: 18),
            AppSectionHeader(
              title: l10n.websites_remarkOptional,
              icon: TablerIcons.notes,
            ),
            _buildDescField(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPemFields() {
    return [
      AppSectionHeader(
        title: context.l10n.websites_certificateContentPem,
        icon: TablerIcons.certificate,
      ),
      _buildCodeField(
        controller: _certController,
        placeholder:
            '-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----',
      ),
      const SizedBox(height: 18),
      AppSectionHeader(
        title: context.l10n.websites_privateKeyContentPem,
        icon: TablerIcons.key,
      ),
      _buildCodeField(
        controller: _keyController,
        placeholder:
            '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----',
      ),
    ];
  }

  List<Widget> _buildLocalFileFields() {
    return [
      AppSectionHeader(
        title: context.l10n.websites_certificateFile,
        icon: TablerIcons.certificate,
      ),
      _buildPathField(
        controller: _certController,
        placeholder: context.l10n.websites_tapToSelectCertificateFile,
        onBrowse: () => _pickLocalFile(_certController),
      ),
      const SizedBox(height: 18),
      AppSectionHeader(
        title: context.l10n.websites_privateKeyFile,
        icon: TablerIcons.key,
      ),
      _buildPathField(
        controller: _keyController,
        placeholder: context.l10n.websites_tapToSelectPrivateKeyFile,
        onBrowse: () => _pickLocalFile(_keyController),
      ),
    ];
  }

  List<Widget> _buildServerFileFields() {
    return [
      AppSectionHeader(
        title: context.l10n.websites_certificateFilePath,
        icon: TablerIcons.certificate,
      ),
      _buildPathField(
        controller: _certController,
        placeholder: '/path/to/fullchain.pem',
        onBrowse: () => _pickServerFile(
          _certController,
          context.l10n.websites_selectCertificateFile,
        ),
      ),
      const SizedBox(height: 18),
      AppSectionHeader(
        title: context.l10n.websites_privateKeyFilePath,
        icon: TablerIcons.key,
      ),
      _buildPathField(
        controller: _keyController,
        placeholder: '/path/to/privkey.pem',
        onBrowse: () => _pickServerFile(
          _keyController,
          context.l10n.websites_selectPrivateKeyFile,
        ),
      ),
    ];
  }

  Widget _buildCodeField({
    required TextEditingController controller,
    required String placeholder,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: 12,
      minLines: 6,
      autocorrect: false,
      enableSuggestions: false,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      style: TextStyle(
        color: AppColors.label(context),
        fontSize: 13,
        fontFamilyFallback: const ['SF Mono', 'Menlo', 'monospace'],
      ),
    );
  }

  Widget _buildPathField({
    required TextEditingController controller,
    required String placeholder,
    required VoidCallback onBrowse,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      autocorrect: false,
      enableSuggestions: false,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      suffix: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(34),
          onPressed: onBrowse,
          child: Icon(
            TablerIcons.folder_open,
            size: 20,
            color: CupertinoColors.activeBlue.resolveFrom(context),
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      style: TextStyle(color: AppColors.label(context), fontSize: 14),
    );
  }

  Widget _buildDescField() {
    return CupertinoTextField(
      controller: _descController,
      placeholder: context.l10n.websites_certificateRemarkPlaceholder,
      autocorrect: false,
      enableSuggestions: false,
      maxLines: 3,
      minLines: 2,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      style: TextStyle(color: AppColors.label(context), fontSize: 14),
    );
  }
}
