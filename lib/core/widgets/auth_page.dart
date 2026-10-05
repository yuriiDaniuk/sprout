import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'brand_header.dart';

/// Keeps the Figma form position on a full screen; scrolls on a short viewport.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.form, required this.footer});

  final Widget form;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
            final heroHeight = keyboardOpen
                ? 196.0
                : math.max(224.0, 320 - topInset);
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        children: [
                          SizedBox(
                            height: heroHeight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: keyboardOpen
                                    ? 24
                                    : math.max(24, 104 - topInset),
                              ),
                              child: const BrandHeader(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
                            child: form,
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                            child: footer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
