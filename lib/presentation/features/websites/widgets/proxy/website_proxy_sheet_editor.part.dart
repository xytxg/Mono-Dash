part of '../website_proxy_sheet.dart';

class _ProxyEditorSheet extends ConsumerStatefulWidget {
  const _ProxyEditorSheet({required this.websiteId, this.initial});
  final int websiteId;
  final WebsiteProxyDto? initial;
  @override
  ConsumerState<_ProxyEditorSheet> createState() => _ProxyEditorSheetState();
}

class _ReplaceRule {
  _ReplaceRule({required this.id, required this.search, required this.replace});
  final int id;
  String search;
  String replace;
}

class _BrowserCacheParsed {
  const _BrowserCacheParsed({required this.time, required this.unit});
  final int time;
  final String unit;
}

class _ProxyEditorSheetState extends ConsumerState<_ProxyEditorSheet> {
  final _nameController = TextEditingController();
  final _modifierController = TextEditingController();
  final _matchController = TextEditingController(text: '/');
  final _proxyPassController = TextEditingController(text: 'http://');
  final _proxyHostController = TextEditingController(text: r'$host');
  final _allowOriginsController = TextEditingController(text: '*');
  final _allowHeadersController = TextEditingController();
  final _serverCacheTimeController = TextEditingController(text: '10');
  final _browserCacheTimeController = TextEditingController(text: '4');
  bool _enable = true;
  bool _serverCacheEnabled = true;
  String _serverCacheUnit = 'm';
  _BrowserCacheMode _browserCacheMode = _BrowserCacheMode.noModify;
  bool _browserCacheTouched = false;
  String _browserCacheUnit = 'h';
  bool _cors = false;
  bool _allowCredentials = true;
  bool _preflight = true;
  final Set<String> _allowMethods = <String>{};
  final List<_ReplaceRule> _replaces = [];
  int _replaceSeq = 0;
  bool _saving = false;

