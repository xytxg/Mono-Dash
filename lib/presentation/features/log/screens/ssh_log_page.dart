import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/ssh_log_provider.dart';
import '../widgets/ssh_log_list.dart';

/// 打开 SSH 登录日志页面。
Future<void> openSshLogPage(BuildContext context, int serverId) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(builder: (_) => SshLogPage(serverId: serverId)),
  );
}

class SshLogPage extends StatelessWidget {
  const SshLogPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _SshLogContent(),
    );
  }
}

class _SshLogContent extends ConsumerStatefulWidget {
  const _SshLogContent();

  @override
  ConsumerState<_SshLogContent> createState() => _SshLogContentState();
}

class _SshLogContentState extends ConsumerState<_SshLogContent> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notifier = ref.read(sshLogControllerProvider.notifier);

    return FrostedScaffold(
      title: _isSearching ? '' : l10n.log_sshLoginLog,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: l10n.log_searchSshPlaceholder,
            onChanged: notifier.searchByInfo,
            onClear: () => notifier.searchByInfo(''),
            onCancel: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              notifier.searchByInfo('');
            },
          );
        }
        return FrostedOverlayMenuButton(
          label: l10n.log_actions,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: l10n.common_search,
              icon: TablerIcons.search,
              action: () {
                setState(() => _isSearching = true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocusNode.requestFocus();
                });
              },
            ),
            FrostedMenuItem(
              text: l10n.common_refresh,
              icon: TablerIcons.refresh,
              action: notifier.refresh,
            ),
          ],
        );
      },
      body: const SshLogList(),
    );
  }
}
