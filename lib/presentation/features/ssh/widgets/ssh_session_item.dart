import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_meta_chip.dart';
import '../../../common/components/mini_button.dart';

/// SSH 会话列表项。
class SshSessionItem extends StatelessWidget {
  const SshSessionItem({
    super.key,
    required this.username,
    required this.pid,
    required this.terminal,
    required this.host,
    required this.loginTime,
    required this.onDisconnect,
  });

  final String username;
  final int pid;
  final String terminal;
  final String host;
  final String loginTime;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像/图标
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue
                    .resolveFrom(context)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                TablerIcons.user,
                size: 18,
                color: CupertinoColors.systemBlue.resolveFrom(context),
              ),
            ),
            const SizedBox(width: 12),

            // 内容区
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppMetaChip(
                        label: terminal,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // 详细元数据
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _MetaInfo(icon: TablerIcons.server, text: host),
                      _MetaInfo(icon: TablerIcons.clock, text: loginTime),
                      _MetaInfo(icon: TablerIcons.hash, text: 'PID $pid'),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MiniButton(
                        label: context.l10n.ssh_forceDisconnect,
                        icon: TablerIcons.logout,
                        color: CupertinoColors.systemRed,
                        onTap: onDisconnect,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  const _MetaInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.tertiaryLabel(context)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
