import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/api/runtime_api.dart';
import '../../../../data/dto/app/app_install_config_dto.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/app_picker.dart';
import 'runtime_base_sheet.dart';
import 'runtime_form_components.dart';

const _phpMirrorSources = [
  'https://mirrors.tuna.tsinghua.edu.cn',
  'https://mirrors.aliyun.com',
  'https://mirrors.ustc.edu.cn',
  'https://mirrors.163.com',
  'https://mirrors.cloud.tencent.com',
  'https://mirrors.huaweicloud.com',
  'https://deb.debian.org',
  'https://mirrors.xtom.com',
];

/// 打开 PHP 运行环境创建/编辑 Sheet。
Future<void> showRuntimePhpSheet(
  BuildContext context, {
  RuntimeDetailDto? editItem,
  required Future<void> Function(RuntimeCreateReq req) onSubmit,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _RuntimePhpSheet(editItem: editItem, onSubmit: onSubmit),
  );
}

class _RuntimePhpSheet extends ConsumerStatefulWidget {
  const _RuntimePhpSheet({this.editItem, required this.onSubmit});

  final RuntimeDetailDto? editItem;
  final Future<void> Function(RuntimeCreateReq req) onSubmit;

  @override
  ConsumerState<_RuntimePhpSheet> createState() => _RuntimePhpSheetState();
}

class _RuntimePhpSheetState extends ConsumerState<_RuntimePhpSheet> {
  List<PhpExtensionGroupDto> _extGroups = [];
  String? _selectedExtGroup;
  late String _selectedMirror;
  final Map<String, TextEditingController> _fieldControllers = {};