  _BrowserCacheParsed? _parseBrowserCacheFromContent(String content) {
    final match = RegExp(
      r'expires\\s+(\\d+)\\s*([smhdwMy]);',
    ).firstMatch(content);
    if (match == null) return null;
    final time = int.tryParse(match.group(1) ?? '');
    final unit = match.group(2) ?? '';
    if (time == null || time <= 0 || !_unitOptions.contains(unit)) return null;
    return _BrowserCacheParsed(time: time, unit: unit);
  }

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    if (item != null) {
      _nameController.text = item.name;
      _matchController.text = item.match;
      _proxyPassController.text = item.proxyPass;
      _proxyHostController.text = item.proxyHost.isEmpty
          ? r'$host'
          : item.proxyHost;
      _modifierController.text = item.modifier;
      _enable = item.enable;
      _serverCacheEnabled = item.serverCacheTime > 0;
      _serverCacheTimeController.text =
          '${item.serverCacheTime > 0 ? item.serverCacheTime : 10}';
      _serverCacheUnit = item.serverCacheUnit.isEmpty
          ? 'm'
          : item.serverCacheUnit;
      final parsedBrowserCache = _parseBrowserCacheFromContent(item.content);
      // Browser cache is parsed from content first to avoid backend cache field ambiguity.
      if (parsedBrowserCache != null) {
        _browserCacheMode = _BrowserCacheMode.enable;
        _browserCacheTimeController.text = '${parsedBrowserCache.time}';
        _browserCacheUnit = parsedBrowserCache.unit;
      } else if (item.cacheTime > 0 && item.cacheUnit.isNotEmpty) {
        _browserCacheMode = _BrowserCacheMode.enable;
        _browserCacheTimeController.text = '${item.cacheTime}';
        _browserCacheUnit = item.cacheUnit;
      } else {
        _browserCacheMode = _BrowserCacheMode.noModify;
        _browserCacheTimeController.text = '4';
        _browserCacheUnit = 'h';
      }
      _cors = item.cors;
      _allowOriginsController.text = item.allowOrigins.isEmpty
          ? '*'
          : item.allowOrigins;
      _allowHeadersController.text = item.allowHeaders;
      _allowCredentials = item.allowCredentials;
      _preflight = item.preflight;
      for (final method
          in item.allowMethods
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)) {
        _allowMethods.add(method.toUpperCase());
      }
      item.replaces.forEach((k, v) {
        _replaces.add(_ReplaceRule(id: _replaceSeq++, search: k, replace: v));
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modifierController.dispose();
    _matchController.dispose();
    _proxyPassController.dispose();
    _proxyHostController.dispose();
    _allowOriginsController.dispose();
    _allowHeadersController.dispose();
    _serverCacheTimeController.dispose();
    _browserCacheTimeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final modifier = _modifierController.text.trim();
    final match = _matchController.text.trim();
    final proxyPass = _proxyPassController.text.trim();
    final proxyHost = _proxyHostController.text.trim();
    if (name.isEmpty ||
        match.isEmpty ||
        proxyPass.isEmpty ||
        proxyHost.isEmpty) {
      showAppWarningToast(context.l10n.websites_proxyRequiredFields);
      return;
    }
    final uri = Uri.tryParse(proxyPass);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      showAppWarningToast(context.l10n.websites_proxyUrlInvalid);
      return;
    }
    if (_cors && _allowOriginsController.text.trim().isEmpty) {
      showAppWarningToast(context.l10n.websites_corsOriginsRequired);
      return;
    }

    final serverCacheTime =
        int.tryParse(_serverCacheTimeController.text.trim()) ?? 0;
    final browserCacheTime =
        int.tryParse(_browserCacheTimeController.text.trim()) ?? 0;
    if (_serverCacheEnabled && serverCacheTime <= 0) {
      showAppWarningToast(context.l10n.websites_serverCacheTimePositive);
      return;
    }
    if (_browserCacheMode == _BrowserCacheMode.enable &&
        browserCacheTime <= 0) {
      showAppWarningToast(context.l10n.websites_browserCacheTimePositive);
      return;
    }

    final replaces = <String, String>{};
    for (final item in _replaces) {
      final key = item.search.trim();
      if (key.isEmpty) continue;
      replaces[key] = item.replace;
    }

    final effectiveBrowserCacheMode = switch ((
      widget.initial != null,
      _browserCacheTouched,
      _browserCacheMode,
    )) {
      // In edit mode, preserve enabled browser cache explicitly when untouched.
      (true, false, _BrowserCacheMode.enable) => _BrowserCacheMode.enable,
      (true, false, _) => _BrowserCacheMode.noModify,
      _ => _browserCacheMode,
    };

    final cacheFlag = switch (effectiveBrowserCacheMode) {
      _BrowserCacheMode.enable => true,
      // Disabling browser cache should not affect server cache.
      _BrowserCacheMode.disable => _serverCacheEnabled,
      // When browser cache is unchanged, preserve previous cache state.
      _BrowserCacheMode.noModify =>
        _serverCacheEnabled || (widget.initial?.cache ?? false),
    };
    final cacheTime = switch (effectiveBrowserCacheMode) {
      _BrowserCacheMode.enable => browserCacheTime,
      _BrowserCacheMode.disable => 0,
      _BrowserCacheMode.noModify => 0,
    };
    final cacheUnit = switch (effectiveBrowserCacheMode) {
      _BrowserCacheMode.enable => _browserCacheUnit,
      _BrowserCacheMode.disable => '',
      _BrowserCacheMode.noModify => '',
    };

    final payload = <String, dynamic>{
      'id': widget.websiteId,
      'operate': widget.initial == null ? 'create' : 'edit',
      'enable': _enable,
      'cache': cacheFlag,
      'cacheTime': cacheTime,
      'cacheUnit': cacheUnit,
      'name': name,
      'modifier': modifier,
      'match': match,
      'proxyPass': proxyPass,
      'proxyHost': proxyHost,
      'replaces': replaces,
      'proxySSLName': widget.initial?.proxySSLName ?? '',
      'serverCacheTime': _serverCacheEnabled ? serverCacheTime : 0,
      'serverCacheUnit': _serverCacheEnabled ? _serverCacheUnit : 'm',
      'cors': _cors,
      'allowOrigins': _cors ? _allowOriginsController.text.trim() : '',
      'allowMethods': _cors ? _allowMethods.join(',') : '',
      'allowHeaders': _cors ? _allowHeadersController.text.trim() : '',
      'allowCredentials': _cors && _allowCredentials,
      'preflight': _cors && _preflight,
      'browserCache': switch (effectiveBrowserCacheMode) {
        _BrowserCacheMode.enable => 'enable',
        _BrowserCacheMode.disable => 'disable',
        _BrowserCacheMode.noModify => 'noModify',
      },
      'proxyProtocol': '${uri.scheme}://',
      'proxyAddress': uri.hasPort ? '${uri.host}:${uri.port}' : uri.host,
      'sni': widget.initial?.sni ?? false,
      'sslVerify': widget.initial?.sslVerify ?? false,
    };
    if (widget.initial != null) {
      payload['content'] = widget.initial!.content;
      payload['filePath'] = widget.initial!.filePath;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(websiteProxyControllerProvider(widget.websiteId).notifier)
          .saveProxy(payload);
      if (mounted) {
        showAppSuccessToast(
          widget.initial == null
              ? context.l10n.websites_proxyCreated
              : context.l10n.websites_proxyUpdated,
        );
        Navigator.of(context).pop();
      }
    } on AppNetworkException catch (error) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_saveFailedCopyDetails,
          description: error.message,
          copyText: error.message,
        );
      }
    } catch (error) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_saveFailedCopyDetails,
          description: '$error',
          copyText: '$error',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background(context),
        middle: Text(
          isEdit
              ? context.l10n.websites_editReverseProxy
              : context.l10n.websites_newReverseProxy,
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
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
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            12,
            10,
            12,
            MediaQuery.paddingOf(context).bottom + 16,
          ),
          children: [
            _FormSection(
              icon: TablerIcons.adjustments,
              title: context.l10n.websites_basicConfig,
              children: [
                _CompactInputField(
                  label: context.l10n.websites_name,
                  icon: TablerIcons.tag,
                  controller: _nameController,
                  required: true,
                  enabled: !isEdit,
                  hint: context.l10n.websites_proxyNameHint,
                  helper: isEdit ? context.l10n.websites_editNameLocked : null,
                ),
                _CompactInputField(
                  label: context.l10n.websites_matchRule,
                  icon: TablerIcons.regex,
                  controller: _modifierController,
                  hint: context.l10n.websites_matchRuleHint,
                  helper: context.l10n.websites_matchRuleHelper,
                ),
                _CompactInputField(
                  label: context.l10n.websites_frontendPath,
                  icon: TablerIcons.route,
                  controller: _matchController,
                  required: true,
                  hint: context.l10n.websites_frontendPathHint,
                ),
                _CompactInputField(
                  label: context.l10n.websites_backendProxyAddress,
                  icon: TablerIcons.world_www,
                  controller: _proxyPassController,
                  required: true,
                  hint: 'http://10.1.1.1',
                  keyboardType: TextInputType.url,
                ),
                _CompactInputField(
                  label: context.l10n.websites_backendDomain,
                  icon: TablerIcons.at,
                  controller: _proxyHostController,
                  required: true,
                  hint: r'$host',
                  helper: context.l10n.websites_backendDomainHelper,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _FormSection(
              icon: TablerIcons.clock,
              title: context.l10n.websites_cacheSettings,
              children: [
                _CompactServerCacheField(
                  value: _serverCacheEnabled,
                  onChanged: (v) => setState(() => _serverCacheEnabled = v),
                ),
                if (_serverCacheEnabled)
                  _CompactDurationField(
                    label: context.l10n.websites_serverCacheTime,
                    icon: TablerIcons.hourglass,
                    controller: _serverCacheTimeController,
                    unit: _serverCacheUnit,
                    onUnitChanged: (value) =>
                        setState(() => _serverCacheUnit = value),
                  ),
                _CompactCacheModeField(
                  value: _browserCacheMode,
                  onChanged: (v) => setState(() {
                    _browserCacheTouched = true;
                    _browserCacheMode = v;
                  }),
                ),
                if (_browserCacheMode == _BrowserCacheMode.enable)
                  _CompactDurationField(
                    label: context.l10n.websites_browserCacheTime,
                    icon: TablerIcons.clock,
                    controller: _browserCacheTimeController,
                    unit: _browserCacheUnit,
                    onUnitChanged: (value) =>
                        setState(() => _browserCacheUnit = value),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _FormSection(
              icon: TablerIcons.world_share,
              title: context.l10n.websites_corsAccess,
              children: [
                _CompactSwitchTile(
                  icon: TablerIcons.shield_check,
                  title: context.l10n.websites_enableCors,
                  value: _cors,
                  onChanged: (v) => setState(() => _cors = v),
                ),
                if (_cors) ...[
                  _CompactInputField(
                    label: context.l10n.websites_allowedOrigins,
                    icon: TablerIcons.world,
                    controller: _allowOriginsController,
                    required: true,
                    hint: context.l10n.websites_allowedOriginsHint,
                  ),
                  _CompactMethodsField(
                    selectedMethods: _allowMethods,
                    onToggle: (method) {
                      setState(() {
                        if (_allowMethods.contains(method)) {
                          _allowMethods.remove(method);
                        } else {
                          _allowMethods.add(method);
                        }
                      });
                    },
                  ),
                  _CompactInputField(
                    label: context.l10n.websites_allowedHeaders,
                    icon: TablerIcons.file_code,
                    controller: _allowHeadersController,
                    hint: 'Content-Type,Authorization',
                  ),
                  _CompactSwitchTile(
                    icon: TablerIcons.cookie,
                    title: context.l10n.websites_allowCredentials,
                    value: _allowCredentials,
                    onChanged: (v) => setState(() => _allowCredentials = v),
                  ),
                  _CompactSwitchTile(
                    icon: TablerIcons.bolt,
                    title: context.l10n.websites_preflightFastResponse,
                    value: _preflight,
                    onChanged: (v) => setState(() => _preflight = v),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            _FormSection(
              icon: TablerIcons.replace,
              title: context.l10n.websites_textReplacement,
              action: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                onPressed: () => setState(() {
                  _replaces.add(
                    _ReplaceRule(id: _replaceSeq++, search: '', replace: ''),
                  );
                }),
                child: Text(context.l10n.websites_add),
              ),
              children: [
                if (_replaces.isEmpty)
                  _CompactEmptyHint(text: context.l10n.websites_noReplaceRules)
                else
                  Localizations.override(
                    context: context,
                    delegates: const [DefaultMaterialLocalizations.delegate],
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: _replaces.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _replaces.removeAt(oldIndex);
                          _replaces.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = _replaces[index];
                        return ReorderableDragStartListener(
                          key: ValueKey(item.id),
                          index: index,
                          child: _ReplaceRow(
                            item: item,
                            onDelete: () =>
                                setState(() => _replaces.removeAt(index)),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
