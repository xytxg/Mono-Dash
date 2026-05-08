import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_picker.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/dto/website/website_dir_dto.dart';
import '../providers/website_detail_provider.dart';
import '../providers/website_dir_provider.dart';
import 'website_modal_sheet.dart';
import '../../files/screens/files_page.dart';
import '../../server_detail/providers/active_server_provider.dart';

Future<void> showWebsiteDirSheet(
  BuildContext context, {
  required WebsiteDetailDto detail,
}) async {
  final container = ProviderScope.containerOf(context);
  await showWebsiteModalSheet<void>(
    context: context,
    child: _WebsiteDirSheet(detail: detail),
  );
  if (!context.mounted) return;
  // Avoid invalidating Riverpod during sheet close animation/rebuild.
  await Future<void>.delayed(const Duration(milliseconds: 260));
  if (!context.mounted) return;
  container.invalidate(websiteDetailProvider(detail.website.id));
}

class _WebsiteDirSheet extends StatelessWidget {
  const _WebsiteDirSheet({required this.detail});

  final WebsiteDetailDto detail;

  @override
  Widget build(BuildContext context) {
    final websiteId = detail.website.id;
    return WebsiteAsyncModalSheet<WebsiteDirDto>(
      provider: websiteDirControllerProvider(websiteId),
      errorTitle: context.l10n.websites_loadWebsiteDirectoryFailed,
      headerBuilder: (context, ref, dirAsync) => const _DirHeader(),
      dataBuilder: (context, dir) => _DirContent(detail: detail, dir: dir),
      onRetry: (ref) => ref.invalidate(websiteDirControllerProvider(websiteId)),
    );
  }
}

class _DirHeader extends StatelessWidget {
  const _DirHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CupertinoColors.systemOrange
                  .resolveFrom(context)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              TablerIcons.folder_root,
              size: 22,
              color: CupertinoColors.systemOrange.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.websites_websiteDirectory,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.websites_directorySubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DirContent extends ConsumerStatefulWidget {
  const _DirContent({required this.detail, required this.dir});

  final WebsiteDetailDto detail;
  final WebsiteDirDto dir;

  @override
  ConsumerState<_DirContent> createState() => _DirContentState();
}

class _DirContentState extends ConsumerState<_DirContent> {
  late String _siteDir;
  late final TextEditingController _userController;
  late final TextEditingController _groupController;
  bool _savingDir = false;
  bool _savingPermission = false;

  @override
  void initState() {
    super.initState();
    _siteDir = _initialSiteDir();
    _userController = TextEditingController(text: widget.dir.user);
    _groupController = TextEditingController(text: widget.dir.userGroup);
  }

