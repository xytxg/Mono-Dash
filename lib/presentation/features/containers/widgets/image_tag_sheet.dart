import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../providers/image_list_provider.dart';

void showImageTagSheet(BuildContext context, DockerImageInfo image) {
  showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => _ImageTagSheet(image: image),
  );
}

class _TagEntry {
  _TagEntry({required this.id, required this.value});

  final String id;
  String value;
}

class _ImageTagSheet extends ConsumerStatefulWidget {
  const _ImageTagSheet({required this.image});

  final DockerImageInfo image;

  @override
  ConsumerState<_ImageTagSheet> createState() => _ImageTagSheetState();
}

class _ImageTagSheetState extends ConsumerState<_ImageTagSheet> {
  late List<_TagEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.image.tags
        .map((t) => _TagEntry(id: const Uuid().v4(), value: t))
        .toList();
  }

  Future<void> _submit() async {
    final tags = _entries
        .map((e) => e.value.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (tags.isEmpty) {
      showAppErrorToast(context.l10n.containers_addAtLeastOneTag);
      return;
    }
    final editTagsFailedText = context.l10n.containers_editTagsFailed;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.tagImage(ImageTagReq(sourceID: widget.image.id, tags: tags));

      if (!mounted) return;
      Navigator.pop(context);
      ref.read(imageListControllerProvider.notifier).refresh();
    } catch (e) {
      showAppErrorToast(editTagsFailedText, description: e.toString());
    }
  }

  void _addTag() {
    HapticFeedback.selectionClick();
    setState(() {
      _entries.add(_TagEntry(id: const Uuid().v4(), value: ''));
    });
  }

  void _removeTag(int index) {
    HapticFeedback.lightImpact();
    setState(() => _entries.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      maxHeightFactor: 0.85,
      showHandle: false,
      panelHeader: _buildPanelHeader(),
      child: _buildForm(),
    );
  }

  Widget _buildPanelHeader() {
    return Padding(
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
              context.l10n.containers_editTags,
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
            onPressed: _submit,
            child: Text(
              context.l10n.common_save,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final idDisplay = widget.image.id.replaceFirst('sha256:', '');
    final shortId = idDisplay.length > 12
        ? idDisplay.substring(0, 12)
        : idDisplay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context.l10n.containers_imageId, TablerIcons.photo),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            shortId,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionTitle(context.l10n.containers_tagList, TablerIcons.tags),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _entries.length; i++) ...[
                _TagRow(
                  key: ValueKey(_entries[i].id),
                  initialValue: _entries[i].value,
                  onChanged: (v) => _entries[i].value = v,
                  onRemove: _entries.length <= 1 ? null : () => _removeTag(i),
                ),
                if (i < _entries.length - 1)
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.only(left: 52),
                    color: AppColors.separator(context).withValues(alpha: 0.15),
                  ),
              ],
              Container(
                height: 0.5,
                margin: const EdgeInsets.only(left: 52),
                color: AppColors.separator(context).withValues(alpha: 0.15),
              ),
              GestureDetector(
                onTap: _addTag,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        TablerIcons.plus,
                        size: 18,
                        color: CupertinoColors.activeBlue.resolveFrom(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.l10n.containers_addTag,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.activeBlue.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            context.l10n.containers_tagEditHint,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.tertiaryLabel(context),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: CupertinoColors.activeBlue.resolveFrom(context),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagRow extends StatefulWidget {
  const _TagRow({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onRemove,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback? onRemove;

  @override
  State<_TagRow> createState() => _TagRowState();
}

class _TagRowState extends State<_TagRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(
            TablerIcons.tag,
            size: 18,
            color: AppColors.tertiaryLabel(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: CupertinoTextField(
              controller: _controller,
              placeholder: context.l10n.containers_tagPlaceholder,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: null,
              autocorrect: false,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: AppColors.label(context),
              ),
              onChanged: widget.onChanged,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(32, 32),
            onPressed: widget.onRemove,
            child: Icon(
              TablerIcons.x,
              size: 18,
              color: widget.onRemove != null
                  ? CupertinoColors.systemRed.resolveFrom(context)
                  : AppColors.tertiaryLabel(context).withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
