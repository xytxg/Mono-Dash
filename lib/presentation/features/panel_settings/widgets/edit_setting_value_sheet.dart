import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_form_components.dart';
import '../../../../core/theme/app_theme.dart';

/// 通用的设置值编辑弹窗。
Future<String?> showEditValueSheet(
  BuildContext context, {
  required String title,
  required String initialValue,
  String placeholder = '',
  String? description,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  bool obscure = false,
  String? Function(String)? validator,
  List<TextInputFormatter>? inputFormatters,
}) {
  return showActionSheet<String>(
    context: context,
    useRootNavigator: true,
    builder: (_) => _EditValueSheet(
      title: title,
      initialValue: initialValue,
      placeholder: placeholder,
      description: description,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscure: obscure,
      validator: validator,
      inputFormatters: inputFormatters,
    ),
  );
}

class _EditValueSheet extends StatefulWidget {
  const _EditValueSheet({
    required this.title,
    required this.initialValue,
    required this.placeholder,
    this.description,
    required this.keyboardType,
    required this.maxLines,
    required this.obscure,
    this.validator,
    this.inputFormatters,
  });

  final String title;
  final String initialValue;
  final String placeholder;
  final String? description;
  final TextInputType keyboardType;
  final int maxLines;
  final bool obscure;
  final String? Function(String)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_EditValueSheet> createState() => _EditValueSheetState();
}

class _EditValueSheetState extends State<_EditValueSheet> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    if (widget.validator != null) {
      _errorText = widget.validator!(widget.initialValue);
      _isValid = _errorText == null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    if (widget.validator == null) return;
    setState(() {
      _errorText = widget.validator!(value);
      _isValid = _errorText == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      isFloating: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.description != null) ...[
            Text(
              widget.description!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryLabel(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          AppFormTextField(
            controller: _controller,
            placeholder: widget.placeholder,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscure,
            maxLines: widget.maxLines,
            inputFormatters: widget.inputFormatters,
            onChanged: _validate,
            onSubmitted: _isValid
                ? (_) => Navigator.of(context).pop(_controller.text.trim())
                : null,
            textInputAction: TextInputAction.done,
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _errorText!,
                style: const TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: _isValid
                  ? () => Navigator.of(context).pop(_controller.text.trim())
                  : null,
              child: Text(
                context.l10n.common_save,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
