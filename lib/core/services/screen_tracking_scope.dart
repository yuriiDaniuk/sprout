import 'package:flutter/widgets.dart';

class ScreenTrackingScope extends InheritedWidget {
  const ScreenTrackingScope({
    super.key,
    required this.observer,
    required super.child,
  });

  final RouteObserver<PageRoute<dynamic>> observer;

  static RouteObserver<PageRoute<dynamic>>? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ScreenTrackingScope>()
          ?.observer;

  @override
  bool updateShouldNotify(ScreenTrackingScope oldWidget) =>
      observer != oldWidget.observer;
}
