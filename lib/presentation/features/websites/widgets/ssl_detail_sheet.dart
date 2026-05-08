import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/frosted_dialog.dart';
import '../utils/ssl_ui_helper.dart';

void showSslDetailSheet(
  BuildContext context, {
  required SslManageDto ssl,
  required Future<void> Function(int id) onDelete,
  required Future<void> Function(int id) onObtain,
  required Future<SslManageDto> Function(int id) onRefresh,
}) {
  showActionSheet<void>(
    context: context,
    builder: (ctx) => _SslDetailSheet(
      ssl: ssl,
      onDelete: onDelete,
      onObtain: onObtain,
      onRefresh: onRefresh,
    ),
  );
}

class _SslDetailSheet extends StatefulWidget {
  const _SslDetailSheet({
    required this.ssl,
    required this.onDelete,
    required this.onObtain,
    required this.onRefresh,
  });

  final SslManageDto ssl;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(int id) onObtain;
  final Future<SslManageDto> Function(int id) onRefresh;

  @override
  State<_SslDetailSheet> createState() => _SslDetailSheetState();
}

class _SslDetailSheetState extends State<_SslDetailSheet> {
  late SslManageDto _ssl;

  @override
  void initState() {
    super.initState();
    _ssl = widget.ssl;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = SslUIHelper.getStatusColor(context, _ssl.status);

    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      maxHeightFactor: 0.86,
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen
                .resolveFrom(context)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              TablerIcons.certificate,
              size: 30,
              color: CupertinoColors.systemGreen.resolveFrom(context),
            ),
          ),
        ),
        title: _ssl.primaryDomain.isEmpty
            ? context.l10n.websites_certificateNumber(_ssl.id)
            : _ssl.primaryDomain,
        subtitle: SslUIHelper.getProviderLabel(context, _ssl.provider, _ssl.type),
        trailing: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                SslUIHelper.getStatusIcon(_ssl.status),
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                SslUIHelper.getStatusLabel(context, _ssl.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: context.l10n.websites_certificateInfo,
            icon: TablerIcons.info_circle,
          ),
          _InfoGroup(
            children: [
              _InfoRow(
                icon: TablerIcons.world,
                label: context.l10n.websites_primaryDomain,
                value: _ssl.primaryDomain.isEmpty ? '--' : _ssl.primaryDomain,
              ),
              if (_ssl.otherDomains.isNotEmpty)
                _InfoRow(
                  icon: TablerIcons.world_latitude,
                  label: context.l10n.websites_otherDomains,
                  value: _ssl.otherDomains,
                ),
              _InfoRow(
                icon: TablerIcons.tag,
                label: context.l10n.websites_certificateSource,
                value: SslUIHelper.getProviderLabel(
                  context,
                  _ssl.provider,
                  _ssl.type,
                ),
              ),
              _InfoRow(
                icon: TablerIcons.category,
                label: context.l10n.websites_issuer,
                value: _ssl.organization.isEmpty ? '--' : _ssl.organization,
              ),
              _InfoRow(
                icon: TablerIcons.clock,
                label: context.l10n.websites_expirationTime,
                value: SslUIHelper.getExpireText(
                  context,
                  _ssl.expireDate,
                  relative: false,
                ),
              ),
              _InfoRow(
                icon: TablerIcons.key,
                label: context.l10n.websites_keyAlgorithm,
                value: _ssl.keyType.isEmpty ? '--' : _ssl.keyType,
              ),
              if (_ssl.autoRenew)
                _InfoRow(
                  icon: TablerIcons.refresh,
                  label: context.l10n.websites_autoRenew,
                  value: context.l10n.websites_enabled,
                ),
              if (_ssl.description.isNotEmpty)
                _InfoRow(
                  icon: TablerIcons.notes,
                  label: context.l10n.common_description,
                  value: _ssl.description,
                ),
            ],
          ),
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.websites_operations,
            icon: TablerIcons.settings,
          ),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.rocket,
                iconColor: CupertinoColors.activeBlue,
                title: context.l10n.websites_obtainOrRenew,
                subtitle: Text(context.l10n.websites_obtainOrRenewSubtitle),
                onTap: () {
                  Navigator.pop(context);
                  widget.onObtain(_ssl.id);
                },
              ),
              AppActionRow(
                icon: TablerIcons.edit,
                iconColor: CupertinoColors.systemOrange,
                title: context.l10n.common_edit,
                subtitle: Text(context.l10n.websites_editCertificateConfig),
                onTap: () {
                  // TODO: open edit sheet
                },
              ),
              AppActionRow(
                icon: TablerIcons.file_code,
                iconColor: CupertinoColors.systemTeal,
                title: context.l10n.websites_viewCertificatePem,
                subtitle: Text(
                  context.l10n.websites_viewCertificatePemSubtitle,
                ),
                onTap: () {
                  // TODO: fetch PEM content and show code editor
                },
              ),
              AppActionRow(
                icon: TablerIcons.lock,
                iconColor: CupertinoColors.systemPurple,
                title: context.l10n.websites_viewPrivateKey,
                subtitle: Text(context.l10n.websites_viewPrivateKeySubtitle),
                onTap: () {
                  // TODO: fetch private key and show code editor
                },
              ),
              AppActionRow(
                icon: TablerIcons.download,
                iconColor: CupertinoColors.systemGreen,
                title: context.l10n.websites_downloadCertificate,
                subtitle: Text(
                  context.l10n.websites_downloadCertificateSubtitle,
                ),
                onTap: () {
                  // TODO: download certificate
                },
              ),
              AppActionRow(
                icon: TablerIcons.trash,
                iconColor: CupertinoColors.systemRed,
                title: context.l10n.common_delete,
                subtitle: Text(context.l10n.websites_deleteCertificateSubtitle),
                isDestructive: true,
                onTap: () async {
                  final confirmed = await showFrostedConfirmDialog(
                    context,
                    title: context.l10n.websites_deleteCertificate,
                    icon: TablerIcons.trash,
                    content: context.l10n.websites_deleteCertificateConfirm,
                    isDestructive: true,
                  );
                  if (confirmed == true && context.mounted) {
                    Navigator.pop(context);
                    widget.onDelete(_ssl.id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 54),
                  child: Container(
                    height: 0.5,
                    color: AppColors.separator(context).withValues(alpha: 0.3),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen
                  .resolveFrom(context)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 16,
              color: CupertinoColors.systemGreen.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 30),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
