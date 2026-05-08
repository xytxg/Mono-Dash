import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/runtime/node_script_dto.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/app_picker.dart';
import 'runtime_base_sheet.dart';
import 'runtime_form_components.dart';

const _npmSources = [
  'https://registry.npmjs.org/',
  'https://registry.npmmirror.com/',
  'https://mirrors.cloud.tencent.com/npm/',
  'https://registry.huaweicloud.com/repository/npm/',
];

const _pkgManagers = [
  AppPickerOption(value: 'npm', label: 'npm'),
  AppPickerOption(value: 'yarn', label: 'yarn'),
  AppPickerOption(value: 'pnpm', label: 'pnpm'),
];

/// 打开 Node.js 运行环境创建/编辑 Sheet。
Future<void> showRuntimeNodeSheet(
  BuildContext context, {
  RuntimeDetailDto? editItem,
  required Future<void> Function(RuntimeCreateReq req) onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _RuntimeNodeSheet(editItem: editItem, onSubmit: onSubmit),
  );
}

class _RuntimeNodeSheet extends ConsumerStatefulWidget {
  const _RuntimeNodeSheet({this.editItem, required this.onSubmit});

  final RuntimeDetailDto? editItem;
  final Future<void> Function(RuntimeCreateReq req) onSubmit;

  @override
  ConsumerState<_RuntimeNodeSheet> createState() => _RuntimeNodeSheetState();
}

class _RuntimeNodeSheetState extends ConsumerState<_RuntimeNodeSheet> {
  String _pkgManager = 'npm';
  late String _selectedSource;
  List<NodeScriptDto> _scripts = [];
  String? _selectedScript;
  bool _customScript = false;
  bool _loadingScripts = false;

  @override
  void initState() {
    super.initState();
    final source = widget.editItem?.source ?? '';
    _selectedSource = source.isNotEmpty ? source : _npmSources.first;
  }

  @override
  Widget build(BuildContext context) {
    return RuntimeBaseSheet(
      type: 'node',
      title: widget.editItem != null
          ? context.l10n.runtime_editTitle('Node.js')
          : context.l10n.runtime_createTitle('Node.js'),
      themeColor: CupertinoColors.activeGreen,
      editItem: widget.editItem,
      onSubmit: widget.onSubmit,
      onCodeDirChanged: _loadScripts,
      sourceBuilder: () => _selectedSource,
      onInitEditMode: (item, fieldValues) {
        final params = item.params ?? {};
        _pkgManager = params['PACKAGE_MANAGER']?.toString() ?? 'npm';
        _customScript = params['CUSTOM_SCRIPT']?.toString() == '1';
        if (!_customScript) {
          _selectedScript = params['EXEC_SCRIPT']?.toString();
        }
      },
      onBuildParams: (baseParams) {
        final params = {...baseParams};
        final canUsePnpm = _canUsePnpm(params['NODE_VERSION']?.toString());
        if (_pkgManager == 'pnpm' && !canUsePnpm) {
          _pkgManager = 'npm';
        }
        params['PACKAGE_MANAGER'] = _pkgManager;
        params['CUSTOM_SCRIPT'] = _customScript ? '1' : '0';
        if (!_customScript) {
          params.remove('EXEC_SCRIPT');
          if (_selectedScript != null) {
            params['EXEC_SCRIPT'] = _selectedScript;
          }
        }
        return params;
      },
      extraFieldsBuilder: (context, fieldValues, config, isLoadingConfig) {
        final canUsePnpm = _canUsePnpm(config?.version);
        return Column(
          children: [
            RuntimeSectionCard(
              icon: TablerIcons.package,
              title: context.l10n.runtime_packageConfig,
              themeColor: CupertinoColors.activeGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RuntimeFieldLabel(context.l10n.runtime_packageManager),
                  const SizedBox(height: 7),
                  _buildPkgManagerPicker(canUsePnpm),
                  const SizedBox(height: 12),
                  _buildSourcePicker(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            RuntimeSectionCard(
              icon: TablerIcons.terminal_2,
              title: context.l10n.runtime_startCommandSection,
              themeColor: CupertinoColors.activeGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RuntimeFieldLabel(context.l10n.runtime_runScript),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () =>
                            setState(() => _customScript = !_customScript),
                        child: Text(
                          _customScript
                              ? context.l10n.runtime_selectBuiltinScript
                              : context.l10n.runtime_customCommand,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  if (_customScript)
                    RuntimeEmptyPlaceholder(
                      context.l10n.runtime_customScriptHint,
                    )
                  else ...[
                    if (_loadingScripts)
                      RuntimeStaticRow(
                        label: '',
                        value: context.l10n.runtime_loadingScripts,
                      )
                    else if (_scripts.isEmpty)
                      RuntimeEmptyPlaceholder(context.l10n.runtime_noScripts)
                    else
                      AppInlinePicker<String>(
                        options: [
                          for (final s in _scripts)
                            AppPickerOption(
                              value: s.name,
                              label: '${s.name} (${s.script})',
                            ),
                        ],
                        value:
                            _selectedScript ??
                            (_scripts.isNotEmpty ? _scripts.first.name : ''),
                        onChanged: (v) => setState(() => _selectedScript = v),
                      ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadScripts(String codeDir) async {
    if (codeDir.isEmpty) return;

    setState(() {
      _loadingScripts = true;
      _scripts = [];
    });

    try {
      final repo = await ref.read(runtimeRepositoryProvider.future);
      final scripts = await repo.getNodeScripts(codeDir);
      if (mounted) {
        setState(() {
          _scripts = scripts;
          _loadingScripts = false;
          if (!_customScript && scripts.isNotEmpty && _selectedScript == null) {
            _selectedScript = scripts.first.name;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingScripts = false);
    }
  }

  bool _canUsePnpm(String? version) {
    if (version == null || version.isEmpty) return false;
    final normalized = version.replaceFirst(RegExp(r'^[^\d]*'), '');
    final major = int.tryParse(normalized.split('.').first);
    return major != null && major > 18;
  }

  Widget _buildPkgManagerPicker(bool canUsePnpm) {
    final options = canUsePnpm
        ? _pkgManagers
        : _pkgManagers.where((option) => option.value != 'pnpm').toList();
    final value = options.any((option) => option.value == _pkgManager)
        ? _pkgManager
        : options.first.value;
    return AppInlinePicker<String>(
      options: options,
      value: value,
      onChanged: (value) => setState(() => _pkgManager = value),
    );
  }

  Widget _buildSourcePicker() {
    final options = [
      for (final source in _npmSources)
        AppPickerOption<String>(value: source, label: source),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuntimeFieldLabel(context.l10n.runtime_npmMirrorSource),
        const SizedBox(height: 7),
        AppInlinePicker<String>(
          value: _selectedSource,
          options: options,
          onChanged: (value) => setState(() => _selectedSource = value),
        ),
      ],
    );
  }
}
