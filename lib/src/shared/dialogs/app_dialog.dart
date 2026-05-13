import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_measures.dart';
import '../styles/app_typography.dart';

/// Reusable dialog widget
class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<AppDialogAction> actions;
  final Widget? content;
  final EdgeInsets contentPadding;

  const AppDialog({
    Key? key,
    required this.title,
    this.message = '',
    this.actions = const [],
    this.content,
    this.contentPadding = const EdgeInsets.all(AppMeasures.paddingLarge),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTypography.headlineSmall),
      content:
          content ??
          (message.isNotEmpty
              ? Text(message, style: AppTypography.bodyMedium)
              : null),
      contentPadding: contentPadding,
      actions: actions
          .map(
            (action) => TextButton(
              onPressed: () {
                Navigator.pop(context, action.result);
                action.onPressed?.call();
              },
              child: Text(action.label),
            ),
          )
          .toList(),
    );
  }

  /// Show dialog easily
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String message = '',
    Widget? content,
    List<AppDialogAction> actions = const [],
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
      ),
    );
  }
}

/// Dialog action model
class AppDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final dynamic result;

  const AppDialogAction({
    required this.label,
    this.onPressed,
    this.result = true,
  });
}

/// Loading dialog untuk menampilkan progress
class LoadingDialog extends StatelessWidget {
  final String message;
  final bool dismissible;

  const LoadingDialog({
    Key? key,
    this.message = 'Loading...',
    this.dismissible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => dismissible,
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet),
            ),
            SizedBox(height: AppMeasures.paddingLarge),
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Show loading dialog
  static void show({
    required BuildContext context,
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  /// Dismiss loading dialog
  static void dismiss(BuildContext context) {
    Navigator.pop(context);
  }
}

/// Confirmation dialog
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      message: message,
      actions: [
        AppDialogAction(
          label: cancelLabel,
          onPressed: () => onCancel?.call(),
          result: false,
        ),
        AppDialogAction(
          label: confirmLabel,
          onPressed: () => onConfirm(),
          result: true,
        ),
      ],
    );
  }

  /// Show confirmation dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}

