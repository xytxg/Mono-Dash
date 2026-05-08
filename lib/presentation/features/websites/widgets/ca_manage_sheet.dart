import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_confirm_sheet.dart';
import 'ca_create_sheet.dart';
import 'ca_obtain_sheet.dart';

/// Shows the self-signed CA management sheet.
Future<void> showCaManageSheet(
  BuildContext context, {
  required List<CaDto> accounts,
  required Future<void> Function(CaCreateReq req) onCreate,
  required Future<void> Function(CaObtainReq req) onObtain,
  required Future<CaDto> Function(int id) onDetail,
  required Future<void> Function(int id) onDelete,
  required Future<Response<dynamic>> Function(int id) onDownload,
  required VoidCallback onRefresh,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _CaManageSheet(
      accounts: accounts,
      onCreate: onCreate,
      onObtain: onObtain,
      onDetail: onDetail,
      onDelete: onDelete,
      onDownload: onDownload,
      onRefresh: onRefresh,
    ),
  );
}

class _CaManageSheet extends StatefulWidget {
  const _CaManageSheet({
    required this.accounts,
    required this.onCreate,
    required this.onObtain,
    required this.onDetail,
    required this.onDelete,
    required this.onDownload,
    required this.onRefresh,
  });

  final List<CaDto> accounts;
  final Future<void> Function(CaCreateReq req) onCreate;
  final Future<void> Function(CaObtainReq req) onObtain;
  final Future<CaDto> Function(int id) onDetail;
  final Future<void> Function(int id) onDelete;
  final Future<Response<dynamic>> Function(int id) onDownload;
  final VoidCallback onRefresh;

  @override
  State<_CaManageSheet> createState() => _CaManageSheetState();
}

class _CaManageSheetState extends State<_CaManageSheet> {
  int? _expandedId;
  CaDto? _detail;
  bool _loadingDetail = false;

  Future<void> _toggleDetail(CaDto ca) async {
    if (_expandedId == ca.id) {
      setState(() {
        _expandedId = null;
        _detail = null;
      });
      return;
    }

    setState(() {
      _expandedId = ca.id;
      _detail = null;
      _loadingDetail = true;
    });

    try {
      final detail = await widget.onDetail(ca.id);
      if (mounted && _expandedId == ca.id) {
        setState(() {
          _detail = detail;
          _loadingDetail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingDetail = false);
        showAppErrorToast(
          context.l10n.websites_loadDetailsFailed,
          description: e.toString(),
        );
      }
    }
  }

  Future<void> _handleDelete(CaDto ca) async {
    final confirmed = await showActionSheet<bool>(
      context: context,
      builder: (ctx) => AppConfirmSheet(
        title: context.l10n.websites_deleteCa,
        content: context.l10n.websites_deleteCaConfirm(
          ca.name.isEmpty ? 'CA #${ca.id}' : ca.name,
        ),
        icon: TablerIcons.trash,
        iconColor: CupertinoColors.systemRed,
        confirmText: context.l10n.common_delete,
        confirmColor: CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.onDelete(ca.id);
      if (_expandedId == ca.id) {
        setState(() {
          _expandedId = null;
          _detail = null;
        });
      }
      widget.onRefresh();
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_deleteFailed,
          description: e.toString(),
        );
      }
    }
  }

