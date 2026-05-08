import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show
        DefaultMaterialLocalizations,
        ReorderableDelayedDragStartListener,
        ReorderableListView;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../common/app_toast.dart';
import '../../../../data/dto/website/website_index_config_dto.dart';
import '../providers/website_index_provider.dart';
import 'website_modal_sheet.dart';

void showWebsiteIndexSheet(
  BuildContext context, {
  required int websiteId,
  required String title,
}) {
  showWebsiteModalSheet<void>(
    context: context,
    child: _WebsiteIndexSheet(websiteId: websiteId, title: title),
  );
}

class _WebsiteIndexSheet extends StatelessWidget {
  const _WebsiteIndexSheet({required this.websiteId, required this.title});

  final int websiteId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return WebsiteAsyncModalSheet<WebsiteIndexConfigDto>(
      provider: websiteIndexControllerProvider(websiteId),
      errorTitle: context.l10n.websites_loadDefaultDocumentsFailed,
      headerBuilder: (context, ref, async) =>
          _IndexHeader(websiteId: websiteId, title: title),
      dataBuilder: (context, dto) => _IndexBody(
        key: ValueKey(Object.hashAll([dto.enable, ...dto.indexFiles])),
        websiteId: websiteId,
        dto: dto,
      ),
      onRetry: (ref) =>
          ref.invalidate(websiteIndexControllerProvider(websiteId)),
    );
  }
}

/// Incremented by the header add button; [_IndexBody] listens to add inline.
final _websiteIndexAddNonceProvider = StateProvider.autoDispose
    .family<int, int>((ref, websiteId) => 0);

class _IndexHeader extends ConsumerWidget {
  const _IndexHeader({required this.websiteId, required this.title});