  @override
  void didUpdateWidget(covariant _DirContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dir != widget.dir) {
      if (!widget.dir.dirs.contains(_siteDir)) {
        _siteDir = widget.dir.dirs.isEmpty ? '/' : widget.dir.dirs.first;
      }
      _userController.text = widget.dir.user;
      _groupController.text = widget.dir.userGroup;
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final rootDir = _rootDir(detail, _siteDir);
    final alias = detail.alias.isNotEmpty
        ? detail.alias
        : detail.website.primaryDomain;
    final l10n = context.l10n;

    return Column(
      children: [
        if (widget.dir.msg.trim().isNotEmpty) ...[
          _WarningCard(message: widget.dir.msg),
          const SizedBox(height: 12),
        ],
        _InfoCard(
          children: [
            _InfoRow(
              icon: TablerIcons.tag,
              title: l10n.websites_websiteAlias,
              value: alias.isEmpty ? l10n.websites_notSet : alias,
            ),
            const _CardDivider(),
            _InfoRow(
              icon: TablerIcons.folder,
              title: l10n.websites_rootDirectory,
              value: rootDir,
              onTap: () => _openDirectory(rootDir),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: TablerIcons.folder_cog,
          title: l10n.websites_runningDirectory,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DirPicker(
                dirs: widget.dir.dirs,
                value: _siteDir,
                onChanged: (value) => setState(() => _siteDir = value),
              ),
              const SizedBox(height: 12),
              _PrimaryButton(
                icon: TablerIcons.refresh,
                label: _savingDir
                    ? l10n.websites_saving
                    : l10n.websites_saveAndReload,
                onPressed: _savingDir ? null : _saveSiteDir,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: TablerIcons.user_cog,
          title: l10n.websites_runningUserGroup,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TextFieldBlock(
                      label: l10n.websites_user,
                      controller: _userController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextFieldBlock(
                      label: l10n.websites_userGroup,
                      controller: _groupController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _PrimaryButton(
                icon: TablerIcons.device_floppy,
                label: _savingPermission
                    ? l10n.websites_saving
                    : l10n.websites_savePermissions,
                onPressed: _savingPermission ? null : _savePermission,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _DirectoryHelpCard(),
      ],
    );
  }

  String _initialSiteDir() {
    final siteDir = widget.detail.website.siteDir;
    if (widget.dir.dirs.contains(siteDir)) return siteDir;
    return widget.dir.dirs.isEmpty ? '/' : widget.dir.dirs.first;
  }

  String _rootDir(WebsiteDetailDto detail, String siteDir) {
    final base = detail.website.sitePath.trim();
    if (siteDir.isEmpty || siteDir == '/') return base;
    final normalizedSiteDir = siteDir.replaceFirst(RegExp(r'^/+'), '');
    return '${base.replaceAll(RegExp(r'/+$'), '')}/$normalizedSiteDir';
  }

  Future<void> _saveSiteDir() async {
    setState(() => _savingDir = true);
    try {
      await ref
          .read(websiteDirControllerProvider(widget.detail.website.id).notifier)
          .updateSiteDir(_siteDir);
    } on AppNetworkException catch (error) {
      if (mounted) showAppErrorToast(error.message);
    } catch (error) {
      if (mounted) showAppErrorToast('$error');
    } finally {
      if (mounted) setState(() => _savingDir = false);
    }
  }

  Future<void> _savePermission() async {
    final user = _userController.text.trim();
    final group = _groupController.text.trim();
    if (user.isEmpty || group.isEmpty) {
      showAppWarningToast(context.l10n.websites_runningUserGroupRequired);
      return;
    }
    setState(() => _savingPermission = true);
    try {
      await ref
          .read(websiteDirControllerProvider(widget.detail.website.id).notifier)
          .updatePermission(user: user, group: group);
    } on AppNetworkException catch (error) {
      if (mounted) showAppErrorToast(error.message);
    } catch (error) {
      if (mounted) showAppErrorToast('$error');
    } finally {
      if (mounted) setState(() => _savingPermission = false);
    }
  }

  void _openDirectory(String path) {
    final targetPath = path.trim();
    if (targetPath.isEmpty) return;

    final serverId = ref.read(activeServerIdProvider);
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ProviderScope(
          overrides: [activeServerIdProvider.overrideWithValue(serverId)],
          child: StandaloneFilesPage(initialPath: targetPath),
        ),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoColors.systemOrange.resolveFrom(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(TablerIcons.alert_triangle, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: CupertinoColors.systemOrange.resolveFrom(context),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 72,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                TablerIcons.chevron_right,
                size: 14,
                color: AppColors.tertiaryLabel(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 42),
      child: Container(
        height: 0.5,
        color: AppColors.separator(context).withValues(alpha: 0.24),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: CupertinoColors.systemOrange.resolveFrom(context),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DirPicker extends StatelessWidget {
  const _DirPicker({
    required this.dirs,
    required this.value,
    required this.onChanged,
  });

  final List<String> dirs;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppInlinePicker<String>(
      options: dirs
          .map((dir) => AppPickerOption(value: dir, label: dir))
          .toList(),
      value: value,
      onChanged: onChanged,
      selectedColor: CupertinoColors.systemOrange.resolveFrom(context),
    );
  }
}

class _TextFieldBlock extends StatelessWidget {
  const _TextFieldBlock({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryLabel(context),
          ),
        ),
        const SizedBox(height: 7),
        CupertinoTextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autocorrect: false,
          enableSuggestions: false,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.tertiaryBackground(
              context,
            ).withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoColors.activeBlue.resolveFrom(context);
    final enabled = onPressed != null;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: enabled ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color.withValues(alpha: enabled ? 1 : 0.4),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
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

class _DirectoryHelpCard extends StatelessWidget {
  const _DirectoryHelpCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: TablerIcons.info_circle,
      title: context.l10n.websites_directoryDescription,
      child: Column(
        children: [
          _HelpRow(name: 'ssl', desc: context.l10n.websites_siteCertificates),
          const SizedBox(height: 8),
          _HelpRow(name: 'log', desc: context.l10n.websites_siteLogs),
          const SizedBox(height: 8),
          _HelpRow(
            name: 'index',
            desc: context.l10n.websites_indexDirectoryDescription,
          ),
        ],
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.name, required this.desc});

  final String name;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: CupertinoColors.systemOrange
                .resolveFrom(context)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.systemOrange.resolveFrom(context),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ),
      ],
    );
  }
}
