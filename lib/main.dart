import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/features/settings/providers/app_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Mono Dash booted');

  final storageService = StorageService();
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
      child: const ToastificationWrapper(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeOption = ref.watch(localeControllerProvider);
    final appearanceMode =
        ref.watch(appSettingsControllerProvider).valueOrNull?.appearanceMode ??
        AppAppearanceMode.system;

    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).app_title,
      theme: switch (appearanceMode) {
        AppAppearanceMode.system => AppTheme.systemTheme,
        AppAppearanceMode.light => AppTheme.lightTheme,
        AppAppearanceMode.dark => AppTheme.darkTheme,
      },
      routerConfig: appRouter,
      locale: localeOption.toLocale(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
