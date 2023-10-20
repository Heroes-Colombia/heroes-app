import 'package:flutter/material.dart';

//This widget is used to show feedback button when user is waiting for a response in async operations
class AsyncButtonWidget extends StatefulWidget {
  final String buttonText;
  final Future<void> Function() onPressed;
  const AsyncButtonWidget(
      {super.key, required this.buttonText, required this.onPressed});

  @override
  State<AsyncButtonWidget> createState() => _AsyncButtonWidgetState();
}

class _AsyncButtonWidgetState extends State<AsyncButtonWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(theme.colorScheme.primary),
        enableFeedback: true,
      ),
      onPressed: isLoading ? null : changeButtonState,
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: theme.colorScheme.onPrimary,
                strokeWidth: 2.0,
              ),
            )
          : Text(widget.buttonText),
    );
  }

  changeButtonState() async {
    setState(() => isLoading = true);
    await widget.onPressed();
    setState(() => isLoading = false);
  }
}
