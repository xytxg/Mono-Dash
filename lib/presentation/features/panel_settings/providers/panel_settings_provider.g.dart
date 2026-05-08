// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$panelSettingsControllerHash() =>
    r'44e4bb310f25a43feb4115924e71ba4d7ba961c6';

/// See also [PanelSettingsController].
@ProviderFor(PanelSettingsController)
final panelSettingsControllerProvider = AutoDisposeAsyncNotifierProvider<
    PanelSettingsController, PanelSettingsViewState>.internal(
  PanelSettingsController.new,
  name: r'panelSettingsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$panelSettingsControllerHash,
  dependencies: <ProviderOrFamily>[settingRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    settingRepositoryProvider,
    ...?settingRepositoryProvider.allTransitiveDependencies
  },
);

typedef _$PanelSettingsController
    = AutoDisposeAsyncNotifier<PanelSettingsViewState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
