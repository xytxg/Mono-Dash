import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../../data/dto/file/file_share_dto.dart';
import '../../../../domain/entities/server.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_picker.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/info_rows.dart';
import '../../../common/components/app_notice_sheet.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../servers/providers/servers_provider.dart';
import '../providers/files_provider.dart';

class FileShareSheet extends ConsumerStatefulWidget {
  const FileShareSheet({super.key, required this.item});

  final FileItemDto item;

  static Future<void> show(BuildContext context, FileItemDto item) {
    return showActionSheet(
      context: context,
      builder: (context) => FileShareSheet(item: item),
    );
  }

  @override
  ConsumerState<FileShareSheet> createState() => _FileShareSheetState();
}

class _FileShareSheetState extends ConsumerState<FileShareSheet> {
  int _expireMinutes = 0; // 0 表示永久
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  FileShareDto? _shareResult;
  bool _showEditView = false;
  bool _isCopied = false;
  Timer? _copyTimer;
  String? _errorTitle;
  String? _errorMessage;
  bool _isUnsupportedVersion = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.shareCode.isNotEmpty) {
      _fetchShareDetail();
    }
  }

  Future<void> _fetchShareDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail = await ref
          .read(filesControllerProvider.notifier)
          .getFileShareDetail(widget.item.path);
      if (mounted) {
        setState(() {
          _shareResult = detail;
          _isLoading = false;
          if (detail != null) {
            _passwordController.text = detail.password ?? '';
            _expireMinutes = detail.permanent
                ? 0
                : 1440; // 默认显示 1 天，或者根据 expiresAt 计算
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // 如果查不到详情，可能已过期，保持 _shareResult 为空以允许重新创建
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _copyTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCreateShare() async {
    final l10n = context.l10n;
    setState(() {
      _isLoading = true;
      _errorTitle = null;
      _errorMessage = null;
      _isUnsupportedVersion = false;
    });
    try {
      final password = _passwordController.text.trim();
      final result = await ref
          .read(filesControllerProvider.notifier)
          .createFileShare(
            path: widget.item.path,
            expireMinutes: _expireMinutes,
            password: password.isEmpty ? "" : password,
          );
      if (mounted) {
        setState(() {
          _shareResult = result;
          _isLoading = false;
          _showEditView = false; // 更新成功后回到结果页
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e is AppNetworkException && e.statusCode == 404) {
            _isUnsupportedVersion = true;
            _errorTitle = l10n.files_shareUnsupportedTitle;
            _errorMessage = l10n.files_shareUnsupportedContent;
          } else {
            _errorTitle = l10n.files_shareFailedTitle;
            _errorMessage = e.toString();
          }
        });
      }
    }
  }

  void _copyShareInfo() {
    if (_shareResult == null) return;

    final serverId = ref.read(activeServerIdProvider);
    final servers = ref.read(serversNotifierProvider).valueOrNull ?? [];
    final server = servers.cast<Server?>().firstWhere(
      (s) => s?.id == serverId,
      orElse: () => null,
    );

    if (server == null) {
      setState(() {
        _isUnsupportedVersion = false;
        _errorTitle = context.l10n.files_shareConfigErrorTitle;
        _errorMessage = context.l10n.files_shareConfigErrorContent;
      });
      return;
    }

    final baseUrl = server.baseUrl.toString();
    final link = "$baseUrl/s/${_shareResult!.code}";
    final password = _shareResult!.password ?? _passwordController.text.trim();

    final text = password.isNotEmpty
        ? context.l10n.files_shareClipboardLinkPassword(link, password)
        : context.l10n.files_shareClipboardLink(link);

    Clipboard.setData(ClipboardData(text: text));

    // 按钮反馈逻辑
    _copyTimer?.cancel();
    setState(() => _isCopied = true);
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return AppNoticeSheet(
        title: _errorTitle ?? context.l10n.files_shareGenericErrorTitle,
        content: _errorMessage!,
        icon: _isUnsupportedVersion
            ? TablerIcons.puzzle_off
            : TablerIcons.alert_triangle,
        iconColor: _isUnsupportedVersion
            ? CupertinoColors.systemBlue
            : CupertinoColors.systemRed,
      );
    }

    final showResult = _shareResult != null && !_showEditView;

    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  TablerIcons.share,
                  size: 24,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.files_shareTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.label(context),
                  ),
                ),
              ],
            ),
            if (!showResult)
              _isLoading
                  ? const CupertinoActivityIndicator(radius: 8)
                  : CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: _handleCreateShare,
                      child: Text(
                        _shareResult != null
                            ? context.l10n.common_update
                            : context.l10n.common_create,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    )
            else
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
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
      child: showResult ? _buildResultView() : _buildCreateView(),
    );
  }

  Widget _buildCreateView() {
    final expireOptions = [
      AppPickerOption(value: 0, label: context.l10n.files_shareExpirePermanent),
      AppPickerOption(value: 60, label: context.l10n.files_shareExpireHours(1)),
      AppPickerOption(
        value: 360,
        label: context.l10n.files_shareExpireHours(6),
      ),
      AppPickerOption(
        value: 1440,
        label: context.l10n.files_shareExpireDays(1),
      ),
      AppPickerOption(
        value: 4320,
        label: context.l10n.files_shareExpireDays(3),
      ),
      AppPickerOption(
        value: 10080,
        label: context.l10n.files_shareExpireDays(7),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context.l10n.files_shareExpireLabel),
        AppInlinePicker<int>(
          options: expireOptions,
          value: _expireMinutes,
          onChanged: (val) => setState(() => _expireMinutes = val),
          anchorHeight: 44,
          backgroundColor: AppColors.secondaryBackground(
            context,
          ).withValues(alpha: 0.5),
        ),
        const SizedBox(height: 20),
        _buildLabel(context.l10n.files_sharePasswordOptional),
        CupertinoTextField(
          controller: _passwordController,
          placeholder: context.l10n.files_sharePasswordPlaceholder,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12.5),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.separator(context).withValues(alpha: 0.1),
            ),
          ),
          style: TextStyle(color: AppColors.label(context)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            context.l10n.files_shareFilePath(widget.item.path),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryLabel(context).withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Icon(
          TablerIcons.circle_check_filled,
          color: CupertinoColors.systemGreen,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.files_shareReady,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.label(context),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: context.l10n.files_shareDetailsTitle,
          children: [
            _buildInfoRow(context.l10n.files_fileName, widget.item.name),
            _buildInfoRow(context.l10n.files_shareFullPath, widget.item.path),
            _buildInfoRow(context.l10n.files_shareCode, _shareResult!.code),
            if (_passwordController.text.trim().isNotEmpty)
              _buildInfoRow(
                context.l10n.files_shareAccessPassword,
                _passwordController.text.trim(),
              ),
            _buildInfoRow(
              context.l10n.files_shareExpireLabel,
              _getExpireLabel(context),
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 32),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _copyShareInfo,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    _isCopied ? TablerIcons.check : TablerIcons.copy,
                    key: ValueKey(_isCopied),
                    size: 20,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.files_shareCopyLink,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 30), // 对齐占位：20(icon) + 10(spacing)
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 20,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => setState(() => _showEditView = true),
            child: Text(
              context.l10n.files_shareUpdateSettings,
              style: TextStyle(
                color: AppColors.secondaryLabel(context),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  final Set<String> _expandedRows = {};

  void _toggleRow(String label) {
    setState(() {
      if (_expandedRows.contains(label)) {
        _expandedRows.remove(label);
      } else {
        _expandedRows.add(label);
      }
    });
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    final isExpanded = _expandedRows.contains(label);

    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _toggleRow(label),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: isExpanded
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topRight,
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.label(context),
                      ),
                      maxLines: isExpanded ? null : 1,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Container(
            height: 0.5,
            margin: const EdgeInsets.only(left: 16),
            color: AppColors.separator(context).withValues(alpha: 0.1),
          ),
      ],
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
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getExpireLabel(BuildContext context) {
    if (_expireMinutes == 0) return context.l10n.files_shareExpirePermanent;
    if (_expireMinutes < 60) {
      return context.l10n.files_shareExpireMinutes(_expireMinutes);
    }
    if (_expireMinutes < 1440) {
      return context.l10n.files_shareExpireHours((_expireMinutes / 60).floor());
    }
    return context.l10n.files_shareExpireDays((_expireMinutes / 1440).floor());
  }
}
