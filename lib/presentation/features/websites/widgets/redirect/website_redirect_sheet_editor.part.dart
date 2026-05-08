part of '../website_redirect_sheet.dart';

class _RedirectEditorSheet extends ConsumerStatefulWidget {
  const _RedirectEditorSheet({required this.websiteId, this.initial});

  final int websiteId;
  final WebsiteRedirectDto? initial;

  @override
  ConsumerState<_RedirectEditorSheet> createState() =>
      _RedirectEditorSheetState();
}

class _RedirectEditorSheetState extends ConsumerState<_RedirectEditorSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  String _type = 'domain';
  String _redirect = '301';
  bool _keepPath = true;
  Set<String> _selectedDomains = {};

  List<WebsiteDomainDto> _availableDomains = [];
  bool _loadingDomains = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameController.text = widget.initial!.name;
      _targetController.text = widget.initial!.target;
      _type = widget.initial!.type;
      _redirect = widget.initial!.redirect;
      _keepPath = widget.initial!.keepPath;
      _selectedDomains = widget.initial!.domains.toSet();
    }
    _loadDomains();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _loadDomains() async {
    try {
      final domains = await ref
          .read(websiteRedirectControllerProvider(widget.websiteId).notifier)
          .fetchDomains();
      if (mounted) {
        setState(() {
          _availableDomains = domains;
          _loadingDomains = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_loadDomainListFailed,
          description: '$e',
        );
        setState(() => _loadingDomains = false);
      }
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppWarningToast(context.l10n.websites_ruleNameRequired);
      return;
    }
    final target = _targetController.text.trim();
    if (target.isEmpty) {
      showAppWarningToast(context.l10n.websites_targetUrlRequired);
      return;
    }
    if (_type == 'domain' && _selectedDomains.isEmpty) {
      showAppWarningToast(context.l10n.websites_selectAtLeastOneDomain);
      return;
    }

    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{
        'websiteID': widget.websiteId,
        'operate': widget.initial == null ? 'create' : 'edit',
        'enable': widget.initial?.enable ?? true,
        'name': name,
        'domains': _selectedDomains.toList(),
        'keepPath': _keepPath,
        'type': _type,
        'redirect': _redirect,
        'target': target,
        'redirectRoot': false,
      };
      if (widget.initial != null) {
        payload['path'] = widget.initial!.path;
        payload['filePath'] = widget.initial!.filePath;
        payload['content'] = widget.initial!.content;
      }

      await ref
          .read(websiteRedirectControllerProvider(widget.websiteId).notifier)
          .updateRedirect(payload);
      if (mounted) {
        showAppSuccessToast(
          widget.initial == null
              ? context.l10n.websites_redirectRuleCreated
              : context.l10n.websites_redirectRuleUpdated,
        );
        Navigator.of(context).pop();
      }
    } on AppNetworkException catch (error) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_saveFailed,
          description: error.message,
        );
      }
    } catch (error) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_saveFailed,
          description: '$error',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background(context),
        middle: Text(
          widget.initial == null
              ? context.l10n.websites_newRedirect
              : context.l10n.websites_editRedirect,
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.common_cancel),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saving ? null : _save,
          child: _saving
              ? const CupertinoActivityIndicator()
              : Text(context.l10n.common_save),
        ),
      ),
      child: SafeArea(
        child: _loadingDomains
            ? const Center(child: CupertinoActivityIndicator())
            : _RedirectForm(
                isEdit: widget.initial != null,
                nameController: _nameController,
                targetController: _targetController,
                type: _type,
                onTypeChanged: (v) => setState(() => _type = v),
                redirect: _redirect,
                onRedirectChanged: (v) => setState(() => _redirect = v),
                keepPath: _keepPath,
                onKeepPathChanged: (v) => setState(() => _keepPath = v),
                availableDomains: _availableDomains,
                selectedDomains: _selectedDomains,
                onDomainToggle: (domain) {
                  setState(() {
                    if (_selectedDomains.contains(domain)) {
                      _selectedDomains.remove(domain);
                    } else {
                      _selectedDomains.add(domain);
                    }
                  });
                },
              ),
      ),
    );
  }
}
