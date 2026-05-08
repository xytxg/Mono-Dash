import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// 通用的表单项组件，带有图标和标签。
class AppFormItem extends StatelessWidget {
  const AppFormItem({
    super.key,
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.secondaryLabel(context)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

/// 通用的表单输入框，预设了符合设计规范的样式。
class AppFormTextField extends StatelessWidget {
  const AppFormTextField({
    super.key,
    required this.controller,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onSubmitted,
    this.textInputAction,
    this.suffix,
    this.backgroundColor,
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
    this.onTapOutside,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final Color? backgroundColor;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(PointerDownEvent)? onTapOutside;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (maxLines ?? 1) > 1 ? null : 46,
      child: CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onSubmitted: onSubmitted,
        onTapOutside: onTapOutside,
        textInputAction: textInputAction,
        clearButtonMode: OverlayVisibilityMode.editing,
        suffix: suffix,
        style: TextStyle(fontSize: 16, color: AppColors.label(context)),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.tertiaryBackground(context),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        inputFormatters: inputFormatters,
        onChanged: onChanged,
      ),
    );
  }
}
