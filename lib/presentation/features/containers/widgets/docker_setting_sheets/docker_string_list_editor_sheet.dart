import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        DefaultMaterialLocalizations,
        Localizations,
        ReorderableListView,
        ReorderableDragStartListener;
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../../core/localization/l10n_x.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../common/components/action_sheet_launcher.dart';
import '../../../../common/components/action_sheet_scaffold.dart';

/// 字符串列表编辑 Sheet（支持排序、增删改）。
///
/// 返回编辑后的列表；用户取消返回 `null`。
Future<List<String>?> showDockerStringListEditorSheet(
  BuildContext context, {
  required String title,
  required List<String> initialItems,
  String placeholder = '',
}) {
  return showActionSheet<List<String>>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => _StringListEditorSheet(
      title: title,
      initialItems: initialItems,
      placeholder: placeholder,
    ),
  );
}

class _StringListEditorSheet extends StatefulWidget {
  const _StringListEditorSheet({
    required this.title,
    required this.initialItems,
    required this.placeholder,
  });

  final String title;
  final List<String> initialItems;
  final String placeholder;

  @override
  State<_StringListEditorSheet> createState() => _StringListEditorSheetState();
}

class _StringListEditorSheetState extends State<_StringListEditorSheet> {
  late final List<_EditableItem> _items;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems
        .map((e) => _EditableItem(id: _seq++, value: e))
        .toList();
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  void _add() {
    setState(() {
      _items.add(_EditableItem(id: _seq++, value: ''));
    });
  }

  void _remove(int index) {
    setState(() {
      _items[index].controller.dispose();
      _items.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  void _confirm() {
    final result = _items
        .map((e) => e.controller.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      maxHeightFactor: 0.6,
      showHandle: false,
      contentPadding: EdgeInsets.zero,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
        child: Row(
          children: [
            CupertinoButton(
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
            Expanded(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: _confirm,
              child: Text(
                context.l10n.common_confirm,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    TablerIcons.list,
                    size: 32,
                    color: AppColors.tertiaryLabel(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.containers_noData,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ),
            )
          else
            Localizations.override(
              context: context,
              delegates: const [DefaultMaterialLocalizations.delegate],
              child: ReorderableListView.builder(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) => child,
                itemCount: _items.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ReorderableDragStartListener(
                    key: ValueKey(item.id),
                    index: index,
                    child: _StringListRow(
                      controller: item.controller,
                      placeholder: widget.placeholder.isEmpty
                          ? context.l10n.containers_inputAddress
                          : widget.placeholder,
                      onDelete: () => _remove(index),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _add,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue
                      .resolveFrom(context)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.activeBlue
                        .resolveFrom(context)
                        .withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      TablerIcons.plus,
                      size: 16,
                      color: CupertinoColors.activeBlue.resolveFrom(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.containers_add,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.activeBlue.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableItem {
  _EditableItem({required this.id, String value = ''})
    : controller = TextEditingController(text: value);

  final int id;
  final TextEditingController controller;
}

class _StringListRow extends StatelessWidget {
  const _StringListRow({
    required this.controller,
    required this.placeholder,
    required this.onDelete,
  });

  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              TablerIcons.grip_vertical,
              size: 16,
              color: AppColors.tertiaryLabel(context),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: CupertinoTextField(
                controller: controller,
                placeholder: placeholder,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                style: TextStyle(
                  color: AppColors.label(context),
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 6),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: onDelete,
              child: Icon(
                TablerIcons.x,
                size: 16,
                color: CupertinoColors.systemRed.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