  final int websiteId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CupertinoColors.systemIndigo
                  .resolveFrom(context)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              TablerIcons.file_type_html,
              size: 22,
              color: CupertinoColors.systemIndigo.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.websites_defaultDocuments,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            onPressed: () {
              ref
                  .read(_websiteIndexAddNonceProvider(websiteId).notifier)
                  .update((n) => n + 1);
            },
            child: Icon(
              TablerIcons.plus,
              size: 22,
              color: CupertinoColors.activeBlue.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexEntry {
  _IndexEntry({required this.id, required this.name});

  final int id;
  String name;
}

class _IndexBody extends ConsumerStatefulWidget {
  const _IndexBody({super.key, required this.websiteId, required this.dto});

  final int websiteId;
  final WebsiteIndexConfigDto dto;

  @override
  ConsumerState<_IndexBody> createState() => _IndexBodyState();
}

class _IndexBodyState extends ConsumerState<_IndexBody> {
  late List<_IndexEntry> _entries;
  late List<String> _initialNames;
  int _idSeq = 0;
  bool _saving = false;
  int? _editingId;
  bool _editingIsNew = false;
  late final TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _entries = [
      for (final name in widget.dto.indexFiles)
        _IndexEntry(id: _idSeq++, name: name),
    ];
    _initialNames = List<String>.from(widget.dto.indexFiles, growable: false);
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _IndexBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.dto.indexFiles, widget.dto.indexFiles)) {
      _entries = [
        for (final name in widget.dto.indexFiles)
          _IndexEntry(id: _idSeq++, name: name),
      ];
      _initialNames = List<String>.from(widget.dto.indexFiles, growable: false);
    }
  }

  List<String> get _names =>
      _entries.map((e) => e.name.trim()).where((s) => s.isNotEmpty).toList();

  int _indexOfEntry(int id) => _entries.indexWhere((entry) => entry.id == id);

  bool get _isEditing => _editingId != null;

  bool get _hasUnsavedChanges {
    final currentEntries = _editingIsNew && _editingId != null
        ? _entries.where((e) => e.id != _editingId)
        : _entries;
    final current = currentEntries.map((e) => e.name).toList(growable: false);
    return !listEquals(current, _initialNames);
  }

  void _beginEdit(int id, String initialValue, {required bool isNew}) {
    _editingController
      ..text = initialValue
      ..selection = TextSelection.collapsed(offset: initialValue.length);
    setState(() {
      _editingId = id;
      _editingIsNew = isNew;
    });
  }

  void _addEntry() {
    if (_isEditing) {
      showAppWarningToast(context.l10n.websites_finishCurrentEditFirst);
      return;
    }
    final entry = _IndexEntry(id: _idSeq++, name: '');
    setState(() => _entries.insert(0, entry));
    _beginEdit(entry.id, '', isNew: true);
  }

  void _editEntry(int id) {
    if (_isEditing && _editingId != id) {
      showAppWarningToast(context.l10n.websites_finishCurrentEditFirst);
      return;
    }
    final index = _indexOfEntry(id);
    if (index < 0) return;
    _beginEdit(id, _entries[index].name, isNew: false);
  }

  void _cancelEdit() {
    final editingId = _editingId;
    if (editingId == null) return;
    setState(() {
      if (_editingIsNew) {
        _entries.removeWhere((entry) => entry.id == editingId);
      }
      _editingId = null;
      _editingIsNew = false;
      _editingController.clear();
    });
  }

  void _confirmEdit() {
    final editingId = _editingId;
    if (editingId == null) return;
    final nextName = _editingController.text.trim();
    if (nextName.isEmpty) {
      showAppWarningToast(context.l10n.websites_fileNameRequired);
      return;
    }
    final index = _indexOfEntry(editingId);
    if (index < 0) return;
    setState(() {
      _entries[index].name = nextName;
      _editingId = null;
      _editingIsNew = false;
      _editingController.clear();
    });
  }

  void _removeAt(int id) {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
      if (_editingId == id) {
        _editingId = null;
        _editingIsNew = false;
        _editingController.clear();
      }
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (_isEditing) {
      showAppWarningToast(l10n.websites_saveOrCancelCurrentEditFirst);
      return;
    }
    final names = _names;
    if (names.length != _entries.length) {
      showAppWarningToast(l10n.websites_validFileNameOrRemoveEmptyRows);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(websiteIndexControllerProvider(widget.websiteId).notifier)
          .saveIndexFiles(names);
      if (mounted) showAppSuccessToast(l10n.websites_savedAndReloaded);
    } on AppNetworkException catch (e) {
      if (mounted) showAppErrorToast(e.message);
    } catch (e) {
      if (mounted) showAppErrorToast('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_websiteIndexAddNonceProvider(widget.websiteId), (prev, next) {
      if ((prev ?? 0) >= next) return;
      Future<void>.microtask(() {
        if (mounted) _addEntry();
      });
    });

    final warnDisabled = !widget.dto.enable;
    final hasUnsavedChanges = _hasUnsavedChanges;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        14,
        0,
        14,
        MediaQuery.paddingOf(context).bottom + 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (warnDisabled) ...[
            _DisabledHintCard(),
            const SizedBox(height: 12),
          ],
          if (hasUnsavedChanges) ...[
            const _UnsavedHintCard(),
            const SizedBox(height: 10),
          ],
          Text(
            context.l10n.websites_defaultDocumentOrderHint,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.secondaryLabel(context),
            ),
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.separator(context).withValues(alpha: 0.16),
                width: 0.5,
              ),
            ),
            child: _entries.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.websites_noDefaultDocumentEntries,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  )
                : Localizations.override(
                    context: context,
                    delegates: const [DefaultMaterialLocalizations.delegate],
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      buildDefaultDragHandles: false,
                      itemCount: _entries.length,
                      onReorder: (oldIndex, newIndex) {
                        if (_isEditing) {
                          showAppWarningToast(
                            context.l10n.websites_cannotDragWhileEditing,
                          );
                          return;
                        }
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _entries.removeAt(oldIndex);
                          _entries.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final e = _entries[index];
                        final isEditing = _editingId == e.id;
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(e.id),
                          index: index,
                          child: _IndexRow(
                            isEditing: isEditing,
                            name: e.name,
                            editingController: _editingController,
                            onEdit: () => _editEntry(e.id),
                            onDelete: () => _removeAt(e.id),
                            onCancel: _cancelEdit,
                            onConfirm: _confirmEdit,
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          _SaveButton(
            saving: _saving,
            hasUnsavedChanges: hasUnsavedChanges,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _DisabledHintCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = CupertinoColors.systemOrange.resolveFrom(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(TablerIcons.info_circle, size: 18, color: c),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.websites_defaultDocumentsDisabledHint,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnsavedHintCard extends StatelessWidget {
  const _UnsavedHintCard();

  @override
  Widget build(BuildContext context) {
    final c = CupertinoColors.systemYellow.resolveFrom(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.22), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(TablerIcons.alert_circle, size: 16, color: c),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.websites_unsavedEdits,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexRow extends StatelessWidget {
  const _IndexRow({
    required this.isEditing,
    required this.name,
    required this.editingController,
    required this.onEdit,
    required this.onDelete,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool isEditing;
  final String name;
  final TextEditingController editingController;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (!isEditing)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  TablerIcons.grip_vertical,
                  size: 20,
                  color: AppColors.tertiaryLabel(context),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: isEditing
                    ? CupertinoTextField(
                        controller: editingController,
                        autofocus: true,
                        placeholder: context.l10n.websites_indexFileExample,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    : Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
            if (isEditing) ...[
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                onPressed: onCancel,
                child: Text(
                  context.l10n.common_cancel,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.only(left: 4, right: 10),
                minimumSize: Size.zero,
                onPressed: onConfirm,
                child: Text(
                  context.l10n.common_confirm,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.activeBlue.resolveFrom(context),
                  ),
                ),
              ),
            ] else ...[
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: Size.zero,
                onPressed: onEdit,
                child: Icon(
                  TablerIcons.pencil,
                  size: 18,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: Size.zero,
                onPressed: onDelete,
                child: Icon(
                  TablerIcons.trash,
                  size: 18,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.saving,
    required this.hasUnsavedChanges,
    required this.onPressed,
  });

  final bool saving;
  final bool hasUnsavedChanges;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoColors.activeBlue.resolveFrom(context);
    final enabled = onPressed != null;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: enabled ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              TablerIcons.device_floppy,
              size: 17,
              color: color.withValues(alpha: enabled ? 1 : 0.4),
            ),
            const SizedBox(width: 8),
            Text(
              saving
                  ? context.l10n.websites_saving
                  : (hasUnsavedChanges
                        ? context.l10n.websites_saveChanges
                        : context.l10n.common_save),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color.withValues(alpha: enabled ? 1 : 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