  final _addExtController = TextEditingController();
  final _addExtFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final source = widget.editItem?.source ?? '';
    _selectedMirror = source.isNotEmpty ? source : _phpMirrorSources.first;
    _loadExtGroups();
  }

  @override
  void dispose() {
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    _addExtController.dispose();
    _addExtFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadExtGroups() async {
    try {
      final repo = await ref.read(runtimeRepositoryProvider.future);
      final groups = await repo.searchPhpExtensions();
      if (mounted) {
        setState(() {
          _extGroups = groups;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return RuntimeBaseSheet(
      type: 'php',
      title: widget.editItem != null
          ? context.l10n.runtime_editTitle('PHP')
          : context.l10n.runtime_createTitle('PHP'),
      themeColor: CupertinoColors.systemTeal,
      editItem: widget.editItem,
      onSubmit: widget.onSubmit,
      splitVersionSection: true,
      showProjectSection: false,
      showDockerSections: false,
      installOnCreate: false,
      versionExtraBuilder: (context, fieldValues, config, isLoadingConfig) {
        final fields = config?.params.formFields ?? const [];
        return _buildPhpVersionField(fields, fieldValues, isLoadingConfig);
      },
      onInitEditMode: (item, fieldValues) {
        final params = item.params ?? {};
        if (params['PHP_EXTENSIONS'] is List) {
          fieldValues['PHP_EXTENSIONS'] = List<String>.from(
            params['PHP_EXTENSIONS'],
          );
        } else if (params['PHP_EXTENSIONS'] is String) {
          fieldValues['PHP_EXTENSIONS'] = params['PHP_EXTENSIONS']
              .toString()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      },
      onBuildParams: (baseParams) {
        // PHP-FPM default port
        if (!baseParams.containsKey('PANEL_APP_PORT_HTTP')) {
          baseParams['PANEL_APP_PORT_HTTP'] = 9000;
        }
        baseParams.remove('HOST_IP');
        return baseParams;
      },
      sourceBuilder: () => _selectedMirror,
      imageBuilder: (config, version, params) {
        final imageName = config.image?.trim();
        if (imageName != null && imageName.isNotEmpty) {
          return '$imageName:$version';
        }
        final phpVersion =
            params['PHP_VERSION']?.toString().trim().isNotEmpty == true
            ? params['PHP_VERSION'].toString().trim()
            : version;
        return '1panel-php-fpm:$phpVersion';
      },
      extraFieldsBuilder: (context, fieldValues, config, isLoadingConfig) {
        final extensions = _asStringList(fieldValues['PHP_EXTENSIONS']);
        final fields = config?.params.formFields ?? const [];

        return Column(
          children: [
            RuntimeSectionCard(
              icon: TablerIcons.link,
              title: context.l10n.runtime_aptMirrorSource,
              themeColor: CupertinoColors.systemTeal,
              child: _buildMirrorPicker(),
            ),
            const SizedBox(height: 12),
            RuntimeSectionCard(
              icon: TablerIcons.brand_php,
              title: context.l10n.runtime_phpConfig,
              themeColor: CupertinoColors.systemTeal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFpmPortField(fields, fieldValues, isLoadingConfig),
                  const SizedBox(height: 12),
                  if (_extGroups.isNotEmpty) ...[
                    _buildExtGroupPicker(fieldValues),
                    const SizedBox(height: 12),
                  ],
                  RuntimeFieldLabel(context.l10n.runtime_phpExtensions),
                  const SizedBox(height: 7),
                  _buildExtensionsWrap(fieldValues, extensions),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhpVersionField(
    List<AppInstallFieldDto> fields,
    Map<String, dynamic> fieldValues,
    bool isLoadingConfig,
  ) {
    if (isLoadingConfig) {
      return RuntimeStaticRow(
        label: context.l10n.runtime_phpVersion,
        value: context.l10n.runtime_loading,
      );
    }
    final field = _fieldByKey(fields, 'PHP_VERSION');
    if (field == null) {
      return RuntimeStaticRow(
        label: context.l10n.runtime_phpVersion,
        value: context.l10n.runtime_noVersions,
      );
    }
    return _buildSelectOrInputField(
      field,
      fieldValues,
      fallbackLabel: context.l10n.runtime_phpVersion,
    );
  }

  Widget _buildFpmPortField(
    List<AppInstallFieldDto> fields,
    Map<String, dynamic> fieldValues,
    bool isLoadingConfig,
  ) {
    if (isLoadingConfig) {
      return RuntimeStaticRow(
        label: context.l10n.runtime_phpFpmPort,
        value: context.l10n.runtime_loading,
      );
    }
    final field = _fieldByKey(fields, 'PANEL_APP_PORT_HTTP');
    if (field == null) {
      return RuntimeStaticRow(
        label: context.l10n.runtime_phpFpmPort,
        value: '9000',
      );
    }
    return _buildSelectOrInputField(
      field,
      fieldValues,
      fallbackLabel: context.l10n.runtime_phpFpmPort,
    );
  }

  Widget _buildSelectOrInputField(
    AppInstallFieldDto field,
    Map<String, dynamic> fieldValues, {
    required String fallbackLabel,
  }) {
    final label = field.label.isEmpty ? fallbackLabel : field.label;
    final values = field.values ?? const <AppInstallFieldValue>[];

    if (field.type == 'select' && field.multiple != true && values.isNotEmpty) {
      final options = [
        for (final value in values)
          AppPickerOption<String>(
            value: value.value,
            label: value.label.isEmpty ? value.value : value.label,
          ),
      ];
      final current = fieldValues[field.envKey]?.toString() ?? '';
      final effective = options.any((option) => option.value == current)
          ? current
          : options.first.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RuntimeFieldLabel(label),
          const SizedBox(height: 7),
          AppInlinePicker<String>(
            value: effective,
            options: options,
            enabled: field.edit,
            onChanged: (value) {
              setState(() {
                fieldValues[field.envKey] = value;
              });
            },
          ),
        ],
      );
    }

    final controller = _controllerFor(field.envKey, fieldValues);
    return RuntimeInputRow(
      label: label,
      placeholder: '${field.defaultValue ?? ''}',
      controller: controller,
      enabled: field.edit,
      keyboardType: field.type == 'number'
          ? TextInputType.number
          : TextInputType.text,
      onChanged: (value) {
        fieldValues[field.envKey] = field.type == 'number'
            ? (num.tryParse(value) ?? value)
            : value;
      },
    );
  }

  TextEditingController _controllerFor(
    String key,
    Map<String, dynamic> fieldValues,
  ) {
    final value = fieldValues[key]?.toString() ?? '';
    final controller = _fieldControllers.putIfAbsent(
      key,
      () => TextEditingController(text: value),
    );
    return controller;
  }

  AppInstallFieldDto? _fieldByKey(List<AppInstallFieldDto> fields, String key) {
    for (final field in fields) {
      if (field.envKey == key) return field;
    }
    return null;
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  Widget _buildExtGroupPicker(Map<String, dynamic> fieldValues) {
    final options = [
      for (final g in _extGroups)
        AppPickerOption<String>(value: g.name, label: g.name),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuntimeFieldLabel(context.l10n.runtime_extensionPreset),
        const SizedBox(height: 7),
        AppInlinePicker<String>(
          value: _selectedExtGroup ?? options.first.value,
          options: options,
          onChanged: (name) {
            setState(() {
              _selectedExtGroup = name;
              final group = _extGroups.firstWhere((g) => g.name == name);
              fieldValues['PHP_EXTENSIONS'] = group.extensions
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            });
          },
        ),
      ],
    );
  }

  Widget _buildMirrorPicker() {
    final options = [
      for (final m in _phpMirrorSources)
        AppPickerOption<String>(value: m, label: m),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuntimeFieldLabel(context.l10n.runtime_mirrorSource),
        const SizedBox(height: 7),
        AppInlinePicker<String>(
          value: _selectedMirror,
          options: options,
          onChanged: (v) => setState(() => _selectedMirror = v),
        ),
      ],
    );
  }

  Widget _buildExtensionsWrap(
    Map<String, dynamic> fieldValues,
    List<String> extensions,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground(context).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final ext in extensions)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      extensions.remove(ext);
                      fieldValues['PHP_EXTENSIONS'] = extensions;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CupertinoColors.activeBlue.withValues(
                          alpha: 0.4,
                        ),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ext,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          TablerIcons.x,
                          size: 12,
                          color: CupertinoColors.activeBlue,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (extensions.isNotEmpty) const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: CupertinoTextField(
              controller: _addExtController,
              focusNode: _addExtFocusNode,
              placeholder: context.l10n.runtime_addMore,
              padding: EdgeInsets.zero,
              decoration: null,
              style: TextStyle(fontSize: 13, color: AppColors.label(context)),
              placeholderStyle: TextStyle(
                fontSize: 13,
                color: AppColors.tertiaryLabel(context),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    if (!extensions.contains(value.trim())) {
                      extensions.add(value.trim());
                      fieldValues['PHP_EXTENSIONS'] = extensions;
                    }
                    _addExtController.clear();
                    _addExtFocusNode.requestFocus();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
