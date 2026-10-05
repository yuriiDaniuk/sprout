import 'package:flutter/material.dart';

const laterLabMessage = 'This feature will be available in a later lab.';

void showDemoMessage(BuildContext context, String message) {
  FocusScope.of(context).unfocus();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
