import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

/// 应用内统一用 toastification 展示简短提示（替代单按钮 AlertDialog）。
void showAppToast(
  String title, {
  ToastificationType type = ToastificationType.info,
  String? description,
  String? copyTextOnTap,
  Duration autoCloseDuration = const Duration(seconds: 4),
}) {
  toastification.show(
    alignment: Alignment.topCenter,
    type: type,
    style: ToastificationStyle.fillColored,
    title: Text(title),
    description: description != null && description.isNotEmpty
        ? Text(description)
        : null,
    callbacks: copyTextOnTap == null
        ? const ToastificationCallbacks()
        : ToastificationCallbacks(
            onTap: (_) async {
              await Clipboard.setData(ClipboardData(text: copyTextOnTap));
            },
          ),
    autoCloseDuration: autoCloseDuration,
  );
}

void showAppErrorToast(String title, {String? description, String? copyText}) =>
    showAppToast(
      title,
      type: ToastificationType.error,
      description: description,
      copyTextOnTap: copyText ?? description,
    );

void showAppSuccessToast(String title, {String? description}) => showAppToast(
  title,
  type: ToastificationType.success,
  description: description,
);

void showAppWarningToast(String title, {String? description}) => showAppToast(
  title,
  type: ToastificationType.warning,
  description: description,
);

void showAppTodoToast(String title, {String? description}) =>
    showAppToast(title, description: description);
