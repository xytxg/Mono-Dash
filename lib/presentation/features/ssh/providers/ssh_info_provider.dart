import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../data/api/host_api.dart';
import '../../../../data/dto/host/ssh_info_dto.dart';
import '../../../common/app_toast.dart';
import '../../server_detail/providers/active_server_provider.dart';

part 'ssh_info_provider.g.dart';

@Riverpod(dependencies: [activeServerId])
class SshInfoController extends _$SshInfoController {
  @override
  FutureOr<SshInfoDto> build() async {
    final serverId = ref.watch(activeServerIdProvider);
    final client = await ref.watch(dioClientProvider(serverId).future);
    return HostApi(client).getSshInfo();
  }

  Future<void> refresh() async {
    final hadValue = state.hasValue;
    if (!hadValue) state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      return HostApi(client).getSshInfo();
    });
  }

  Future<bool> operate(String operation) async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      await HostApi(client).operateSsh(operation);
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.ssh_operationCompleted);
      return true;
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.ssh_operationFailed, description: '$e');
      return false;
    }
  }

  Future<bool> updateConfig(String key, String newValue) async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      await HostApi(client).updateSsh(key, newValue);
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.ssh_configUpdated);
      return true;
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.ssh_updateFailed, description: '$e');
      return false;
    }
  }

  /// 读取 SSH 配置文件内容（`"authKeys"` / `"sshdConfOptions"` / `"sshdConfPath:<path>"`）。
  Future<String> loadSshFile(String name) async {
    final serverId = ref.read(activeServerIdProvider);
    final client = await ref.read(dioClientProvider(serverId).future);
    return HostApi(client).loadSshFile(name);
  }

  /// 写入 SSH 配置文件（`key` 为 `"authKeys"` 或 `"sshdConfPath"`）。
  Future<bool> updateSshFile(String key, String path, String value) async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      await HostApi(client).updateSshFile(key, path, value);
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.ssh_configUpdated);
      return true;
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.ssh_updateFailed, description: '$e');
      return false;
    }
  }
}
