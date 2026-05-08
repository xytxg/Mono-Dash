// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardControllerHash() =>
    r'f0e0779a9cb800521ed65d923dbf7be44c9ab568';

/// 仪表盘数据加载器，依赖当前激活服务器。
///
/// - 首次 build：拉取监控选项与 base/current，初始化历史序列。
/// - 可见时刷新：由 DashboardPage 在概览 Tab 可见时每秒触发一次 current。
/// - 下拉刷新：直接拉一次 current，不清空旧数据（避免图表闪白）。
/// - 出错恢复：`state` 无值时，`refresh()` 会触发 provider 重建。
///
/// Copied from [DashboardController].
@ProviderFor(DashboardController)
final dashboardControllerProvider = AutoDisposeAsyncNotifierProvider<
    DashboardController, DashboardViewState>.internal(
  DashboardController.new,
  name: r'dashboardControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardControllerHash,
  dependencies: <ProviderOrFamily>[dashboardRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    dashboardRepositoryProvider,
    ...?dashboardRepositoryProvider.allTransitiveDependencies
  },
);

typedef _$DashboardController = AutoDisposeAsyncNotifier<DashboardViewState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
