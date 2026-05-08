import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/dto/website/website_log_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_picker.dart';
import '../../../common/components/frosted_dialog.dart';
import '../providers/website_detail_provider.dart';
import '../providers/website_log_provider.dart';
import 'website_modal_sheet.dart';

void showWebsiteLogSheet(
  BuildContext context, {
  required WebsiteDetailDto detail,
}) {
  showWebsiteModalSheet<void>(
    context: context,
    child: _WebsiteLogSheet(detail: detail),
  );
}

class _WebsiteLogSheet extends ConsumerStatefulWidget {
  const _WebsiteLogSheet({required this.detail});

  final WebsiteDetailDto detail;

  @override
  ConsumerState<_WebsiteLogSheet> createState() => _WebsiteLogSheetState();
}

class _WebsiteLogSheetState extends ConsumerState<_WebsiteLogSheet> {
  WebsiteLogType _type = WebsiteLogType.access;
  String _query = '';
  bool _searching = false;
  bool _accessEnabled = true;
  bool _errorEnabled = true;

  @override
  void initState() {
    super.initState();
    _accessEnabled = widget.detail.accessLog;
    _errorEnabled = widget.detail.errorLog;
  }

  @override
  Widget build(BuildContext context) {
    return WebsiteAsyncModalSheet<WebsiteLogFileDto>(
      provider: websiteLogControllerProvider(widget.detail.website.id, _type),
      maxHeightFactor: 0.9,
      minBodyHeightFactor: 0.56,
      errorTitle: _type == WebsiteLogType.access
          ? context.l10n.websites_accessLogLoadFailed
          : context.l10n.websites_errorLogLoadFailed,
      headerBuilder: (context, ref, async) => _LogHeader(
        title: widget.detail.website.primaryDomain,
        type: _type,
        totalLines: async?.valueOrNull?.totalLines,
        searching: _searching,
        query: _query,
        accessEnabled: _accessEnabled,
        errorEnabled: _errorEnabled,
        onTypeChanged: (value) => setState(() => _type = value),
        onToggleSearch: () => setState(() {
          _searching = !_searching;
          if (!_searching) _query = '';
        }),
        onQueryChanged: (value) => setState(() => _query = value),
      ),
      dataBuilder: (context, file) =>
          _LogBody(file: file, type: _type, query: _query, onCopyRaw: _copyRaw),
      panelOverlayBuilder: (context, async) {
        final file = async?.valueOrNull;
        if (file == null) return const SizedBox.shrink();
        return Positioned(
          right: 16,
          bottom: MediaQuery.paddingOf(context).bottom + 18,
          child: _LogFabMenu(
            type: _type,
            enabled: _isCurrentEnabled,
            onRefresh: _refresh,
            onClear: _clear,
            onExport: () => _export(file),
            onSwitchType: () => setState(() {
              _type = _type == WebsiteLogType.access
                  ? WebsiteLogType.error
                  : WebsiteLogType.access;
            }),
            onSetEnabled: _setCurrentEnabled,
          ),
        );
      },
      onRetry: (ref) => ref.invalidate(
        websiteLogControllerProvider(widget.detail.website.id, _type),
      ),
    );
  }

  bool get _isCurrentEnabled =>
      _type == WebsiteLogType.access ? _accessEnabled : _errorEnabled;

  Future<void> _refresh() async {
    try {
      await ref
          .read(
            websiteLogControllerProvider(
              widget.detail.website.id,
              _type,
            ).notifier,
          )
          .refresh();
    } on AppNetworkException catch (error) {
      showAppErrorToast(error.message);
    } catch (error) {
      showAppErrorToast('$error');
    }
  }