  Future<void> _handleDownload(CaDto ca) async {
    try {
      final resp = await widget.onDownload(ca.id);
      final fileName = _parseFileName(resp) ?? 'ca_${ca.id}.zip';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(resp.data as List<int>);

      await SharePlus.instance.share(
        ShareParams(
          title: fileName,
          subject: fileName,
          files: [XFile(file.path)],
          fileNameOverrides: [fileName],
        ),
      );
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_downloadFailed,
          description: e.toString(),
        );
      }
    }
  }

  String? _parseFileName(Response<dynamic> resp) {
    final disposition = resp.headers.value('content-disposition');
    if (disposition == null) return null;
    final match = RegExp(r"filename\*=utf-8''(.+)").firstMatch(disposition);
    if (match != null) return Uri.decodeComponent(match.group(1)!);
    final simple = RegExp(r'filename="([^"]+)"').firstMatch(disposition);
    return simple?.group(1);
  }

  Future<void> _openCreateSheet() async {
    await showCaCreateSheet(
      context,
      onSubmit: (req) async {
        await widget.onCreate(req);
        widget.onRefresh();
      },
    );
  }

  Future<void> _openObtainSheet(CaDto ca) async {
    await showCaObtainSheet(
      context,
      caId: ca.id,
      onSubmit: (req) async {
        await widget.onObtain(req);
        widget.onRefresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      maxHeightFactor: 0.85,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
        child: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.common_close,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Text(
                context.l10n.websites_selfSignedCa,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            const SizedBox(width: 64),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: context.l10n.websites_caList,
            icon: TablerIcons.list,
          ),
          if (widget.accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  context.l10n.websites_noSelfSignedCa,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
            )
          else
            ...widget.accounts.map(_buildCaRow),
          const SizedBox(height: 18),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.plus,
                iconColor: CupertinoColors.systemGreen,
                title: context.l10n.websites_createCa,
                subtitle: Text(
                  context.l10n.websites_createSelfSignedCaSubtitle,
                ),
                onTap: _openCreateSheet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaRow(CaDto ca) {
    final isExpanded = _expandedId == ca.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + name + CN, tap to expand/collapse.
          GestureDetector(
            onTap: () => _toggleDetail(ca),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    TablerIcons.shield_lock,
                    size: 24,
                    color: CupertinoColors.systemPurple,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ca.name.isEmpty ? 'CA #${ca.id}' : ca.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (ca.commonName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          ca.commonName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryLabel(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    TablerIcons.chevron_down,
                    size: 18,
                    color: AppColors.tertiaryLabel(context),
                  ),
                ),
              ],
            ),
          ),
          // Info chips, tap to expand/collapse.
          if (ca.organization.isNotEmpty ||
              ca.organizationUnit.isNotEmpty ||
              ca.country.isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _toggleDetail(ca),
              behavior: HitTestBehavior.opaque,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (ca.organization.isNotEmpty)
                    _buildInfoChip(TablerIcons.building, ca.organization),
                  if (ca.organizationUnit.isNotEmpty)
                    _buildInfoChip(
                      TablerIcons.users_group,
                      ca.organizationUnit,
                    ),
                  if (ca.country.isNotEmpty)
                    _buildInfoChip(TablerIcons.flag, ca.country),
                ],
              ),
            ),
          ],
          // Action buttons.
          const SizedBox(height: 10),
          Row(
            children: [
              _buildActionButton(
                icon: TablerIcons.certificate,
                label: context.l10n.websites_issue,
                color: CupertinoColors.activeBlue,
                onTap: () => _openObtainSheet(ca),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: TablerIcons.download,
                label: context.l10n.websites_export,
                color: CupertinoColors.systemOrange,
                onTap: () => _handleDownload(ca),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => _handleDelete(ca),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        TablerIcons.trash,
                        size: 14,
                        color: CupertinoColors.systemRed.resolveFrom(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.common_delete,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.systemRed.resolveFrom(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Expanded detail area.
          if (isExpanded) _buildDetailSection(),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    if (_loadingDetail) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CupertinoActivityIndicator(radius: 10)),
      );
    }

    final d = _detail;
    if (d == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(context.l10n.websites_keyAlgorithm, d.keyType),
          _buildDetailRow(context.l10n.websites_commonNameShort, d.commonName),
          _buildDetailRow(context.l10n.websites_countryRegionShort, d.country),
          _buildDetailRow(context.l10n.websites_organization, d.organization),
          _buildDetailRow(
            context.l10n.websites_organizationUnitShort,
            d.organizationUnit,
          ),
          _buildDetailRow(context.l10n.websites_province, d.province),
          _buildDetailRow(context.l10n.websites_cityShort, d.city),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tertiaryLabel(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: AppColors.label(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.label(context).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.tertiaryLabel(context)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
