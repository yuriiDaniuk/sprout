import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/sprout_theme.dart';

class SproutTextField extends StatefulWidget {
  const SproutTextField({
    super.key,
    required this.label,
    required this.controller,
    this.password = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final bool password;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<SproutTextField> createState() => _SproutTextFieldState();
}

class _SproutTextFieldState extends State<SproutTextField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) => TextField(
    controller: widget.controller,
    obscureText: widget.password && !_visible,
    keyboardType: widget.keyboardType,
    textInputAction: widget.textInputAction,
    onSubmitted: widget.onSubmitted,
    autofillHints: widget.autofillHints,
    autocorrect:
        !widget.password && widget.keyboardType != TextInputType.emailAddress,
    enableSuggestions: !widget.password,
    textCapitalization: widget.label == 'Name'
        ? TextCapitalization.words
        : TextCapitalization.none,
    style: sproutText(15),
    scrollPadding: const EdgeInsets.all(24),
    decoration: InputDecoration(
      hintText: widget.label,
      hintStyle: sproutText(15, color: SproutColors.muted),
      filled: true,
      fillColor: SproutColors.input,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
      constraints: const BoxConstraints(minHeight: 56),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: SproutColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: SproutColors.green),
      ),
      suffixIcon: widget.password
          ? IconButton(
              tooltip: '${_visible ? 'Hide' : 'Show'} ${widget.label}',
              onPressed: () => setState(() => _visible = !_visible),
              icon: Icon(
                _visible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                size: 20,
                color: SproutColors.muted,
              ),
            )
          : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 48),
    ),
  );
}
