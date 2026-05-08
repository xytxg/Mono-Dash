import '../../../core/localization/generated/app_localizations.dart';

String text(Object? value) {
  if (value == null) return '--';
  final t = '$value'.trim();
  return t.isEmpty ? '--' : t;
}

String boolText(Object? value, AppLocalizations l10n) {
  if (value is bool) return value ? l10n.common_yes : l10n.common_no;
  return text(value);
}

int? intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

double? doubleValue(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}
