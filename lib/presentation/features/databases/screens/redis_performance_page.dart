import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/frosted_action_button.dart';
import '../widgets/database_placeholders.dart';

/// Redis 性能调整页面（timeout / maxclients / maxmemory）。
class RedisPerformancePage extends ConsumerStatefulWidget {
  const RedisPerformancePage({
    super.key,
    required this.dbType,
    required this.dbName,
  });

  final String dbType;
  final String dbName;

  @override
  ConsumerState<RedisPerformancePage> createState() =>
      _RedisPerformancePageState();
}

class _RedisPerformancePageState extends ConsumerState<RedisPerformancePage> {
  final _timeoutCtrl = TextEditingController();
  final _maxclientsCtrl = TextEditingController();
  final _maxmemoryCtrl = TextEditingController();

  Object? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadConf();
  }

  @override
  void dispose() {
    _timeoutCtrl.dispose();
    _maxclientsCtrl.dispose();
    _maxmemoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConf() async {
    try {
      final repo = await ref.read(databaseRepositoryProvider.future);
      final conf = await repo.getRedisConf(
        type: widget.dbType,
        name: widget.dbName,
      );
      if (!mounted) return;
      setState(() {
        _timeoutCtrl.text = conf.timeout;
        _maxclientsCtrl.text = conf.maxclients;
        _maxmemoryCtrl.text = conf.maxmemory;
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

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final repo = await ref.read(databaseRepositoryProvider.future);
      await repo.updateRedisConf(
        dbType: widget.dbType,
        database: widget.dbName,
        timeout: _timeoutCtrl.text,
        maxclients: _maxclientsCtrl.text,
        maxmemory: _maxmemoryCtrl.text,
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

    final topPadding = FrostedScaffold.contentTopPadding(context) + 12;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 40),
      children: [
        _buildGroup(context.l10n.databases_perfGroupConnection, [
          _VarTile(
            label: 'timeout',
            description: context.l10n.databases_perfRedisTimeoutDesc,
            controller: _timeoutCtrl,
          ),
          _VarTile(
            label: 'maxclients',
            description: context.l10n.databases_perfRedisMaxclientsDesc,
            controller: _maxclientsCtrl,
          ),
        ]),
        const SizedBox(height: 24),
        _buildGroup(context.l10n.databases_perfGroupMemory, [
          _VarTile(
            label: 'maxmemory',
            description: context.l10n.databases_perfRedisMaxmemoryDesc,
            controller: _maxmemoryCtrl,
          ),
        ]),
      ],
    );
  }

  Widget _buildGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
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
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _VarTile extends StatelessWidget {
  const _VarTile({
    required this.label,
    required this.description,
    required this.controller,
  });

  final String label;
  final String description;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
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
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.label(context),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
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
                  keyboardType: TextInputType.number,
                  placeholder: '-',
                  placeholderStyle: TextStyle(
                    color: AppColors.tertiaryLabel(context),
                  ),
                ),
              ),
            ],
          ),
        ),
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
