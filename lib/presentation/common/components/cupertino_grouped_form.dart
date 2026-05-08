import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_theme.dart';

class AppCupertinoSectionHeader extends StatelessWidget {
  const AppCupertinoSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryLabel(context),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class AppCupertinoGroupedBox extends StatelessWidget {
  const AppCupertinoGroupedBox({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.14),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class AppCupertinoFormTile extends StatelessWidget {
  const AppCupertinoFormTile({
    super.key,
    required this.label,
    required this.child,
    this.isLast = false,
  });

  final String label;
  final Widget child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 44,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.label(context),
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              height: 0.5,
              color: AppColors.separator(context).withValues(alpha: 0.1),
            ),
          ),
      ],
    );
  }
}
