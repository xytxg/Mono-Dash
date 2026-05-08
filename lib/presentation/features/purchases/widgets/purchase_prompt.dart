import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../servers/screens/premium_purchase_page.dart';

Future<void> showUnlimitedServersPurchasePrompt(
  BuildContext context,
  WidgetRef ref, {
  required int serverCount,
}) async {
  await Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const PremiumPurchasePage(isFromLimitPrompt: true),
    ),
  );
}
