import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/frosted_action_button.dart';
import '../widgets/database_placeholders.dart';

/// MySQL 性能调整页面。
class DatabasePerformancePage extends ConsumerStatefulWidget {
  const DatabasePerformancePage({
    super.key,
    required this.dbType,
    required this.dbName,
  });

  final String dbType;
  final String dbName;

  @override
  ConsumerState<DatabasePerformancePage> createState() =>
      _DatabasePerformancePageState();
}

class _DatabasePerformancePageState
    extends ConsumerState<DatabasePerformancePage> {
  MysqlVariables? _variables;
  Object? _error;
  bool _loading = true;
  bool _saving = false;

  // Values being edited (key -> controller).
  final Map<String, TextEditingController> _controllers = {};

  List<_VariableGroup> get _groups {
    final l10n = context.l10n;
    return [
      _VariableGroup(l10n.databases_perfGroupConnection, [
        _VarDef(
          'maxConnections',
          'max_connections',
          l10n.databases_perfMaxConnections,
        ),
        _VarDef(
          'threadCacheSize',
          'thread_cache_size',
          l10n.databases_perfThreadCacheSize,
        ),
        _VarDef(
          'threadStackSize',
          'thread_stack',
          l10n.databases_perfThreadStackSize,
        ),
      ]),
      _VariableGroup(l10n.databases_perfGroupBuffer, [
        _VarDef(
          'joinBufferSize',
          'join_buffer_size',
          l10n.databases_perfJoinBufferSize,
        ),
        _VarDef(
          'sortBufferSize',
          'sort_buffer_size',
          l10n.databases_perfSortBufferSize,
        ),
        _VarDef(
          'readBufferSize',
          'read_buffer_size',
          l10n.databases_perfReadBufferSize,
        ),
        _VarDef(
          'readRndBufferSize',
          'read_rnd_buffer_size',
          l10n.databases_perfReadRndBufferSize,
        ),
        _VarDef(
          'tmpTableSize',
          'tmp_table_size',
          l10n.databases_perfTmpTableSize,
        ),
        _VarDef(
          'maxHeapTableSize',
          'max_heap_table_size',
          l10n.databases_perfMaxHeapTableSize,
        ),
      ]),
      _VariableGroup('InnoDB', [
        _VarDef(
          'innodbBufferPoolSize',
          'innodb_buffer_pool_size',
          l10n.databases_perfInnodbBufferPoolSize,
        ),
        _VarDef(
          'innodbLogBufferSize',
          'innodb_log_buffer_size',
          l10n.databases_perfInnodbLogBufferSize,
        ),
      ]),
      _VariableGroup(l10n.databases_perfGroupQuery, [
        _VarDef(
          'keyBufferSize',
          'key_buffer_size',
          l10n.databases_perfKeyBufferSize,
        ),
        _VarDef(
          'tableOpenCache',
          'table_open_cache',
          l10n.databases_perfTableOpenCache,
        ),
        _VarDef(
          'queryCacheSize',
          'query_cache_size',
          l10n.databases_perfQueryCacheSize,
        ),
        _VarDef(
          'queryCacheType',
          'query_cache_type',
          l10n.databases_perfQueryCacheType,
        ),
      ]),
      _VariableGroup(l10n.databases_perfGroupOther, [
        _VarDef(
          'binlogCacheSize',
          'binlog_cache_size',
          l10n.databases_perfBinlogCacheSize,
        ),
      ]),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadVariables();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadVariables() async {
    try {
      final repo = await ref.read(databaseRepositoryProvider.future);
      final vars = await repo.loadVariables(
        type: widget.dbType,
        name: widget.dbName,
      );
      if (!mounted) return;
      _initControllers(vars);
      setState(() {
        _variables = vars;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _initControllers(MysqlVariables vars) {
    final values = _variablesToMap(vars);
    for (final group in _groups) {
      for (final def in group.vars) {
        _controllers[def.key] = TextEditingController(
          text: values[def.key] ?? '',
        );
      }
    }
  }

  Map<String, String> _variablesToMap(MysqlVariables v) {
    return {
      'binlogCacheSize': v.binlogCacheSize ?? '',
      'innodbBufferPoolSize': v.innodbBufferPoolSize ?? '',
      'innodbLogBufferSize': v.innodbLogBufferSize ?? '',
      'joinBufferSize': v.joinBufferSize ?? '',
      'keyBufferSize': v.keyBufferSize ?? '',
      'longQueryTime': v.longQueryTime ?? '',
      'maxConnections': v.maxConnections ?? '',
      'maxHeapTableSize': v.maxHeapTableSize ?? '',
      'queryCacheSize': v.queryCacheSize ?? '',
      'queryCacheType': v.queryCacheType ?? '',
      'readBufferSize': v.readBufferSize ?? '',
      'readRndBufferSize': v.readRndBufferSize ?? '',
      'slowQueryLog': v.slowQueryLog ?? '',
      'sortBufferSize': v.sortBufferSize ?? '',
      'tableOpenCache': v.tableOpenCache ?? '',
      'threadCacheSize': v.threadCacheSize ?? '',
      'threadStackSize': v.threadStackSize ?? '',
      'tmpTableSize': v.tmpTableSize ?? '',
    };
  }

  Map<String, dynamic> _collectChangedVariables() {
    final original = _variablesToMap(_variables!);
    final changed = <Map<String, dynamic>>[];
    for (final group in _groups) {
      for (final def in group.vars) {
        final newValue = _controllers[def.key]!.text;
        if (newValue != original[def.key]) {
          changed.add({'param': _toSnakeCase(def.key), 'value': newValue});
        }
      }
    }
    return {'changed': changed};
  }

  String _toSnakeCase(String camelCase) {
    return camelCase.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '_${m.group(0)!.toLowerCase()}',
    );
  }

  Future<void> _save() async {
    final collected = _collectChangedVariables();
    final changed = collected['changed'] as List<Map<String, dynamic>>;
    if (changed.isEmpty) {
      showAppWarningToast(context.l10n.databases_noChanges);
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = await ref.read(databaseRepositoryProvider.future);
      await repo.updateVariables(
        type: widget.dbType,
        database: widget.dbName,
        variables: changed,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSuccessToast(context.l10n.databases_performanceParamsSaved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppErrorToast(context.l10n.databases_saveFailed, description: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FrostedScaffold(
      title: context.l10n.databases_performanceTuning,
      trailingBuilder: (isDark, isOverlapping) => FrostedActionButton(
        text: context.l10n.common_save,
        isDark: isDark,
        isOverlapping: isOverlapping,
        isLoading: _saving,
        onTap: _save,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (_error != null) {
      return DatabaseErrorPlaceholder(
        error: _error!,
        iconColor: CupertinoColors.systemRed.resolveFrom(context),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        FrostedScaffold.contentTopPadding(context) + 12,
        16,
        40,
      ),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return _buildGroup(group);
      },
    );
  }

  Widget _buildGroup(_VariableGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              group.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryLabel(context),
                letterSpacing: 0.2,
              ),
            ),
          ),
          Container(
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
            child: Column(
              children: [
                for (int i = 0; i < group.vars.length; i++)
                  _buildVariableTile(
                    group.vars[i],
                    isLast: i == group.vars.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariableTile(_VarDef def, {required bool isLast}) {
    final controller = _controllers[def.key]!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      def.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.label(context),
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (def.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        def.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: CupertinoTextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.label(context),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const BoxDecoration(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  keyboardType: TextInputType.text,
                  placeholder: '-',
                  placeholderStyle: TextStyle(
                    color: AppColors.tertiaryLabel(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              height: 0.5,
              color: AppColors.separator(context).withValues(alpha: 0.1),
            ),
          ),
      ],
    );
  }
}

class _VariableGroup {
  const _VariableGroup(this.title, this.vars);
  final String title;
  final List<_VarDef> vars;
}

class _VarDef {
  const _VarDef(this.key, this.label, [this.description]);
  final String key;
  final String label;
  final String? description;
}
