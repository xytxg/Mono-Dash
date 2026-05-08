// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firewall_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firewallBaseInfoHash() => r'27a40c62f7f6ee7f9ce0689e47d05eff82b73a7b';

/// See also [firewallBaseInfo].
@ProviderFor(firewallBaseInfo)
final firewallBaseInfoProvider =
    AutoDisposeFutureProvider<FirewallBaseInfoDto>.internal(
      firewallBaseInfo,
      name: r'firewallBaseInfoProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firewallBaseInfoHash,
      dependencies: <ProviderOrFamily>[
        firewallRepositoryProvider,
        activeServerIdProvider,
      ],
      allTransitiveDependencies: <ProviderOrFamily>{
        firewallRepositoryProvider,
        ...?firewallRepositoryProvider.allTransitiveDependencies,
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef FirewallBaseInfoRef = AutoDisposeFutureProviderRef<FirewallBaseInfoDto>;
String _$firewallPortRulesControllerHash() =>
    r'fc7ce50081d030ae1cf88cf1c3cc698cfee114a1';

/// See also [FirewallPortRulesController].
@ProviderFor(FirewallPortRulesController)
final firewallPortRulesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      FirewallPortRulesController,
      FirewallPortRulesState
    >.internal(
      FirewallPortRulesController.new,
      name: r'firewallPortRulesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firewallPortRulesControllerHash,
      dependencies: <ProviderOrFamily>[
        firewallRepositoryProvider,
        activeServerIdProvider,
      ],
      allTransitiveDependencies: <ProviderOrFamily>{
        firewallRepositoryProvider,
        ...?firewallRepositoryProvider.allTransitiveDependencies,
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef _$FirewallPortRulesController =
    AutoDisposeAsyncNotifier<FirewallPortRulesState>;
String _$firewallIpRulesControllerHash() =>
    r'706bf90f706cb8d672d5f3c58df8f0783d16d619';

/// See also [FirewallIpRulesController].
@ProviderFor(FirewallIpRulesController)
final firewallIpRulesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      FirewallIpRulesController,
      FirewallIpRulesState
    >.internal(
      FirewallIpRulesController.new,
      name: r'firewallIpRulesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firewallIpRulesControllerHash,
      dependencies: <ProviderOrFamily>[
        firewallRepositoryProvider,
        activeServerIdProvider,
      ],
      allTransitiveDependencies: <ProviderOrFamily>{
        firewallRepositoryProvider,
        ...?firewallRepositoryProvider.allTransitiveDependencies,
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef _$FirewallIpRulesController =
    AutoDisposeAsyncNotifier<FirewallIpRulesState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
