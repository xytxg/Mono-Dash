import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/info_rows.dart';
import '../../../common/components/file_browser_picker_sheet.dart';
import '../providers/files_provider.dart';

class FileDecompressSheet extends ConsumerStatefulWidget {
  const FileDecompressSheet({super.key, required this.item});

  final FileItemDto item;

  static Future<void> show(BuildContext context, FileItemDto item) {
    return showActionSheet(
      context: context,
      builder: (context) => FileDecompressSheet(item: item),
    );
  }

  @override
  ConsumerState<FileDecompressSheet> createState() =>
      _FileDecompressSheetState();
}

class _FileDecompressSheetState extends ConsumerState<FileDecompressSheet> {
  late TextEditingController _dstController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 默认解压路径为当前目录
    final currentPath =
        ref.read(filesControllerProvider).valueOrNull?.currentPath ?? '/';
    _dstController = TextEditingController(text: currentPath);
  }

  @override
  void dispose() {
    _dstController.dispose();
    super.dispose();
  }

  String _getArchiveType() {
    final ext = widget.item.extension.toLowerCase();
    if (ext.isEmpty) return 'zip';
    // 移除点
    return ext.startsWith('.') ? ext.substring(1) : ext;
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final dst = _dstController.text.trim();
    if (dst.isEmpty) {
      showAppErrorToast(l10n.files_decompressPathRequired);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(filesControllerProvider.notifier)
          .decompressFile(
            path: widget.item.path,
            type: _getArchiveType(),
            dst: dst,
          );
      if (mounted) {
        showAppSuccessToast(l10n.files_decompressStarted);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          l10n.files_decompressFailed,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      showHandle: false,
      isAdaptive: true,
      hasHorizontalPadding: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.files_decompressTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.label(context),
              ),
            ),
            _isSubmitting
                ? const CupertinoActivityIndicator(radius: 8)
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: _submit,
                    child: Text(
                      context.l10n.files_decompressAction,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 基础信息
          _buildSection(context.l10n.files_detailsBasicInfo, [
            ConfigRow(
              label: context.l10n.files_fileName,
              value: widget.item.name,
              valueTextAlign: TextAlign.end,
            ),
            ConfigRow(
              label: context.l10n.files_detailsSize,
              value: formatBytes(widget.item.size),
              valueTextAlign: TextAlign.end,
            ),
            ConfigRow(
              label: context.l10n.files_detailsModifiedTime,
              value: widget.item.modTime.isNotEmpty
                  ? widget.item.modTime.split('.').first.replaceAll('T', ' ')
                  : '-',
              valueTextAlign: TextAlign.end,
            ),
          ]),
          const SizedBox(height: 20),

          // 2. 解压路径
          _buildLabel(context.l10n.files_decompressPath),
          _buildDestinationInput(),
          const SizedBox(height: 20),

          Text(
            context.l10n.files_decompressHint,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryLabel(context),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: children.asMap().entries.map((entry) {
                final isLast = entry.key == children.length - 1;
                return Column(
                  children: [
                    entry.value,
                    if (!isLast)
                      Container(
                        height: 0.5,
                        color: AppColors.separator(
                          context,
                        ).withValues(alpha: 0.1),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationInput() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _dstController,
              placeholder: context.l10n.files_decompressTargetPlaceholder,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(
                  context,
                ).withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                border: Border(
                  left: BorderSide(
                    color: AppColors.separator(context).withValues(alpha: 0.1),
                  ),
                  top: BorderSide(
                    color: AppColors.separator(context).withValues(alpha: 0.1),
                  ),
                  bottom: BorderSide(
                    color: AppColors.separator(context).withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _pickDestinationPath,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground(
                  context,
                ).withValues(alpha: 0.3),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
                border: Border.all(
                  color: AppColors.separator(context).withValues(alpha: 0.1),
                ),
              ),
              child: Icon(
                TablerIcons.folder_search,
                size: 20,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDestinationPath() async {
    final result = await FileBrowserPickerSheet.show(
      context,
      title: context.l10n.files_selectDecompressPath,
      confirmText: context.l10n.common_use,
      initialPath: _dstController.text.trim().isEmpty
          ? '/'
          : _dstController.text.trim(),
      selectionMode: FilePickerSelectionMode.directories,
    );
    if (!mounted || result == null) return;
    _dstController.text = result.path;
  }
}
