import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../utils/file_icon_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/info_rows.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../providers/files_provider.dart';

class FileDetailsSheet extends ConsumerStatefulWidget {
  const FileDetailsSheet({super.key, required this.item});

  final FileItemDto item;

  static Future<void> show(BuildContext context, FileItemDto item) {
    return showActionSheet(
      context: context,
      builder: (context) => FileDetailsSheet(item: item),
    );
  }

  @override
  ConsumerState<FileDetailsSheet> createState() => _FileDetailsSheetState();
}

class _FileDetailsSheetState extends ConsumerState<FileDetailsSheet> {
  late Future<FileItemDto> _detailFuture;
  int? _calculatedSize;
  bool _isCalculatingSize = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchDetails();
  }

  Future<FileItemDto> _fetchDetails() async {
    final repo = await ref.read(fileRepositoryProvider.future);
    return repo.getFileContent(path: widget.item.path, isDetail: true);
  }

  Future<void> _calculateSize() async {
    if (_isCalculatingSize) return;
    setState(() => _isCalculatingSize = true);
    try {
      final repo = await ref.read(fileRepositoryProvider.future);
      final size = await repo.getFileSize(widget.item.path);
      if (mounted) {
        setState(() {
          _calculatedSize = size;
          _isCalculatingSize = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCalculatingSize = false);
        showAppErrorToast(context.l10n.files_detailsCalculateSizeFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      showHandle: false,
      isAdaptive: true,
      isFloating: false,
      hasHorizontalPadding: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.files_detailsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.label(context),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.l10n.common_done,
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
      child: FutureBuilder<FileItemDto>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(FileItemDto detail) {
    final modTime = DateTime.tryParse(detail.modTime)?.toLocal();
    final modTimeStr = modTime != null
        ? '${modTime.year}-${modTime.month.toString().padLeft(2, '0')}-${modTime.day.toString().padLeft(2, '0')} ${modTime.hour.toString().padLeft(2, '0')}:${modTime.minute.toString().padLeft(2, '0')}:${modTime.second.toString().padLeft(2, '0')}'
        : context.l10n.common_unknown;

    return Column(
      children: [
        _buildHeader(detail),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: context.l10n.files_detailsBasicInfo,
          children: [
            ConfigRow(
              label: context.l10n.files_detailsPath,
              value: detail.path,
              valueTextAlign: TextAlign.end,
              labelFlex: 1,
              valueFlex: 3,
            ),
            // 双重保险：如果详情接口没回，就用列表传进来的数据
            if ((detail.isSymlink || widget.item.isSymlink) &&
                (detail.linkPath.isNotEmpty || widget.item.linkPath.isNotEmpty))
              ConfigRow(
                label: context.l10n.files_detailsLinkTarget,
                value: detail.linkPath.isNotEmpty
                    ? detail.linkPath
                    : widget.item.linkPath,
                valueTextAlign: TextAlign.end,
                labelFlex: 1,
                valueFlex: 3,
                valueStyle: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ConfigRow(
              label: context.l10n.files_detailsType,
              value: detail.isDir
                  ? context.l10n.files_detailsDirectoryType
                  : (detail.extension.isEmpty
                        ? context.l10n.files_detailsFileType
                        : detail.extension.toUpperCase()),
              valueTextAlign: TextAlign.end,
            ),
            ConfigRow(
              label: context.l10n.files_detailsSize,
              value: detail.isDir
                  ? context.l10n.files_detailsCalculate
                  : formatBytes(detail.size),
              valueTextAlign: TextAlign.end,
              onTap:
                  detail.isDir && _calculatedSize == null && !_isCalculatingSize
                  ? _calculateSize
                  : null,
              valueWidget: _isCalculatingSize
                  ? const Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoActivityIndicator(radius: 8),
                    )
                  : (_calculatedSize != null
                        ? Text(
                            formatBytes(_calculatedSize!),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.label(context),
                            ),
                          )
                        : (detail.isDir
                              ? Text(
                                  context.l10n.files_detailsTapToCalculate,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.activeBlue
                                        .resolveFrom(context),
                                  ),
                                )
                              : null)),
            ),
            ConfigRow(
              label: context.l10n.files_detailsModifiedTime,
              value: modTimeStr,
              valueTextAlign: TextAlign.end,
            ),
            if (detail.shareCode.isNotEmpty || widget.item.shareCode.isNotEmpty)
              ConfigRow(
                label: context.l10n.files_detailsShareCode,
                value: detail.shareCode.isNotEmpty
                    ? detail.shareCode
                    : widget.item.shareCode,
                valueTextAlign: TextAlign.end,
                valueStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGreen,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: context.l10n.files_detailsPermissionsOwner,
          children: [
            ConfigRow(
              label: context.l10n.files_detailsPermissionMode,
              value:
                  '${detail.mode} (${formatPermissions(detail.mode, detail.isDir)})',
              valueTextAlign: TextAlign.end,
            ),
            ConfigRow(
              label: context.l10n.files_detailsOwner,
              value: '${detail.user} (UID: ${detail.uid})',
              valueTextAlign: TextAlign.end,
            ),
            ConfigRow(
              label: context.l10n.files_detailsGroup,
              value: '${detail.group} (GID: ${detail.gid})',
              valueTextAlign: TextAlign.end,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(FileItemDto detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildFileIcon(detail),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.label(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (detail.mimeType.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail.mimeType,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(FileItemDto detail) {
    // 同步符号链接和分享状态，确保徽标正确显示
    final displayItem = detail.copyWith(
      isSymlink: detail.isSymlink || widget.item.isSymlink,
      shareCode: detail.shareCode.isNotEmpty
          ? detail.shareCode
          : widget.item.shareCode,
    );
    return FileIconUtils.buildIcon(context, displayItem, size: 40);
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryLabel(context).withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ),
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

  Widget _buildLoading() {
    return Column(
      children: [
        const SkeletonItem(
          width: double.infinity,
          height: 80,
          borderRadius: 16,
        ),
        const SizedBox(height: 24),
        const SkeletonItem(
          width: double.infinity,
          height: 120,
          borderRadius: 14,
        ),
        const SizedBox(height: 24),
        const SkeletonItem(
          width: double.infinity,
          height: 100,
          borderRadius: 14,
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 40,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.files_detailsLoadFailed,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.label(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
