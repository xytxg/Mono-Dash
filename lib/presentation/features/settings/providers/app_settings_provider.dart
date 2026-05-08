import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/generated/app_localizations.dart';

part 'app_settings_provider.g.dart';

enum AppIconVariant {
  defaultIcon(null, 'assets/icons/1panel_mate_app_icon_2.png'),
  icon3('icon_3', 'assets/icons/1panel_mate_app_icon_3.png'),
  icon4('icon_4', 'assets/icons/1panel_mate_app_icon_4.png'),
  icon5('icon_5', 'assets/icons/1panel_mate_app_icon_5.png');

  const AppIconVariant(this.alternateIconName, this.assetPath);

  final String? alternateIconName;
  final String assetPath;

  String labelOf(AppLocalizations l10n) => switch (this) {
    AppIconVariant.defaultIcon => l10n.settings_appIcon_default,
    AppIconVariant.icon3 => l10n.settings_appIcon_variant(3),
    AppIconVariant.icon4 => l10n.settings_appIcon_variant(4),
    AppIconVariant.icon5 => l10n.settings_appIcon_variant(5),
  };

  static AppIconVariant fromName(String? name) {
    return values.firstWhere(
      (variant) => variant.alternateIconName == name,
      orElse: () => AppIconVariant.defaultIcon,
    );
  }
}

enum ServerCardStyle {
  terminal('terminal'),
  simple('simple');

  const ServerCardStyle(this.name);

  final String name;

  String labelOf(AppLocalizations l10n) => switch (this) {
    ServerCardStyle.terminal => l10n.settings_cardStyle_terminal,
    ServerCardStyle.simple => l10n.settings_cardStyle_simple,
  };

  static ServerCardStyle fromName(String? name) {
    return values.firstWhere(
      (style) => style.name == name,
      orElse: () => ServerCardStyle.simple,
    );
  }
}

class AppSettings {
  const AppSettings({
    this.appIconVariant = AppIconVariant.defaultIcon,
    this.serverCardStyle = ServerCardStyle.simple,
    this.requestTimeoutSeconds = 60,
    this.customHeaders = const {},
  });

  final AppIconVariant appIconVariant;
  final ServerCardStyle serverCardStyle;
  final int requestTimeoutSeconds;
  final Map<String, String> customHeaders;

  AppSettings copyWith({
    AppIconVariant? appIconVariant,
    ServerCardStyle? serverCardStyle,
    int? requestTimeoutSeconds,
    Map<String, String>? customHeaders,
  }) {
    return AppSettings(
      appIconVariant: appIconVariant ?? this.appIconVariant,
      serverCardStyle: serverCardStyle ?? this.serverCardStyle,
      requestTimeoutSeconds:
          requestTimeoutSeconds ?? this.requestTimeoutSeconds,
      customHeaders: customHeaders ?? this.customHeaders,
    );
  }
}

@riverpod
class AppSettingsController extends _$AppSettingsController {
  static const _appIconVariantKey = 'app_icon_variant';
  static const _serverCardStyleKey = 'server_card_style';
  static const _requestTimeoutSecondsKey = 'request_timeout_seconds';
  static const _customHeadersKey = 'custom_headers';
  static const defaultRequestTimeoutSeconds = 60;

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = AppSettings(
      appIconVariant: AppIconVariant.fromName(
        prefs.getString(_appIconVariantKey),
      ),
      serverCardStyle: ServerCardStyle.fromName(
        prefs.getString(_serverCardStyleKey),
      ),
      requestTimeoutSeconds:
          prefs.getInt(_requestTimeoutSecondsKey) ??
          defaultRequestTimeoutSeconds,
      customHeaders: _decodeHeaders(prefs.getString(_customHeadersKey)),
    );
    return settings;
  }

  Future<void> setAppIconVariant(AppIconVariant variant) async {
    final previous = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(previous.copyWith(appIconVariant: variant));

    final prefs = await SharedPreferences.getInstance();
    final iconName = variant.alternateIconName;
    if (iconName == null) {
      await prefs.remove(_appIconVariantKey);
    } else {
      await prefs.setString(_appIconVariantKey, iconName);
    }
  }

  Future<void> setServerCardStyle(ServerCardStyle style) async {
    final previous = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(previous.copyWith(serverCardStyle: style));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverCardStyleKey, style.name);
  }

  Future<void> setRequestTimeoutSeconds(int seconds) async {
    final value = seconds.clamp(5, 300);
    final previous = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(previous.copyWith(requestTimeoutSeconds: value));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_requestTimeoutSecondsKey, value);
  }

  Future<void> setCustomHeaders(Map<String, String> headers) async {
    final normalized = Map<String, String>.unmodifiable(headers);
    final previous = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(previous.copyWith(customHeaders: normalized));

    final prefs = await SharedPreferences.getInstance();
    if (normalized.isEmpty) {
      await prefs.remove(_customHeadersKey);
    } else {
      await prefs.setString(_customHeadersKey, jsonEncode(normalized));
    }
  }

  static Map<String, String> _decodeHeaders(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return const {};
    }
  }
}
