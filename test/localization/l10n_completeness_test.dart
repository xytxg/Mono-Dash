import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zh covers all en localization keys', () async {
    final en = await File(
      'lib/core/localization/l10n/app_en.arb',
    ).readAsString();
    final zh = await File(
      'lib/core/localization/l10n/app_zh.arb',
    ).readAsString();

    final enKeys = (jsonDecode(en) as Map<String, dynamic>).keys
        .where((key) => !key.startsWith('@'))
        .toSet();
    final zhKeys = (jsonDecode(zh) as Map<String, dynamic>).keys
        .where((key) => !key.startsWith('@'))
        .toSet();

    expect(enKeys.difference(zhKeys), isEmpty, reason: 'zh missing keys');
    expect(zhKeys.difference(enKeys), isEmpty, reason: 'zh has stale keys');
  });
}
