import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/api/app_api.dart';
import '../../../../data/dto/app/app_catalog_dto.dart';
import '../../../../data/dto/app/app_catalog_search_req.dart';
import '../../../../data/dto/app/app_install_config_dto.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_picker.dart';
import '../../../common/components/defer_init.dart';
import '../../server_detail/providers/active_server_provider.dart';
import 'runtime_dotnet_sheet.dart';
import 'runtime_form_components.dart';
import 'runtime_go_sheet.dart';
import 'runtime_java_sheet.dart';
import 'runtime_node_sheet.dart';
import 'runtime_php_sheet.dart';
import 'runtime_python_sheet.dart';

/// 根据类型自动打开对应的运行环境创建/编辑 Sheet。
Future<void> showRuntimeSheet(
  BuildContext context, {
  required String type,
  RuntimeDetailDto? editItem,
  required Future<void> Function(RuntimeCreateReq req) onSubmit,
}) {
  switch (type) {
    case 'php':
      return showRuntimePhpSheet(
        context,
        editItem: editItem,
        onSubmit: onSubmit,
      );
    case 'node':
      return showRuntimeNodeSheet(
        context,
        editItem: editItem,
        onSubmit: onSubmit,
      );
    case 'java':
      return showRuntimeJavaSheet(
        context,
        editItem: editItem,
        onSubmit: onSubmit,
      );
    case 'go':
      return showRuntimeGoSheet(
        context,
        editItem: editItem,
        onSubmit: onSubmit,
      );
    case 'python':
      return showRuntimePythonSheet(
        context,
        editItem: editItem,
        onSubmit: onSubmit,
      );
    case 'dotnet':
      return showRuntimeDotnetSheet(
        context,
        editItem: editItem,
        onSubmit: onSubmit,
      );
    default:
      return showRuntimeGoSheet(
        context,
        editItem: editItem,
        onSubmit: onSubmit,
      );
  }
}

/// 一个通用的运行环境创建/编辑 Sheet 组件。
class RuntimeBaseSheet extends ConsumerStatefulWidget {
  const RuntimeBaseSheet({
    super.key,
    required this.type,
    required this.title,
    required this.themeColor,
    required this.onSubmit,
    this.editItem,
    this.versionExtraBuilder,
    this.extraFieldsBuilder,
    this.onBuildParams,
    this.sourceBuilder,
    this.imageBuilder,
    this.onInitEditMode,
    this.onCodeDirChanged,
    this.splitVersionSection = false,
    this.showProjectSection = true,
    this.showDockerSections = true,
    this.installOnCreate = true,
  });

  final String type;
  final String title;
  final Color themeColor;
  final Future<void> Function(RuntimeCreateReq req) onSubmit;
  final RuntimeDetailDto? editItem;
  final bool splitVersionSection;
  final bool showProjectSection;
  final bool showDockerSections;
  final bool installOnCreate;

  /// 版本选择区域内的自定义字段。
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> fieldValues,
    AppInstallConfigDto? config,
    bool isLoadingConfig,
  )?
  versionExtraBuilder;

  /// 代码目录变化回调。
  final ValueChanged<String>? onCodeDirChanged;

  /// 自定义字段构建器。
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> fieldValues,
    AppInstallConfigDto? config,
    bool isLoadingConfig,
  )?
  extraFieldsBuilder;

  /// 自定义参数构建逻辑。
  final Map<String, dynamic> Function(Map<String, dynamic> baseParams)?
  onBuildParams;

  /// 可选的运行环境源码/镜像源字段。
  final String? Function()? sourceBuilder;

  /// 可选的运行环境镜像构建逻辑。
  final String Function(
    AppInstallConfigDto config,
    String version,
    Map<String, dynamic> params,
  )?
  imageBuilder;

  /// 编辑模式下的自定义初始化逻辑。
  final void Function(RuntimeDetailDto item, Map<String, dynamic> fieldValues)?
  onInitEditMode;

  @override
  ConsumerState<RuntimeBaseSheet> createState() => _RuntimeBaseSheetState();
}

