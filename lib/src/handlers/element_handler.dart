import 'dart:async';

import 'package:flutter/widgets.dart';

import '../center.dart';
import '../effect.dart';
import 'handler.dart';

/// A widget that provides a [BuildContext] for the [UICenter] to show ui effects.
/// UI effects are imperative ui side effects, such as dialogs and navigation.
///
/// An [EffectHandler] should be placed in your widget tree, typically
/// below `Scaffold` or `CupertinoScaffold`.
class EffectHandler extends Widget {
  /// Creates a widget that supplies a handler to display ui-effects.
  const EffectHandler({super.key, required this.child});

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  EffectHandlerElement createElement() => EffectHandlerElement(this);
}

/// The element for [EffectHandler].
///
/// This element implements the [Handler] interface and registers itself with
/// [UICenter] when it's mounted, and deregisters when unmounted.
class EffectHandlerElement extends ComponentElement implements Handler {
  /// Creates an element that uses the given widget as its configuration.
  EffectHandlerElement(super.widget);

  @override
  Future<void> request<T>(RequestEffect<T> event) async {
    event.complete(event.callback(this));
  }

  @override
  void send(SendEffect event) {
    event.callback(this);
  }

  @override
  Widget build() => (widget as EffectHandler).child;

  @override
  void update(EffectHandler newWidget) {
    //implementation copied from [StatelessElement]
    super.update(newWidget);
    assert(widget == newWidget);
    rebuild(force: true);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    UICenter.instance.registerHandler(this);
  }

  @override
  void unmount() {
    UICenter.instance.deregisterHandler(this);
    super.unmount();
  }
}
