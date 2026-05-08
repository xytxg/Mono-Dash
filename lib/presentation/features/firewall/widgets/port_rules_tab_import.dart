part of 'port_rules_tab.dart';

enum _ImportStatus { newRule, conflict, duplicate, invalid }

class _ImportCandidate {
  _ImportCandidate({
    required this.body,
    required this.status,
    this.existingStrategy,
  }) : error = null;

  _ImportCandidate.invalid(this.error)
    : body = const {},
      status = _ImportStatus.invalid,
      existingStrategy = null;

  final Map<String, dynamic> body;
  final _ImportStatus status;
  final String? existingStrategy;
  final String? error;

  bool get selectable =>
      status == _ImportStatus.newRule || status == _ImportStatus.conflict;
}

class _ImportPreviewSheet extends ConsumerStatefulWidget {
  const _ImportPreviewSheet({required this.candidates});

  final List<_ImportCandidate> candidates;

  @override
  ConsumerState<_ImportPreviewSheet> createState() =>
      _ImportPreviewSheetState();
}

class _ImportPreviewSheetState extends ConsumerState<_ImportPreviewSheet> {
  late final Set<int> _selected;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _selected = {
      for (var i = 0; i < widget.candidates.length; i++)
        if (widget.candidates[i].status == _ImportStatus.newRule) i,
    };
  }

  @override
  Widget build(BuildContext context) {
    final importable = _selected.length;
    return ActionSheetScaffold(
      title: context.l10n.firewall_importPortRules,
      maxHeightFactor: 0.86,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: importable == 0 || _importing ? null : _import,
        child: _importing
            ? const CupertinoActivityIndicator(radius: 10)
            : Text(
                context.l10n.firewall_importCount(importable),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: importable == 0
                      ? AppColors.tertiaryLabel(context)
                      : CupertinoColors.activeBlue.resolveFrom(context),
                ),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            for (var i = 0; i < widget.candidates.length; i++) ...[
              _ImportCandidateRow(
                candidate: widget.candidates[i],
                selected: _selected.contains(i),
                onTap: widget.candidates[i].selectable
                    ? () => setState(() {
                        if (_selected.contains(i)) {
                          _selected.remove(i);
                        } else {
                          _selected.add(i);
                        }
                      })
                    : null,
              ),
              if (i != widget.candidates.length - 1)
                Container(
                  height: 0.5,
                  color: AppColors.separator(context).withValues(alpha: 0.18),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    final rules = _selected
        .map((index) => widget.candidates[index].body)
        .toList(growable: false);
    final result = await ref
        .read(firewallPortRulesControllerProvider.notifier)
        .importRules(rules);
    if (!mounted) return;
    Navigator.pop(context);
    if (result.failed == 0) {
      showAppSuccessToast(
        context.l10n.firewall_importSucceeded,
        description: context.l10n.firewall_importedCount(result.success),
      );
    } else {
      showAppWarningToast(
        context.l10n.firewall_importPartiallySucceeded,
        description: context.l10n.firewall_importPartialDescription(
          result.success,
          result.failed,
        ),
      );
    }
  }
}

class _ImportCandidateRow extends StatelessWidget {
  const _ImportCandidateRow({
    required this.candidate,
    required this.selected,
    required this.onTap,
  });

  final _ImportCandidate candidate;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (candidate.status) {
      _ImportStatus.newRule => CupertinoColors.systemGreen,
      _ImportStatus.conflict => CupertinoColors.systemOrange,
      _ImportStatus.duplicate => CupertinoColors.systemGrey,
      _ImportStatus.invalid => CupertinoColors.systemRed,
    };
    final label = switch (candidate.status) {
      _ImportStatus.newRule => context.l10n.firewall_importStatusNew,
      _ImportStatus.conflict => context.l10n.firewall_importStatusConflict,
      _ImportStatus.duplicate => context.l10n.firewall_importStatusDuplicate,
      _ImportStatus.invalid => context.l10n.firewall_importStatusInvalid,
    };
    final body = candidate.body;
    final title = candidate.status == _ImportStatus.invalid
        ? candidate.error!
        : context.l10n.firewall_importPortTitle(
            '${body['port']}',
            '${body['protocol']}',
          );
    final subtitle = candidate.status == _ImportStatus.conflict
        ? context.l10n.firewall_importConflictSubtitle(
            candidate.existingStrategy ?? '',
            '${body['strategy']}',
          )
        : candidate.status == _ImportStatus.invalid
        ? context.l10n.firewall_importInvalidSubtitle
        : context.l10n.firewall_importCandidateSubtitle(
            (body['address'] as String).isEmpty
                ? context.l10n.firewall_allAddresses
                : '${body['address']}',
            '${body['strategy']}',
          );

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              selected ? TablerIcons.circle_check_filled : TablerIcons.circle,
              size: 22,
              color: selected
                  ? CupertinoColors.activeBlue.resolveFrom(context)
                  : AppColors.tertiaryLabel(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
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
            const SizedBox(width: 8),
            _StrategyChip(label: label, color: color),
          ],
        ),
      ),
    );
  }
}