class _RuntimeBaseSheetState extends ConsumerState<RuntimeBaseSheet> {
  bool get _isEdit => widget.editItem != null;

  final _nameController = TextEditingController();
  final _containerNameController = TextEditingController();
  final _remarkController = TextEditingController();
  final _codeDirController = TextEditingController(text: '/');
  final _execScriptController = TextEditingController();

  // App store state
  List<AppCatalogDto> _apps = [];
  AppCatalogDto? _selectedApp;
  List<String> _versions = [];
  String? _selectedVersion;
  AppInstallConfigDto? _installConfig;

  // Dynamic form values
  final Map<String, dynamic> _fieldValues = {};
  Map<String, dynamic> _editParams = {};

  bool _loadingApps = true;
  bool _loadingVersions = false;
  bool _loadingConfig = false;
  bool _submitting = false;
  bool _deferredReady = false;

  // Container config
  final List<RuntimePortMapping> _ports = [];
  final List<RuntimeEnvMapping> _environments = [];
  final List<RuntimeVolumeMapping> _volumes = [];
  final List<RuntimeHostMapping> _extraHosts = [];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _initEditMode();
    }
  }

  void _onDeferredReady() {
    if (_isEdit) {
      _loadAppsForEdit(widget.editItem!);
    } else {
      _loadApps();
    }
  }

  void _initEditMode() {
    final item = widget.editItem!;
    _nameController.text = item.name;
    _containerNameController.text = item.containerName;
    _remarkController.text = item.remark;
    _codeDirController.text = item.codeDir.isNotEmpty ? item.codeDir : '/';

    // Restore params
    final params = item.params ?? {};
    _execScriptController.text = params['EXEC_SCRIPT']?.toString() ?? '';

    // Restore mappings
    for (final ep in item.exposedPorts) {
      _ports.add(
        RuntimePortMapping(
          hostPort: TextEditingController(text: '${ep.hostPort}'),
          containerPort: TextEditingController(text: '${ep.containerPort}'),
          isPublic: ep.hostIP == '0.0.0.0',
        ),
      );
    }

    for (final env in item.environments) {
      _environments.add(
        RuntimeEnvMapping(
          key: TextEditingController(text: env.key),
          value: TextEditingController(text: env.value),
        ),
      );
    }

    for (final vol in item.volumes) {
      _volumes.add(
        RuntimeVolumeMapping(
          source: TextEditingController(text: vol.source),
          target: TextEditingController(text: vol.target),
        ),
      );
    }

    for (final host in item.extraHosts) {
      _extraHosts.add(
        RuntimeHostMapping(
          hostname: TextEditingController(text: host.hostname),
          ip: TextEditingController(text: host.ip),
        ),
      );
    }

    _editParams = Map<String, dynamic>.from(params);

    if (widget.onInitEditMode != null) {
      widget.onInitEditMode!(item, _fieldValues);
    }

    if (widget.onCodeDirChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onCodeDirChanged!(_codeDirController.text);
      });
    }

    _loadAppsForEdit(item);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _containerNameController.dispose();
    _remarkController.dispose();
    _codeDirController.dispose();
    _execScriptController.dispose();
    for (final p in _ports) {
      p.dispose();
    }
    for (final e in _environments) {
      e.dispose();
    }
    for (final v in _volumes) {
      v.dispose();
    }
    for (final h in _extraHosts) {
      h.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // API Loading
  // ---------------------------------------------------------------------------

  Future<void> _loadApps() async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      final appApi = AppApi(client);
      final result = await appApi.searchApps(
        AppCatalogSearchReq(type: widget.type, page: 1, pageSize: 100),
      );
      final apps = result.items
          .where((app) => app.type.isEmpty || app.type == widget.type)
          .toList();
      if (mounted) {
        setState(() {
          _apps = apps;
          _loadingApps = false;
          if (_apps.isNotEmpty) {
            _selectedApp = _apps.first;
            _loadVersions();
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingApps = false);
    }
  }

  Future<void> _loadAppsForEdit(RuntimeDetailDto editItem) async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      final appApi = AppApi(client);
      final result = await appApi.searchApps(
        AppCatalogSearchReq(type: widget.type, page: 1, pageSize: 100),
      );
      final apps = result.items
          .where((app) => app.type.isEmpty || app.type == widget.type)
          .toList();
      if (!mounted) return;

      _apps = apps;
      _loadingApps = false;

      if (editItem.appID > 0) {
        _selectedApp = _apps.cast<AppCatalogDto?>().firstWhere(
          (a) => a?.id == editItem.appID,
          orElse: () => _apps.isNotEmpty ? _apps.first : null,
        );
      } else if (_apps.isNotEmpty) {
        _selectedApp = _apps.first;
      }

      if (_selectedApp != null) {
        final detail = await appApi.getAppDetail(_selectedApp!.key);
        if (!mounted) return;
        _versions = detail.versions;
        _selectedVersion = _versions.contains(editItem.version)
            ? editItem.version
            : (_versions.isNotEmpty ? _versions.first : null);

        if (_selectedVersion != null) {
          final config = await appApi.getAppRuntimeConfig(
            _selectedApp!.id,
            _selectedVersion!,
          );
          if (!mounted) return;
          _installConfig = config;

          for (final field in config.params.formFields) {
            _fieldValues[field.envKey] = _initialFieldValue(field);
          }
          _editParams = Map<String, dynamic>.from(editItem.params ?? {});
          _applyEditParams(config);
          if (editItem.containerName.isNotEmpty) {
            _fieldValues['CONTAINER_NAME'] = editItem.containerName;
          }
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadVersions() async {
    final app = _selectedApp;
    if (app == null) return;

    setState(() {
      _loadingVersions = true;
      _versions = [];
      _selectedVersion = null;
      _installConfig = null;
    });

    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      final appApi = AppApi(client);
      final detail = await appApi.getAppDetail(app.key);
      if (mounted) {
        setState(() {
          _versions = detail.versions;
          _loadingVersions = false;
          if (_versions.isNotEmpty) {
            _selectedVersion = _versions.first;
            _loadConfig();
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingVersions = false);
    }
  }

  Future<void> _loadConfig() async {
    final app = _selectedApp;
    final version = _selectedVersion;
    if (app == null || version == null) return;

    setState(() {
      _loadingConfig = true;
      _installConfig = null;
      _fieldValues.clear();
    });

    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      final appApi = AppApi(client);
      final config = await appApi.getAppRuntimeConfig(app.id, version);
      if (mounted) {
        setState(() {
          _installConfig = config;
          _loadingConfig = false;
          for (final field in config.params.formFields) {
            _fieldValues[field.envKey] = _initialFieldValue(field);
          }
          if (_isEdit) _applyEditParams(config);
          _syncContainerName(_nameController.text);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingConfig = false);
    }
  }

  void _applyEditParams(AppInstallConfigDto config) {
    for (final entry in _editParams.entries) {
      if (config.params.formFields.any((f) => f.envKey == entry.key)) {
        _fieldValues[entry.key] = entry.value;
      }
    }
  }

  dynamic _initialFieldValue(AppInstallFieldDto field) {
    final defaultValue = field.defaultValue;
    if (field.multiple == true) {
      if (defaultValue is List) return defaultValue;
      if (defaultValue is String && defaultValue.trim().isNotEmpty) {
        return defaultValue
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return <String>[];
    }
    if (field.type == 'select') {
      final defaultText = defaultValue?.toString() ?? '';
      final values = field.values;
      if (defaultText.isNotEmpty &&
          (values == null || values.any((v) => v.value == defaultText))) {
        return defaultText;
      }
      if (values != null && values.isNotEmpty) return values.first.value;
      return defaultText;
    }
    if (field.type == 'number') {
      if (defaultValue is num) return defaultValue;
      return num.tryParse(defaultValue?.toString() ?? '') ?? defaultValue;
    }
    return defaultValue;
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  void _syncContainerName(String value) {
    final name = value.trim();
    final current = _containerNameController.text.trim();
    final previous = _fieldValues['CONTAINER_NAME']?.toString().trim() ?? '';
    if (current.isEmpty || current == previous) {
      _containerNameController.text = name;
    }
    _fieldValues['CONTAINER_NAME'] =
        _containerNameController.text.trim().isEmpty
        ? name
        : _containerNameController.text.trim();
  }

  void _addPort() => setState(() => _ports.add(RuntimePortMapping()));

  void _removePort(int index) {
    setState(() {
      _ports[index].dispose();
      _ports.removeAt(index);
    });
  }

  void _addEnvironment() =>
      setState(() => _environments.add(RuntimeEnvMapping()));

  void _removeEnvironment(int index) {
    setState(() {
      _environments[index].dispose();
      _environments.removeAt(index);
    });
  }

  void _addVolume() => setState(() => _volumes.add(RuntimeVolumeMapping()));

  void _removeVolume(int index) {
    setState(() {
      _volumes[index].dispose();
      _volumes.removeAt(index);
    });
  }

  void _addExtraHost() => setState(() => _extraHosts.add(RuntimeHostMapping()));

  void _removeExtraHost(int index) {
    setState(() {
      _extraHosts[index].dispose();
      _extraHosts.removeAt(index);
    });
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppErrorToast(context.l10n.runtime_nameRequired);
      return;
    }
    if (!_isEdit && _selectedApp == null) {
      showAppErrorToast(context.l10n.runtime_appLoadFailed);
      return;
    }
    if (_selectedVersion == null) {
      showAppErrorToast(context.l10n.runtime_versionRequired);
      return;
    }
    if (_installConfig == null) {
      showAppErrorToast(context.l10n.runtime_configLoading);
      return;
    }

    final containerName = _containerNameController.text.trim().isEmpty
        ? name
        : _containerNameController.text.trim();
    final containerNameRegExp = RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_.-]*$');
    if (!containerNameRegExp.hasMatch(containerName)) {
      showAppErrorToast(context.l10n.runtime_containerNameInvalid);
      return;
    }

    final codeDir = _codeDirController.text.trim();
    if (widget.showProjectSection && codeDir.isEmpty) {
      showAppErrorToast(context.l10n.runtime_codeDirRequired);
      return;
    }

    // Validate ports
    final hostPorts = <int>{};
    final containerPorts = <int>{};
    for (final p in _ports) {
      final hp = int.tryParse(p.hostPort.text.trim());
      final cp = int.tryParse(p.containerPort.text.trim());
      if (hp == null || hp <= 0 || hp > 65535) {
        showAppErrorToast(context.l10n.runtime_hostPortInvalid);
        return;
      }
      if (cp == null || cp <= 0 || cp > 65535) {
        showAppErrorToast(context.l10n.runtime_containerPortInvalid);
        return;
      }
      if (!hostPorts.add(hp)) {
        showAppErrorToast(context.l10n.runtime_hostPortDuplicate(hp));
        return;
      }
      if (!containerPorts.add(cp)) {
        showAppErrorToast(context.l10n.runtime_containerPortDuplicate(cp));
        return;
      }
    }

    final config = _installConfig!;
    final execScript = _execScriptController.text.trim();

    var params = <String, dynamic>{
      'CONTAINER_NAME': containerName,
      'HOST_IP': '0.0.0.0',
      if (execScript.isNotEmpty) 'EXEC_SCRIPT': execScript,
    };

    // Merge dynamic form fields
    for (final field in config.params.formFields) {
      final key = field.envKey;
      if (key.isEmpty || key == 'CONTAINER_NAME') continue;
      if (_fieldValues.containsKey(key)) {
        params[key] = _fieldValues[key];
      }
    }

    if (widget.onBuildParams != null) {
      params = widget.onBuildParams!(params);
    }

    final exposedPorts = _ports
        .map(
          (p) => ExposedPort(
            hostPort: int.tryParse(p.hostPort.text.trim()) ?? 0,
            containerPort: int.tryParse(p.containerPort.text.trim()) ?? 0,
            hostIP: p.isPublic ? '0.0.0.0' : '127.0.0.1',
          ),
        )
        .toList();

    final environments = _environments
        .where((e) => e.key.text.trim().isNotEmpty)
        .map(
          (e) => EnvironmentVar(
            key: e.key.text.trim(),
            value: e.value.text.trim(),
          ),
        )
        .toList();

    final volumes = _volumes
        .where((v) => v.source.text.trim().isNotEmpty)
        .map(
          (v) => VolumeMount(
            source: v.source.text.trim(),
            target: v.target.text.trim(),
          ),
        )
        .toList();

    final extraHosts = _extraHosts
        .where((h) => h.hostname.text.trim().isNotEmpty)
        .map(
          (h) =>
              ExtraHost(hostname: h.hostname.text.trim(), ip: h.ip.text.trim()),
        )
        .toList();

    final version = _selectedVersion!;
    String image;
    if (_isEdit) {
      image = widget.editItem!.image;
    } else if (widget.imageBuilder != null) {
      image = widget.imageBuilder!(config, version, params);
    } else {
      final imageName = config.image?.trim();
      image = imageName != null && imageName.isNotEmpty
          ? '$imageName:$version'
          : '';
    }

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        RuntimeCreateReq(
          id: _isEdit ? widget.editItem!.id : null,
          name: name,
          appDetailID: _isEdit ? widget.editItem!.appDetailID : config.id,
          image: image,
          params: params,
          type: widget.type,
          resource: 'appstore',
          version: version,
          source: widget.sourceBuilder?.call(),
          codeDir: widget.showProjectSection ? codeDir : null,
          rebuild: _isEdit ? true : null,
          install: _isEdit ? null : widget.installOnCreate,
          clean: _isEdit ? null : false,
          exposedPorts: exposedPorts,
          environments: environments,
          volumes: volumes,
          extraHosts: extraHosts,
          remark: _remarkController.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          _isEdit
              ? context.l10n.runtime_saveFailed
              : context.l10n.runtime_createFailed,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      maxHeightFactor: 0.92,
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
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const CupertinoActivityIndicator(radius: 10)
                  : Text(
                      _isEdit
                          ? context.l10n.common_save
                          : context.l10n.common_create,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
      child: DeferInit(
        builder: (context, isReady) {
          if (!isReady) {
            return _buildSkeleton(context);
          }
          // 首次 ready 时触发数据加载
          if (!_deferredReady) {
            _deferredReady = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _onDeferredReady();
            });
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 4),
                if (widget.splitVersionSection) ...[
                  RuntimeSectionCard(
                    icon: TablerIcons.server_2,
                    title: context.l10n.runtime_appSelection,
                    themeColor: widget.themeColor,
                    child: Column(
                      children: [
                        _buildVersionPicker(),
                        if (widget.versionExtraBuilder != null) ...[
                          const SizedBox(height: 12),
                          widget.versionExtraBuilder!(
                            context,
                            _fieldValues,
                            _installConfig,
                            _loadingConfig,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // 基本配置
                RuntimeSectionCard(
                  icon: TablerIcons.settings,
                  title: context.l10n.runtime_basicConfig,
                  themeColor: widget.themeColor,
                  child: Column(
                    children: [
                      if (!widget.splitVersionSection) ...[
                        _buildVersionPicker(),
                        const SizedBox(height: 12),
                      ],
                      RuntimeInputRow(
                        label: context.l10n.runtime_name,
                        placeholder: 'my-${widget.type}',
                        controller: _nameController,
                        onChanged: _syncContainerName,
                        enabled: !_isEdit,
                      ),
                      const SizedBox(height: 12),
                      RuntimeInputRow(
                        label: context.l10n.runtime_containerName,
                        placeholder:
                            context.l10n.runtime_containerNamePlaceholder,
                        controller: _containerNameController,
                      ),
                    ],
                  ),
                ),
                if (widget.showProjectSection) ...[
                  const SizedBox(height: 12),
                  // 项目配置
                  RuntimeSectionCard(
                    icon: TablerIcons.folder,
                    title: context.l10n.runtime_projectConfig,
                    themeColor: widget.themeColor,
                    child: Column(
                      children: [
                        RuntimeCodeDirRow(
                          controller: _codeDirController,
                          isEdit: _isEdit,
                          onSelected: (path) {
                            _codeDirController.text = path;
                            if (widget.onCodeDirChanged != null) {
                              widget.onCodeDirChanged!(path);
                            }
                          },
                          onEditingComplete: () {
                            if (widget.onCodeDirChanged != null) {
                              widget.onCodeDirChanged!(
                                _codeDirController.text.trim(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        RuntimeInputRow(
                          label: context.l10n.runtime_startCommand,
                          placeholder: context.l10n.runtime_startCommandExample(
                            _getExampleExecScript(),
                          ),
                          controller: _execScriptController,
                        ),
                      ],
                    ),
                  ),
                ],

                if (widget.extraFieldsBuilder != null) ...[
                  const SizedBox(height: 12),
                  widget.extraFieldsBuilder!(
                    context,
                    _fieldValues,
                    _installConfig,
                    _loadingConfig,
                  ),
                ],

                if (widget.showDockerSections) ...[
                  const SizedBox(height: 12),
                  // 端口映射
                  RuntimeSectionCard(
                    icon: TablerIcons.plug,
                    title: context.l10n.runtime_portMappings,
                    themeColor: widget.themeColor,
                    onAdd: _addPort,
                    description: _ports.isEmpty
                        ? null
                        : Text(
                            context.l10n.runtime_portPublicHint,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.tertiaryLabel(
                                context,
                              ).withValues(alpha: 0.8),
                            ),
                          ),
                    child: RuntimePortMappingsSection(
                      ports: _ports,
                      themeColor: widget.themeColor,
                      onTogglePublic: (i) => setState(
                        () => _ports[i].isPublic = !_ports[i].isPublic,
                      ),
                      onRemove: _removePort,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 环境变量
                  RuntimeSectionCard(
                    icon: TablerIcons.variable,
                    title: context.l10n.runtime_environmentVariables,
                    themeColor: widget.themeColor,
                    onAdd: _addEnvironment,
                    child: RuntimeEnvironmentSection(
                      environments: _environments,
                      onRemove: _removeEnvironment,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 挂载
                  RuntimeSectionCard(
                    icon: TablerIcons.folders,
                    title: context.l10n.runtime_mounts,
                    themeColor: widget.themeColor,
                    onAdd: _addVolume,
                    child: RuntimeVolumesSection(
                      volumes: _volumes,
                      onSourceSelected: (i, path) =>
                          setState(() => _volumes[i].source.text = path),
                      onRemove: _removeVolume,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 主机映射
                  RuntimeSectionCard(
                    icon: TablerIcons.network,
                    title: context.l10n.runtime_hostMappings,
                    themeColor: widget.themeColor,
                    onAdd: _addExtraHost,
                    child: RuntimeExtraHostsSection(
                      extraHosts: _extraHosts,
                      onRemove: _removeExtraHost,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // 其他
                RuntimeSectionCard(
                  icon: TablerIcons.notes,
                  title: context.l10n.runtime_other,
                  themeColor: widget.themeColor,
                  child: RuntimeInputRow(
                    label: context.l10n.runtime_remark,
                    placeholder: context.l10n.runtime_optional,
                    controller: _remarkController,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 4),
          if (widget.splitVersionSection) ...[
            RuntimeSectionCard(
              icon: TablerIcons.server_2,
              title: context.l10n.runtime_appSelection,
              themeColor: widget.themeColor,
              child: _skeletonRow(context, context.l10n.runtime_version),
            ),
            const SizedBox(height: 12),
          ],
          RuntimeSectionCard(
            icon: TablerIcons.settings,
            title: context.l10n.runtime_basicConfig,
            themeColor: widget.themeColor,
            child: Column(
              children: [
                if (!widget.splitVersionSection) ...[
                  _skeletonRow(context, context.l10n.runtime_version),
                  const SizedBox(height: 12),
                ],
                _skeletonRow(context, context.l10n.runtime_name),
                const SizedBox(height: 12),
                _skeletonRow(context, context.l10n.runtime_containerName),
              ],
            ),
          ),
          if (widget.showProjectSection) ...[
            const SizedBox(height: 12),
            RuntimeSectionCard(
              icon: TablerIcons.folder,
              title: context.l10n.runtime_projectConfig,
              themeColor: widget.themeColor,
              child: Column(
                children: [
                  _skeletonRow(context, context.l10n.runtime_codeDirectory),
                  const SizedBox(height: 12),
                  _skeletonRow(context, context.l10n.runtime_startCommand),
                ],
              ),
            ),
          ],
          if (widget.extraFieldsBuilder != null) ...[
            const SizedBox(height: 12),
            RuntimeSectionCard(
              icon: TablerIcons.adjustments,
              title: ' ',
              themeColor: widget.themeColor,
              child: Column(
                children: [
                  _skeletonBlock(context, 36),
                  const SizedBox(height: 12),
                  _skeletonBlock(context, 36),
                ],
              ),
            ),
          ],
          if (widget.showDockerSections) ...[
            const SizedBox(height: 12),
            RuntimeSectionCard(
              icon: TablerIcons.plug,
              title: context.l10n.runtime_portMappings,
              themeColor: widget.themeColor,
              child: _skeletonBlock(context, 48),
            ),
            const SizedBox(height: 12),
            RuntimeSectionCard(
              icon: TablerIcons.variable,
              title: context.l10n.runtime_environmentVariables,
              themeColor: widget.themeColor,
              child: _skeletonBlock(context, 48),
            ),
            const SizedBox(height: 12),
            RuntimeSectionCard(
              icon: TablerIcons.folders,
              title: context.l10n.runtime_mounts,
              themeColor: widget.themeColor,
              child: _skeletonBlock(context, 48),
            ),
            const SizedBox(height: 12),
            RuntimeSectionCard(
              icon: TablerIcons.network,
              title: context.l10n.runtime_hostMappings,
              themeColor: widget.themeColor,
              child: _skeletonBlock(context, 48),
            ),
          ],
          const SizedBox(height: 12),
          RuntimeSectionCard(
            icon: TablerIcons.notes,
            title: context.l10n.runtime_other,
            themeColor: widget.themeColor,
            child: _skeletonRow(context, context.l10n.runtime_remark),
          ),
        ],
      ),
    );
  }

  Widget _skeletonRow(BuildContext context, String label) {
    return Row(
      children: [
        RuntimeFieldLabel(label),
        const SizedBox(width: 12),
        Expanded(child: _skeletonBlock(context, 36)),
      ],
    );
  }

  Widget _skeletonBlock(BuildContext context, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildVersionPicker() {
    if (_loadingApps) {
      return RuntimeStaticRow(
        label: context.l10n.runtime_version,
        value: context.l10n.runtime_loadingApps,
      );
    }
    if (_loadingVersions) {
      return RuntimeStaticRow(
        label: context.l10n.runtime_version,
        value: context.l10n.runtime_loading,
      );
    }
    if (_versions.isEmpty) {
      return RuntimeStaticRow(
        label: context.l10n.runtime_version,
        value: context.l10n.runtime_noVersions,
      );
    }

    final options = [
      for (final v in _versions) AppPickerOption<String>(value: v, label: v),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuntimeFieldLabel(context.l10n.runtime_version),
        const SizedBox(height: 7),
        AppInlinePicker<String>(
          options: options,
          value:
              _selectedVersion ??
              (options.isNotEmpty ? options.first.value : ''),
          enabled: !_loadingConfig,
          onChanged: (v) {
            setState(() {
              _selectedVersion = v;
              _loadConfig();
            });
          },
        ),
      ],
    );
  }

  String _getExampleExecScript() {
    switch (widget.type) {
      case 'php':
        return 'php app.php';
      case 'node':
        return 'npm start';
      case 'java':
        return 'java -jar app.jar';
      case 'go':
        return 'go run main.go';
      case 'python':
        return 'python app.py';
      case 'dotnet':
        return 'dotnet run';
      default:
        return '';
    }
  }
}
