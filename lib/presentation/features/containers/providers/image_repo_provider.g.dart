// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_repo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageRepoControllerHash() =>
    r'69cde32428bcf7092ab0337aecf3bd039fd931eb';

/// See also [ImageRepoController].
@ProviderFor(ImageRepoController)
final imageRepoControllerProvider = AutoDisposeAsyncNotifierProvider<
    ImageRepoController, ImageRepoState>.internal(
  ImageRepoController.new,
  name: r'imageRepoControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imageRepoControllerHash,
  dependencies: <ProviderOrFamily>[containerRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    containerRepositoryProvider,
    ...?containerRepositoryProvider.allTransitiveDependencies
  },
);

typedef _$ImageRepoController = AutoDisposeAsyncNotifier<ImageRepoState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
