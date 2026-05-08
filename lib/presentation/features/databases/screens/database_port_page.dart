import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/frosted_action_button.dart';

/// 修改数据库端口页面。
class DatabasePortPage extends ConsumerStatefulWidget {
  const DatabasePortPage({
    super.key,
    required this.dbType,
    required this.dbName,
    required this.currentPort,
  });

  final String dbType;
  final String dbName;
  final int currentPort;

  @override
  ConsumerState<DatabasePortPage> createState() => _DatabasePortPageState();
}

class _DatabasePortPageState extends ConsumerState<DatabasePortPage> {
  late final TextEditingController _portController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _portController = TextEditingController(
      text: widget.currentPort > 0 ? '${widget.currentPort}' : '',
    );
  }

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _portController.text.trim();
    final port = int.tryParse(text);
    if (port == null || port < 1 || port > 65535) {
      showAppWarningToast(context.l10n.databases_portRange);
      return;
    }
    if (port == widget.currentPort) {
      showAppWarningToast(context.l10n.databases_portUnchanged);
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      await repo.changePort(
        key: widget.dbType,
        name: widget.dbName,
        port: port,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSuccessToast(context.l10n.databases_portChanged(port));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppErrorToast(context.l10n.databases_changeFailed, description: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FrostedScaffold(
      title: context.l10n.databases_port,
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
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        FrostedScaffold.contentTopPadding(context) + 12,
        16,
        40,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            context.l10n.databases_portSettings,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  context.l10n.databases_port,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.label(context),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: CupertinoTextField(
                    controller: _portController,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.label(context),
                    ),
                    decoration: const BoxDecoration(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            context.l10n.databases_portChangeHint,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.tertiaryLabel(context),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
