import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import 'database_type_icon.dart';

/// 数据库实例卡片，展示数据库实例（如 MySQL、Redis 服务）的基本信息。
class DatabaseInstanceCard extends StatelessWidget {
  const DatabaseInstanceCard({
    super.key,
    required this.instance,
    required this.onTap,
  });

  final DatabaseInstanceDto instance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      pressedOpacity: 0.7,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(color: CupertinoColors.transparent),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background(context),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: DatabaseTypeIcon(type: instance.type, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instance.database,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label(context),
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        instance.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryLabel(
                            context,
                          ).withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        instance.version,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.tertiaryLabel(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (instance.from == 'remote'
                            ? CupertinoColors.systemIndigo
                            : CupertinoColors.systemBlue)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    instance.from == 'remote'
                        ? TablerIcons.cloud
                        : TablerIcons.device_desktop,
                    size: 11,
                    color: instance.from == 'remote'
                        ? CupertinoColors.systemIndigo
                        : CupertinoColors.systemBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    instance.from == 'remote'
                        ? context.l10n.databases_remote
                        : context.l10n.databases_local,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: instance.from == 'remote'
                          ? CupertinoColors.systemIndigo
                          : CupertinoColors.systemBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: AppColors.tertiaryLabel(context).withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// 数据库项卡片，展示具体的数据库（如某个 MySQL Schema）的信息。
class DatabaseCard extends StatefulWidget {
  const DatabaseCard({
    super.key,
    required this.database,
    required this.type,
    required this.onTap,
  });

  final DatabaseSearchItemDto database;
  final String type;
  final VoidCallback onTap;

  @override
  State<DatabaseCard> createState() => _DatabaseCardState();
}

class _DatabaseCardState extends State<DatabaseCard> {
  bool _obscurePassword = true;
  bool _usernameCopied = false;
  bool _passwordCopied = false;
  Timer? _hideTimer;
  Timer? _usernameTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _usernameTimer?.cancel();
    super.dispose();
  }

  void _copyUsername() {
    Clipboard.setData(ClipboardData(text: widget.database.username));
    setState(() => _usernameCopied = true);

    _usernameTimer?.cancel();
    _usernameTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _usernameCopied = false);
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _obscurePassword = true;
          _passwordCopied = false;
        });
      }
    });
  }

  void _copyPassword() {
    Clipboard.setData(ClipboardData(text: widget.database.password));
    setState(() => _passwordCopied = true);
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final isRemote = widget.database.from.toLowerCase() == 'remote';

    return CupertinoButton(
      padding: EdgeInsets.zero,
      pressedOpacity: 0.9,
      onPressed: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.14),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DatabaseTypeIcon(type: widget.type, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.database.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label(context),
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.databases_createdAt(
                          formatLocalDateTime(
                            widget.database.createdAt,
                            includeSeconds: false,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.tertiaryLabel(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isRemote
                                ? CupertinoColors.systemIndigo
                                : CupertinoColors.systemBlue)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRemote
                            ? TablerIcons.cloud
                            : TablerIcons.device_desktop,
                        size: 11,
                        color: isRemote
                            ? CupertinoColors.systemIndigo
                            : CupertinoColors.systemBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRemote
                            ? context.l10n.databases_remote
                            : context.l10n.databases_local,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isRemote
                              ? CupertinoColors.systemIndigo
                              : CupertinoColors.systemBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                height: 0.5,
                color: AppColors.separator(context).withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        TablerIcons.user,
                        size: 14,
                        color: AppColors.secondaryLabel(context),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.l10n.databases_username,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.database.username,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: _copyUsername,
                        child: Icon(
                          _usernameCopied
                              ? TablerIcons.check
                              : TablerIcons.copy,
                          size: 16,
                          color: _usernameCopied
                              ? CupertinoColors.systemGreen
                              : AppColors.tertiaryLabel(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                        if (_obscurePassword) {
                          _hideTimer?.cancel();
                        } else {
                          _startHideTimer();
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          TablerIcons.lock,
                          size: 14,
                          color: AppColors.secondaryLabel(context),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n.databases_password,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryLabel(context),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _obscurePassword
                              ? '•' * widget.database.password.length
                              : widget.database.password,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.label(context),
                            fontFamily: _obscurePassword ? null : 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: _obscurePassword
                              ? () {
                                  setState(() => _obscurePassword = false);
                                  _startHideTimer();
                                }
                              : (_passwordCopied ? null : _copyPassword),
                          child: Icon(
                            _obscurePassword
                                ? TablerIcons.eye_off
                                : (_passwordCopied
                                      ? TablerIcons.check
                                      : TablerIcons.copy),
                            size: 16,
                            color: (_passwordCopied && !_obscurePassword)
                                ? CupertinoColors.systemGreen
                                : AppColors.tertiaryLabel(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 18,
                        child: Center(
                          child: Icon(
                            TablerIcons.notes,
                            size: 14,
                            color: AppColors.tertiaryLabel(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.database.description.isEmpty
                              ? context.l10n.databases_none
                              : widget.database.description,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: widget.database.description.isEmpty
                                ? AppColors.tertiaryLabel(context)
                                : AppColors.secondaryLabel(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
