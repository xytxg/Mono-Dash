part of '../website_auth_sheet.dart';

Future<void> showWebsiteAuthFormSheet(
  BuildContext context, {
  required int websiteId,
  required String scope, // 'root' or 'path'
  WebsiteAuthItemDto? initialAccount,
  WebsitePathAuthItemDto? initialPathAccount,
}) async {
  await showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => _WebsiteAuthFormSheet(
      websiteId: websiteId,
      scope: scope,
      initialAccount: initialAccount,
      initialPathAccount: initialPathAccount,
    ),
  );
}

class _WebsiteAuthFormSheet extends ConsumerStatefulWidget {
  const _WebsiteAuthFormSheet({
    required this.websiteId,
    required this.scope,
    this.initialAccount,
    this.initialPathAccount,
  });

  final int websiteId;
  final String scope;
  final WebsiteAuthItemDto? initialAccount;
  final WebsitePathAuthItemDto? initialPathAccount;

  @override
  ConsumerState<_WebsiteAuthFormSheet> createState() =>
      _WebsiteAuthFormSheetState();
}

class _WebsiteAuthFormSheetState extends ConsumerState<_WebsiteAuthFormSheet> {
  late final TextEditingController _pathController;
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _remarkController;
  bool _isLoading = false;

  bool get _isEdit =>
      widget.initialAccount != null || widget.initialPathAccount != null;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(
      text: widget.initialPathAccount?.path ?? '/',
    );
    _nameController = TextEditingController(
      text: widget.initialPathAccount?.name ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.initialAccount?.username ?? widget.initialPathAccount?.username ?? '',
    );
    _passwordController = TextEditingController();
    _remarkController = TextEditingController(
      text: widget.initialAccount?.remark ?? widget.initialPathAccount?.remark ?? '',
    );
  }

  @override
  void dispose() {
    _pathController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty) {
      showAppWarningToast(l10n.websites_usernameRequired);
      return;
    }
    if (!_isEdit && password.isEmpty) {
      showAppWarningToast(l10n.websites_passwordRequired);
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.scope == 'root') {
        await ref
            .read(websiteAuthControllerProvider(widget.websiteId).notifier)
            .updateAuth(
              WebsiteAuthUpdateReq(
                websiteId: widget.websiteId,
                operate: _isEdit ? 'edit' : 'create',
                username: username,
                password: password,
                remark: _remarkController.text.trim(),
                scope: 'root',
              ),
            );
      } else {
        final path = _pathController.text.trim();
        final name = _nameController.text.trim();
        if (path.isEmpty || name.isEmpty) {
          showAppWarningToast(l10n.websites_pathAndNameRequired);
          return;
        }
        await ref
            .read(websitePathAuthControllerProvider(widget.websiteId).notifier)
            .updatePathAuth(
              WebsitePathAuthUpdateReq(
                websiteId: widget.websiteId,
                path: path,
                name: name,
                username: username,
                password: password,
                operate: _isEdit ? 'edit' : 'create',
                remark: _remarkController.text.trim(),
              ),
            );
      }
      if (mounted) {
        showAppSuccessToast(l10n.common_saved);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showAppErrorToast(l10n.websites_saveFailed, description: '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPath = widget.scope == 'path';
    final title = _isEdit ? l10n.websites_editAccount : l10n.websites_addAccount;

    return ActionSheetScaffold(
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          if (isPath) ...[
            _FormItem(
              label: l10n.websites_protectedPath,
              icon: TablerIcons.folder,
              child: CupertinoTextField(
                controller: _pathController,
                placeholder: l10n.websites_pathExampleAdmin,
                enabled: !_isEdit,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context)
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _FormItem(
              label: l10n.websites_authName,
              icon: TablerIcons.tag,
              child: CupertinoTextField(
                controller: _nameController,
                placeholder: l10n.websites_authNameExample,
                enabled: !_isEdit,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context)
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _FormItem(
            label: l10n.websites_username,
            icon: TablerIcons.user,
            child: CupertinoTextField(
              controller: _usernameController,
              placeholder: l10n.websites_usernameRequired,
              enabled: !_isEdit,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context)
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FormItem(
            label: l10n.websites_accessPassword,
            icon: TablerIcons.key,
            child: CupertinoTextField(
              controller: _passwordController,
              placeholder:
                  _isEdit ? l10n.websites_leaveBlankToKeep : l10n.websites_passwordRequired,
              obscureText: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context)
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FormItem(
            label: l10n.websites_remarkOptional,
            icon: TablerIcons.note,
            child: CupertinoTextField(
              controller: _remarkController,
              placeholder: l10n.websites_accountRemarkPlaceholder,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context)
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isEdit)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: Row(
                children: [
                  Icon(TablerIcons.info_circle,
                      size: 12, color: AppColors.tertiaryLabel(context)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isPath
                          ? l10n.websites_pathAuthImmutableHint
                          : l10n.websites_globalAuthPasswordResetHint,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.tertiaryLabel(context)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: CupertinoColors.activeBlue.resolveFrom(context),
              borderRadius: BorderRadius.circular(14),
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white)
                  : Text(
                      l10n.websites_confirmSave,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormItem extends StatelessWidget {
  const _FormItem({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.secondaryLabel(context)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
