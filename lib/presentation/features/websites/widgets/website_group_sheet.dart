import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/website/website_group_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_confirm_sheet.dart';

/// Shows the website group management sheet.
Future<void> showWebsiteGroupSheet(
  BuildContext context, {
  VoidCallback? onChanged,
}) async {
  await showActionSheet<void>(
    context: context,
    builder: (_) => _WebsiteGroupSheet(onChanged: onChanged),
  );
}

// ---------------------------------------------------------------------------
// Main sheet
// ---------------------------------------------------------------------------

class _WebsiteGroupSheet extends ConsumerStatefulWidget {
  const _WebsiteGroupSheet({this.onChanged});

  final VoidCallback? onChanged;

  @override
  ConsumerState<_WebsiteGroupSheet> createState() => _WebsiteGroupSheetState();
}

class _WebsiteGroupSheetState extends ConsumerState<_WebsiteGroupSheet> {
  List<WebsiteGroupDto> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final groups = await repo.searchWebsiteGroups();
      if (mounted) {
        setState(() {
          _groups = groups;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAppErrorToast(
          context.l10n.websites_loadGroupsGenericFailed,
          description: '$e',
        );
      }
    }
  }

  void _markDirty() {
    widget.onChanged?.call();
  }

  // Create

  Future<void> _createGroup() async {
    final groupCreated = context.l10n.websites_groupCreated;
    final createFailed = context.l10n.websites_createFailed;
    final name = await _showGroupNameSheet(context);
    if (name == null || name.isEmpty) return;

    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.createWebsiteGroup(
        WebsiteGroupDto(id: 0, name: name, type: 'website', isDefault: false),
      );
      _markDirty();
      showAppSuccessToast(groupCreated);
      await _loadGroups();
    } catch (e) {
      showAppErrorToast(createFailed, description: '$e');
    }
  }

  // Edit

  Future<void> _editGroup(WebsiteGroupDto group) async {
    final groupUpdated = context.l10n.websites_groupUpdated;
    final updateFailed = context.l10n.websites_updateFailed;
    final name = await _showGroupNameSheet(context, initialName: group.name);
    if (name == null || name.isEmpty || name == group.name) return;

    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.updateWebsiteGroup(group.copyWith(name: name));
      _markDirty();
      showAppSuccessToast(groupUpdated);
      await _loadGroups();
    } catch (e) {
      showAppErrorToast(updateFailed, description: '$e');
    }
  }

  // Set default

  Future<void> _setDefault(WebsiteGroupDto group) async {
    final defaultGroupSet = context.l10n.websites_defaultGroupSet;
    final operationFailed = context.l10n.websites_operationFailed;
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.updateWebsiteGroup(group.copyWith(isDefault: true));
      _markDirty();
      showAppSuccessToast(defaultGroupSet);
      await _loadGroups();
    } catch (e) {
      showAppErrorToast(operationFailed, description: '$e');
    }
  }

  // Delete

  Future<void> _deleteGroup(WebsiteGroupDto group) async {
    final groupDeleted = context.l10n.websites_groupDeleted;
    final deleteFailed = context.l10n.websites_deleteFailed;
    final confirmed = await showActionSheet<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: context.l10n.websites_deleteGroup,
        content: context.l10n.websites_deleteGroupConfirm(group.name),
        confirmText: context.l10n.common_delete,
        confirmColor: CupertinoColors.destructiveRed,
        icon: TablerIcons.trash,
        iconColor: CupertinoColors.destructiveRed,
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.deleteWebsiteGroup(group.id);
      _markDirty();
      showAppSuccessToast(groupDeleted);
      await _loadGroups();
    } catch (e) {
      showAppErrorToast(deleteFailed, description: '$e');
    }
  }

  // UI

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      hasHorizontalPadding: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
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
            ),
            Text(
              context.l10n.websites_manageGroups,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
                letterSpacing: -0.4,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: _createGroup,
                child: Icon(
                  TablerIcons.plus,
                  size: 22,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                ),
              ),
            ),
          ],
        ),
      ),
      child: _loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CupertinoActivityIndicator()),
            )
          : _groups.isEmpty
          ? _buildEmptyState()
          : _buildGroupList(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.folder_off,
            size: 48,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.websites_noGroups,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.14),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _groups.length; i++) ...[
              _GroupTile(
                group: _groups[i],
                onEdit: () => _editGroup(_groups[i]),
                onSetDefault: () => _setDefault(_groups[i]),
                onDelete: () => _deleteGroup(_groups[i]),
              ),
              if (i < _groups.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Container(
                    height: 0.5,
                    color: AppColors.separator(context).withValues(alpha: 0.1),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group list item
// ---------------------------------------------------------------------------

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  final WebsiteGroupDto group;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showGroupActions(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              TablerIcons.folder,
              size: 20,
              color: group.isDefault
                  ? CupertinoColors.activeBlue
                  : AppColors.secondaryLabel(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: group.isDefault
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: AppColors.label(context),
                      ),
                    ),
                  ),
                  if (group.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue
                            .resolveFrom(context)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        context.l10n.websites_default,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.activeBlue.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              TablerIcons.dots_vertical,
              size: 18,
              color: AppColors.tertiaryLabel(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupActions(BuildContext context) {
    HapticFeedback.selectionClick();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onEdit();
            },
            child: Text(context.l10n.common_edit),
          ),
          if (!group.isDefault)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onSetDefault();
              },
              child: Text(context.l10n.websites_setAsDefault),
            ),
          if (!group.isDefault)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: Text(context.l10n.common_delete),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.common_cancel),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group name input sheet
// ---------------------------------------------------------------------------

Future<String?> _showGroupNameSheet(
  BuildContext context, {
  String? initialName,
}) {
  return showActionSheet<String>(
    context: context,
    builder: (_) => _GroupNameSheet(initialName: initialName),
  );
}

class _GroupNameSheet extends StatefulWidget {
  const _GroupNameSheet({this.initialName});

  final String? initialName;

  @override
  State<_GroupNameSheet> createState() => _GroupNameSheetState();
}

class _GroupNameSheetState extends State<_GroupNameSheet> {
  late final TextEditingController _controller;
  bool _submitting = false;

  bool get _isEdit => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      showAppWarningToast(context.l10n.websites_groupNameRequired);
      return;
    }
    setState(() => _submitting = true);
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      hasHorizontalPadding: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.l10n.common_cancel,
                  style: TextStyle(
                    color: AppColors.secondaryLabel(context),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Text(
              _isEdit
                  ? context.l10n.websites_editGroup
                  : context.l10n.websites_newGroup,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
                letterSpacing: -0.4,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const CupertinoActivityIndicator(radius: 10)
                    : Text(
                        _isEdit
                            ? context.l10n.common_save
                            : context.l10n.common_create,
                        style: TextStyle(
                          color: CupertinoColors.activeBlue.resolveFrom(
                            context,
                          ),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.separator(context).withValues(alpha: 0.14),
              width: 0.5,
            ),
          ),
          child: SizedBox(
            height: 44,
            child: CupertinoTextField(
              controller: _controller,
              autofocus: true,
              placeholder: context.l10n.websites_groupNameRequired,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 15, color: AppColors.label(context)),
              decoration: const BoxDecoration(),
              autocorrect: false,
              enableSuggestions: false,
              onSubmitted: (_) => _submit(),
            ),
          ),
        ),
      ),
    );
  }
}