  Future<void> _clear() async {
    final logCleared = context.l10n.websites_logCleared;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: _type == WebsiteLogType.access
          ? context.l10n.websites_clearAccessLog
          : context.l10n.websites_clearErrorLog,
      content: context.l10n.websites_clearLogConfirm,
      confirmText: context.l10n.websites_clear,
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(
            websiteLogControllerProvider(
              widget.detail.website.id,
              _type,
            ).notifier,
          )
          .clear();
      showAppSuccessToast(logCleared);
    } on AppNetworkException catch (error) {
      showAppErrorToast(error.message);
    } catch (error) {
      showAppErrorToast('$error');
    }
  }

  Future<void> _setCurrentEnabled(bool enabled) async {
    final successMessage = enabled
        ? context.l10n.websites_logEnabled
        : context.l10n.websites_logDisabled;
    try {
      await ref
          .read(
            websiteLogControllerProvider(
              widget.detail.website.id,
              _type,
            ).notifier,
          )
          .setEnabled(enabled);
      setState(() {
        if (_type == WebsiteLogType.access) {
          _accessEnabled = enabled;
        } else {
          _errorEnabled = enabled;
        }
      });
      ref.invalidate(websiteDetailProvider(widget.detail.website.id));
      showAppSuccessToast(successMessage);
    } on AppNetworkException catch (error) {
      showAppErrorToast(error.message);
    } catch (error) {
      showAppErrorToast('$error');
    }
  }

  Future<void> _copyRaw(String raw) async {
    final copied = context.l10n.websites_rawLogCopied;
    await Clipboard.setData(ClipboardData(text: raw));
    showAppSuccessToast(copied);
  }

  Future<void> _export(WebsiteLogFileDto file) async {
    final sharePluginUnregistered =
        context.l10n.websites_sharePluginUnregistered;
    final sharePluginRestartHint = context.l10n.websites_sharePluginRestartHint;
    final exportFailed = context.l10n.websites_exportFailed;
    if (file.lines.isEmpty) {
      showAppWarningToast(context.l10n.websites_noExportableLogs);
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final filename = _exportFilename(
        widget.detail.website.primaryDomain,
        _type,
      );
      final exportFile = File('${dir.path}/$filename');
      await exportFile.writeAsString(file.lines.join('\n'));
      await SharePlus.instance.share(
        ShareParams(
          title: filename,
          subject: filename,
          files: [XFile(exportFile.path, mimeType: 'text/plain')],
          fileNameOverrides: [filename],
        ),
      );
    } on MissingPluginException {
      showAppErrorToast(
        sharePluginUnregistered,
        description: sharePluginRestartHint,
      );
    } catch (error) {
      showAppErrorToast(exportFailed, description: '$error');
    }
  }

  String _exportFilename(String domain, WebsiteLogType type) {
    final host = domain.split(':').first.trim().isEmpty
        ? 'website'
        : domain.split(':').first.trim();
    final safeHost = host.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    final timestamp = DateTime.now().toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    return '${safeHost}_${timestamp}_${type.exportName}.log';
  }
}

class _LogHeader extends StatelessWidget {
  const _LogHeader({
    required this.title,
    required this.type,
    required this.totalLines,
    required this.searching,
    required this.query,
    required this.accessEnabled,
    required this.errorEnabled,
    required this.onTypeChanged,
    required this.onToggleSearch,
    required this.onQueryChanged,
  });

