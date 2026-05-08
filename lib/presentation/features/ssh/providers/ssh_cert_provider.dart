import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../data/api/host_api.dart';
import '../../../../data/dto/host/ssh_cert_dto.dart';
import '../../../common/app_toast.dart';
import '../../server_detail/providers/active_server_provider.dart';

part 'ssh_cert_provider.g.dart';

@Riverpod(dependencies: [activeServerId])
class SshCertController extends _$SshCertController {
  @override
  FutureOr<List<SshCertDto>> build() async {
    final serverId = ref.watch(activeServerIdProvider);
    final client = await ref.watch(dioClientProvider(serverId).future);
    final result = await HostApi(client).searchCerts();
    return result.items;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      final result = await HostApi(client).searchCerts();
      return result.items;
    });
  }

  Future<bool> createCert(SshCertOperateReq req) async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      await HostApi(client).createCert(req);
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.ssh_certCreated);
      return true;
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.ssh_createFailed, description: '$e');
      return false;
    }
  }

  Future<bool> editCert(SshCertOperateReq req) async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      await HostApi(client).editCert(req);
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.ssh_certUpdated);
      return true;
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.ssh_updateFailed, description: '$e');
      return false;
    }
  }

  Future<bool> deleteCert(int id) async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      await HostApi(client).deleteCert([id]);
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.ssh_certDeleted);
      return true;
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.ssh_deleteFailed, description: '$e');
      return false;
    }
  }

  Future<bool> syncCert() async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final client = await ref.read(dioClientProvider(serverId).future);
      await HostApi(client).syncCert();
      await refresh();
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(l10n.ssh_syncCompleted);
      return true;
    } catch (e) {
      final l10n = ref.read(appLocalizationsProvider);
      showAppErrorToast(l10n.ssh_syncFailed, description: '$e');
      return false;
    }
  }
}
