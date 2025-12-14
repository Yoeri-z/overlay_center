import 'dart:async';

import 'package:flutter/widgets.dart' as w;

import 'package:overlay_center/src/center.dart';
import 'package:overlay_center/src/common.dart';
import 'package:overlay_center/src/handler.dart';

/// A widget that registers itself as a handler for overlay events.
///
/// An [OverlayHandler] should be placed in the widget tree below any widgets
/// needed for overlay actions (like dialogs or snackbars) using
/// [OverlayCenter]. It provides the necessary [w.BuildContext] for these
/// actions to be executed.
///
/// Only one [OverlayHandler] should be active on a page at any given time,
/// you can disable this behaviour by setting `OverlayCenter.instance.debugThrowOnMultipleHandlers` is to `false`.
/// This is not recommended.
class OverlayHandler extends w.Widget {
  /// Creates an [OverlayHandler].
  const OverlayHandler({super.key, required this.child});

  /// The widget below this widget in the tree.
  final w.Widget child;

  @override
  OverlayHandlerElement createElement() => OverlayHandlerElement(this);
}

/// The element for [OverlayHandler].
///
/// This element implements the [Handler] interface and registers itself with
/// [OverlayCenter] when it's mounted, and deregisters when unmounted.
class OverlayHandlerElement extends w.ComponentElement implements Handler {
  /// Creates an element that uses the given widget as its configuration.
  OverlayHandlerElement(super.widget);

  @override
  Future<T?> request<T>(OverlayAction<Future<T?>> action) {
    return action(this);
  }

  @override
  T raw<T>(OverlayAction<T> action) {
    return action(this);
  }

  @override
  w.Widget build() => (widget as OverlayHandler).child;

  @override
  void update(OverlayHandler newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    rebuild(force: true);
  }

  @override
  void mount(w.Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    OverlayCenter.instance.registerHandlerElement(this);
  }

  @override
  void unmount() {
    OverlayCenter.instance.deregisterHandlerElement(this);
    super.unmount();
  }
}