  final String title;
  final WebsiteLogType type;
  final int? totalLines;
  final bool searching;
  final String query;
  final bool accessEnabled;
  final bool errorEnabled;
  final ValueChanged<WebsiteLogType> onTypeChanged;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = type == WebsiteLogType.access
        ? accessEnabled
        : errorEnabled;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBrown
                      .resolveFrom(context)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  TablerIcons.logs,
                  size: 22,
                  color: CupertinoColors.systemBrown.resolveFrom(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.websites_websiteLogs,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.label(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.websites_logHeaderSubtitle(
                        title,
                        totalLines ?? 0,
                        enabled
                            ? context.l10n.websites_enabled
                            : context.l10n.websites_disabled,
                      ),
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
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: onToggleSearch,
                child: Icon(
                  searching ? TablerIcons.x : TablerIcons.search,
                  size: 22,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppInlinePicker<WebsiteLogType>(
            options: [
              AppPickerOption(
                value: WebsiteLogType.access,
                label: context.l10n.websites_accessLog,
              ),
              AppPickerOption(
                value: WebsiteLogType.error,
                label: context.l10n.websites_errorLog,
              ),
            ],
            value: type,
            selectedColor: CupertinoColors.systemBrown.resolveFrom(context),
            anchorHeight: 40,
            itemHeight: 40,
            maxVisibleItems: 2,
            onChanged: onTypeChanged,
          ),
          if (searching) ...[
            const SizedBox(height: 10),
            CupertinoSearchTextField(
              placeholder: context.l10n.websites_logSearchPlaceholder,
              onChanged: onQueryChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _LogBody extends StatelessWidget {
  const _LogBody({
    required this.file,
    required this.type,
    required this.query,
    required this.onCopyRaw,
  });

  final WebsiteLogFileDto file;
  final WebsiteLogType type;
  final String query;
  final ValueChanged<String> onCopyRaw;

  @override
  Widget build(BuildContext context) {
    // File lines are oldest-first; show the latest entries at the top.
    final parsed = file.lines
        .map((line) => ParsedWebsiteLog.fromRaw(line, type, context.l10n))
        .where((entry) => entry.matches(query))
        .toList(growable: false)
        .reversed
        .toList();

    if (parsed.isEmpty) return _EmptyLogState(query: query);
    return Column(
      children: [
        for (int i = 0; i < parsed.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _LogEntryCard(
            entry: parsed[i],
            onCopyRaw: () => onCopyRaw(parsed[i].raw),
          ),
        ],
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 92),
      ],
    );
  }
}

class _LogEntryCard extends StatefulWidget {
  const _LogEntryCard({required this.entry, required this.onCopyRaw});

  final ParsedWebsiteLog entry;
  final VoidCallback onCopyRaw;

  @override
  State<_LogEntryCard> createState() => _LogEntryCardState();
}

class _LogEntryCardState extends State<_LogEntryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final statusColor = _statusColor(context, entry.statusCode);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.16),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StatusBadge(
                            statusCode: entry.statusCode,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          _MethodBadge(method: entry.method),
                          const SizedBox(width: 8),
                          Expanded(child: _IpChip(ip: entry.ip)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (entry.timeLabel.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 86,
                    child: Text(
                      entry.timeLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.15,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.summary,
              maxLines: _expanded ? 3 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.secondaryLabel(context),
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          children: [
                            _DetailRow(
                              label: context.l10n.websites_time,
                              value: entry.absoluteTimeLabel,
                            ),
                            _DetailRow(
                              label: context.l10n.websites_path,
                              value: entry.path,
                            ),
                            _DetailRow(
                              label: context.l10n.websites_user,
                              value: entry.remoteUser,
                            ),
                            _DetailRow(label: 'UA', value: entry.userAgent),
                            _DetailRow(
                              label: context.l10n.websites_source,
                              value: entry.referer,
                            ),
                            _DetailRow(
                              label: context.l10n.websites_size,
                              value: entry.bytes,
                            ),
                            _DetailRow(
                              label: 'XFF',
                              value: entry.xForwardedFor,
                            ),
                            _DetailRow(label: 'Host', value: entry.host),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CupertinoButton(
                                padding: const EdgeInsets.only(top: 6),
                                minimumSize: const Size(0, 28),
                                onPressed: widget.onCopyRaw,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      TablerIcons.copy,
                                      size: 15,
                                      color: CupertinoColors.activeBlue
                                          .resolveFrom(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.l10n.websites_copyRawData,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: CupertinoColors.activeBlue
                                            .resolveFrom(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, int? statusCode) {
    if (statusCode == null) return AppColors.secondaryLabel(context);
    if (statusCode >= 500) {
      return CupertinoColors.systemRed.resolveFrom(context);
    }
    if (statusCode >= 400) {
      return CupertinoColors.systemOrange.resolveFrom(context);
    }
    if (statusCode >= 300) {
      return CupertinoColors.systemBlue.resolveFrom(context);
    }
    return CupertinoColors.systemGreen.resolveFrom(context);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.statusCode, required this.color});

  final int? statusCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          statusCode?.toString() ?? 'LOG',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 44),
      child: Text(
        method.isEmpty ? '-' : method,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: CupertinoColors.activeBlue.resolveFrom(context),
        ),
      ),
    );
  }
}

class _IpChip extends StatelessWidget {
  const _IpChip({required this.ip});

  final String ip;

  @override
  Widget build(BuildContext context) {
    return Text(
      ip.isEmpty ? 'unknown' : ip,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.label(context),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty || value == '-') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(
              label,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.tertiaryLabel(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.label(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLogState extends StatelessWidget {
  const _EmptyLogState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              query.isEmpty ? TablerIcons.file_text : TablerIcons.search_off,
              size: 38,
              color: AppColors.tertiaryLabel(context),
            ),
            const SizedBox(height: 10),
            Text(
              query.isEmpty
                  ? context.l10n.websites_noLogs
                  : context.l10n.websites_noMatchingLogs,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.label(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogFabMenu extends StatefulWidget {
  const _LogFabMenu({
    required this.type,
    required this.enabled,
    required this.onRefresh,
    required this.onClear,
    required this.onExport,
    required this.onSwitchType,
    required this.onSetEnabled,
  });

  final WebsiteLogType type;
  final bool enabled;
  final VoidCallback onRefresh;
  final VoidCallback onClear;
  final VoidCallback onExport;
  final VoidCallback onSwitchType;
  final ValueChanged<bool> onSetEnabled;

  @override
  State<_LogFabMenu> createState() => _LogFabMenuState();
}

class _LogFabMenuState extends State<_LogFabMenu> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _FabAction(
        icon: TablerIcons.refresh,
        label: context.l10n.common_refresh,
        onTap: widget.onRefresh,
        color: CupertinoColors.activeBlue.resolveFrom(context),
      ),
      _FabAction(
        icon: TablerIcons.switch_2,
        label: widget.type == WebsiteLogType.access
            ? context.l10n.websites_errorLog
            : context.l10n.websites_accessLog,
        onTap: widget.onSwitchType,
        color: CupertinoColors.systemPurple.resolveFrom(context),
      ),
      _FabAction(
        icon: widget.enabled
            ? TablerIcons.player_pause
            : TablerIcons.player_play,
        label: widget.enabled
            ? context.l10n.websites_disable
            : context.l10n.websites_enable,
        onTap: () => widget.onSetEnabled(!widget.enabled),
        color: CupertinoColors.systemGreen.resolveFrom(context),
      ),
      _FabAction(
        icon: TablerIcons.download,
        label: context.l10n.websites_export,
        onTap: widget.onExport,
        color: CupertinoColors.systemTeal.resolveFrom(context),
      ),
      _FabAction(
        icon: TablerIcons.trash,
        label: context.l10n.websites_clear,
        onTap: widget.onClear,
        color: CupertinoColors.systemRed.resolveFrom(context),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: _open
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < actions.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _FabActionButton(
                            action: actions[i],
                            onTap: () {
                              setState(() => _open = false);
                              actions[i].onTap();
                            },
                          ),
                        ),
                    ],
                  )
                : const SizedBox(width: 1),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => setState(() => _open = !_open),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue.resolveFrom(context),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.activeBlue
                      .resolveFrom(context)
                      .withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _open ? TablerIcons.x : TablerIcons.dots_vertical,
              color: CupertinoColors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _FabAction {
  const _FabAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
}

class _FabActionButton extends StatelessWidget {
  const _FabActionButton({required this.action, required this.onTap});

  final _FabAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.background(context).withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.separator(context).withValues(alpha: 0.18),
                width: 0.5,
              ),
            ),
            child: Text(
              action.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.label(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: action.color.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(action.icon, size: 17, color: CupertinoColors.white),
          ),
        ],
      ),
    );
  }
}

class ParsedWebsiteLog {
  const ParsedWebsiteLog({
    required this.raw,
    required this.type,
    required this.ip,
    required this.remoteUser,
    required this.timeLabel,
    required this.absoluteTimeLabel,
    required this.method,
    required this.path,
    required this.statusCode,
    required this.bytes,
    required this.referer,
    required this.userAgent,
    required this.xForwardedFor,
    required this.host,
    required this.summary,
  });

  final String raw;
  final WebsiteLogType type;
  final String ip;
  final String remoteUser;
  final String timeLabel;
  final String absoluteTimeLabel;
  final String method;
  final String path;
  final int? statusCode;
  final String bytes;
  final String referer;
  final String userAgent;
  final String xForwardedFor;
  final String host;
  final String summary;

  static ParsedWebsiteLog fromRaw(
    String raw,
    WebsiteLogType type,
    AppLocalizations l10n,
  ) {
    return type == WebsiteLogType.access
        ? _parseAccess(raw, l10n)
        : _parseError(raw, l10n);
  }

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return raw.toLowerCase().contains(q) ||
        ip.toLowerCase().contains(q) ||
        method.toLowerCase().contains(q) ||
        path.toLowerCase().contains(q) ||
        (statusCode?.toString().contains(q) ?? false);
  }

  static ParsedWebsiteLog _parseAccess(String raw, AppLocalizations l10n) {
    final regex = RegExp(
      r'^(\S+) \S+ (\S+) \[([^\]]+)\] "([^"]*)" (\d{3}) (\S+) "([^"]*)" "([^"]*)" "([^"]*)"',
    );
    final match = regex.firstMatch(raw);
    if (match == null) return _fallback(raw, WebsiteLogType.access);

    final request = match.group(4) ?? '';
    final requestParts = request.split(RegExp(r'\s+'));
    final method = requestParts.isNotEmpty ? requestParts[0] : '';
    final path = requestParts.length > 1 ? requestParts[1] : request;
    final rawTime = match.group(3) ?? '';
    final timestamp = _parseAccessTime(rawTime);
    return ParsedWebsiteLog(
      raw: raw,
      type: WebsiteLogType.access,
      ip: match.group(1) ?? '',
      remoteUser: _dashToEmpty(match.group(2) ?? ''),
      timeLabel: _relativeTime(timestamp, l10n) ?? rawTime,
      absoluteTimeLabel: _absoluteTime(timestamp) ?? rawTime,
      method: method,
      path: path,
      statusCode: int.tryParse(match.group(5) ?? ''),
      bytes: match.group(6) ?? '',
      referer: _dashToEmpty(match.group(7) ?? ''),
      userAgent: _dashToEmpty(match.group(8) ?? ''),
      xForwardedFor: _dashToEmpty(match.group(9) ?? ''),
      host: '',
      summary: path,
    );
  }

  static ParsedWebsiteLog _parseError(String raw, AppLocalizations l10n) {
    final prefix = RegExp(r'^(\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}) \[(\w+)\]');
    final client = RegExp(r'client: ([^,\s]+)').firstMatch(raw)?.group(1) ?? '';
    final request =
        RegExp(r'request: "([^"]*)"').firstMatch(raw)?.group(1) ?? '';
    final host = RegExp(r'host: "([^"]*)"').firstMatch(raw)?.group(1) ?? '';
    final referer =
        RegExp(r'referrer: "([^"]*)"').firstMatch(raw)?.group(1) ?? '';
    final prefixMatch = prefix.firstMatch(raw);
    final rawTime = prefixMatch?.group(1) ?? '';
    final timestamp = _parseErrorTime(rawTime);
    final requestParts = request.split(RegExp(r'\s+'));
    final method = requestParts.isNotEmpty ? requestParts[0] : '';
    final path = requestParts.length > 1 ? requestParts[1] : '';

    return ParsedWebsiteLog(
      raw: raw,
      type: WebsiteLogType.error,
      ip: client,
      remoteUser: '',
      timeLabel: _relativeTime(timestamp, l10n) ?? rawTime,
      absoluteTimeLabel: _absoluteTime(timestamp) ?? rawTime,
      method: method,
      path: path,
      statusCode: null,
      bytes: '',
      referer: referer,
      userAgent: '',
      xForwardedFor: '',
      host: host,
      summary: raw.replaceFirst(prefix, '').trim(),
    );
  }

  static ParsedWebsiteLog _fallback(String raw, WebsiteLogType type) {
    return ParsedWebsiteLog(
      raw: raw,
      type: type,
      ip: '',
      remoteUser: '',
      timeLabel: '',
      absoluteTimeLabel: '',
      method: '',
      path: '',
      statusCode: null,
      bytes: '',
      referer: '',
      userAgent: '',
      xForwardedFor: '',
      host: '',
      summary: raw,
    );
  }

  static String _dashToEmpty(String value) => value == '-' ? '' : value;

  static DateTime? _parseAccessTime(String value) {
    final match = RegExp(
      r'^(\d{1,2})/([A-Za-z]{3})/(\d{4}):(\d{2}):(\d{2}):(\d{2}) ([+-])(\d{2})(\d{2})$',
    ).firstMatch(value.trim());
    if (match == null) return null;

    final month = _monthNumber(match.group(2) ?? '');
    if (month == null) return null;
    final day = int.tryParse(match.group(1) ?? '');
    final year = int.tryParse(match.group(3) ?? '');
    final hour = int.tryParse(match.group(4) ?? '');
    final minute = int.tryParse(match.group(5) ?? '');
    final second = int.tryParse(match.group(6) ?? '');
    final offsetHour = int.tryParse(match.group(8) ?? '');
    final offsetMinute = int.tryParse(match.group(9) ?? '');
    if (day == null ||
        year == null ||
        hour == null ||
        minute == null ||
        second == null ||
        offsetHour == null ||
        offsetMinute == null) {
      return null;
    }

    final sign = match.group(7) == '-' ? -1 : 1;
    final offset = Duration(
      hours: offsetHour * sign,
      minutes: offsetMinute * sign,
    );
    final utc = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
    ).subtract(offset);
    return utc.toLocal();
  }

  static DateTime? _parseErrorTime(String value) {
    final match = RegExp(
      r'^(\d{4})/(\d{2})/(\d{2}) (\d{2}):(\d{2}):(\d{2})$',
    ).firstMatch(value.trim());
    if (match == null) return null;
    final year = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final day = int.tryParse(match.group(3) ?? '');
    final hour = int.tryParse(match.group(4) ?? '');
    final minute = int.tryParse(match.group(5) ?? '');
    final second = int.tryParse(match.group(6) ?? '');
    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null ||
        second == null) {
      return null;
    }
    return DateTime.utc(year, month, day, hour, minute, second).toLocal();
  }

  static int? _monthNumber(String month) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    return months[month.toLowerCase()];
  }

  static String? _relativeTime(DateTime? value, AppLocalizations l10n) {
    if (value == null) return null;
    final now = DateTime.now();
    final diff = now.difference(value);
    if (diff.isNegative) {
      final future = value.difference(now);
      if (future.inMinutes < 1) return l10n.format_relativeSoon;
      if (future.inHours < 1) {
        return l10n.format_relativeMinutesLater(future.inMinutes);
      }
      if (future.inDays < 1) {
        return l10n.format_relativeHoursLater(future.inHours);
      }
      return l10n.format_relativeDaysLater(future.inDays);
    }
    if (diff.inSeconds < 10) return l10n.format_relativeJustNow;
    if (diff.inMinutes < 1) {
      return l10n.format_relativeSecondsAgo(diff.inSeconds);
    }
    if (diff.inHours < 1) return l10n.format_relativeMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.format_relativeHoursAgo(diff.inHours);
    if (diff.inDays < 30) return l10n.format_relativeDaysAgo(diff.inDays);
    if (diff.inDays < 365) {
      return l10n.format_relativeMonthsAgo(diff.inDays ~/ 30);
    }
    return l10n.format_relativeYearsAgo(diff.inDays ~/ 365);
  }

  static String? _absoluteTime(DateTime? value) {
    if (value == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }
}
