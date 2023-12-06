import 'package:flutter/material.dart';

//This widget is used to show feedback button when user is waiting for a response in async operations
class AsyncTextButtonWidget extends StatefulWidget {
  final String buttonText;
  final Future<void> Function() onPressed;
  const AsyncTextButtonWidget(
      {super.key, required this.buttonText, required this.onPressed});

  @override
  State<AsyncTextButtonWidget> createState() => _AsyncTextButtonWidgetState();
}

class _AsyncTextButtonWidgetState extends State<AsyncTextButtonWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      style: const ButtonStyle(
        enableFeedback: true,
      ),
      onPressed: isLoading ? null : changeButtonState,
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
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
