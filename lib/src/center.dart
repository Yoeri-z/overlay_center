import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:flutter/material.dart' as m;
import 'package:flutter/cupertino.dart' as c;

import 'package:overlay_center/src/common.dart';
import 'package:overlay_center/src/handler.dart';
import 'package:overlay_center/src/testing.dart';
import 'package:overlay_center/src/toast/toast.dart';
import 'package:overlay_center/src/toast/toast_theme.dart';
import 'package:overlay_center/src/widget.dart';
import 'package:overlay_center/src/context_extensions.dart';

/// A centralized manager for showing overlays like dialogs, bottom sheets, and snackbars.
///
/// `OverlayCenter` provides a simple, consistent API for triggering overlays from
/// anywhere in your app, without needing direct access to `BuildContext`. It relies on
/// an [OverlayHandler] being present in the widget tree.
///
/// Example:
/// ```dart
/// OverlayCenter.instance.showDialog((context) => AlertDialog(title: Text('Hi')));
/// ```
class OverlayCenter {
  OverlayCenter._();

  /// The singleton instance of [OverlayCenter].
  static final instance = OverlayCenter._();

  /// When `true`, an assertion will be thrown if multiple [OverlayHandler]
  /// widgets are registered on the same page.
  ///
  /// This is useful for debugging to ensure that there's only one handler active
  /// at a time. If having multiple handlers is intended, set this to `false`.
  /// Defaults to `true`.
  bool debugThrowOnMultipleHandlers = true;

  final _registered = HashSet<Handler>();

  /// Displays a Material dialog.
  ///
  /// A convenience method that wraps `showDialog`. For more complex dialogs
  /// or for more control over the dialog's properties, it is recommended to
  /// create a standalone function and pass it to [request].
  ///
  /// Returns a [Future] that completes to the value passed to [Navigator.pop]
  /// when the dialog is closed.
  Future<T?> showDialog<T>(
    m.Widget dialog, {
    bool barrierDismissible = true,
    String? barrierLabel,
    bool fullscreenDialog = false,
    bool? requestFocus,
  }) {
    return request(
      (context) => m.showDialog(
        context: context,
        builder: (context) => dialog,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        fullscreenDialog: fullscreenDialog,
        requestFocus: requestFocus,
      ),
    );
  }

  /// Displays a Material bottom sheet.
  ///
  /// if [duration] is provided bottom sheet closes automatically after the given duration.
  void showBottomSheet<T>(m.Widget sheet, {Duration? duration}) {
    return send(
      (context) => context.showBottomSheet(sheet, duration: duration),
    );
  }

  /// Shows a [m.SnackBar] at the bottom of the screen.
  void showSnackbar(
    m.SnackBar snackBar, {
    w.AnimationStyle? snackBarAnimationStyle,
  }) {
    return send(
      (context) => context.showSnackBar(
        snackBar,
        snackBarAnimationStyle: snackBarAnimationStyle,
      ),
    );
  }

  /// Shows a [m.MaterialBanner] at the top of the screen.
  ///
  /// if [duration] is provided material banner closes automatically after the given duration.
  void showMaterialBanner(m.MaterialBanner banner, {Duration? duration}) {
    return send(
      (context) => context.showMaterialBanner(banner, duration: duration),
    );
  }

  /// Displays a modal Material bottom sheet.
  ///
  /// A modal bottom sheet is an alternative to a menu or a dialog and prevents
  /// the user from interacting with the rest of the app.
  Future<T?> showModalBottomSheet<T>(m.Widget sheet) {
    return request(
      (context) =>
          m.showModalBottomSheet(context: context, builder: (context) => sheet),
    );
  }

  /// Displays a Cupertino-style dialog.
  Future<T?> showCupertinoDialog<T>(
    c.Widget dialog, {
    bool barrierDismissible = true,
    String? barrierLabel,
    bool? requestFocus,
  }) {
    return request(
      (context) => c.showCupertinoDialog(
        context: context,
        builder: (context) => dialog,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        requestFocus: requestFocus,
      ),
    );
  }

  /// Shows a Cupertino-style modal popup that slides up from the bottom of the screen.
  Future<T?> showCupertinoModalPopup<T>(
    c.Widget modal, {
    bool barrierDismissible = true,
    bool? requestFocus,
  }) {
    return request(
      (context) => c.showCupertinoModalPopup(
        context: context,
        builder: (context) => modal,
        barrierDismissible: barrierDismissible,
        requestFocus: requestFocus,
      ),
    );
  }

  /// Shows a Cupertino-style bottom sheet.
  Future<T?> showCupertinoSheet<T>(c.Widget sheet, {bool enableDrag = true}) {
    return request(
      (context) => c.showCupertinoSheet(
        context: context,
        builder: (context) => sheet,
        enableDrag: enableDrag,
      ),
    );
  }

  /// Show a toast message, this is a custom extra overlay option provided by this package.
  ///
  /// Toasts are a popular way to provide feedback to users on desktop applications.
  void showToast({
    required String message,
    required ToastType toastType,
    ToastAlignment? alignment,
    Duration toastDuration = const Duration(seconds: 2),
    Duration fadeDuration = const Duration(milliseconds: 350),
    bool isDismissible = false,
  }) {
    return send(
      (context) => context.showToast(
        message: message,
        toastType: toastType,
        alignment: alignment,
        toastDuration: toastDuration,
        fadeDuration: fadeDuration,
        isDismissible: isDismissible,
      ),
    );
  }

  /// Executes an asynchronous overlay action that returns a [Future].
  ///
  /// This method finds the registered [OverlayHandler] and uses its context
  /// to execute the provided [action]. It's the foundation for methods like
  /// [showDialog] and [showModalBottomSheet].
  ///
  /// Throws an assertion error in debug mode if no [OverlayHandler] is found.
  Future<T?> request<T>(OverlayRequest<T> action) {
    if (!_assertHasHandler()) return Future.value(null);

    return _registered.first.request(action);
  }

  /// Executes a synchronous overlay action.
  ///
  /// Similar to [request], but for actions that return a value directly,
  /// such as showing a snackbar and getting its controller.
  ///
  /// Throws a [StateError] if no [OverlayHandler] is found.
  void send(OverlaySend action) {
    if (!_assertHasHandler()) {
      throw StateError('No handler registered in current page.');
    }

    _registered.first.send(action);
  }

  bool _assertHasHandler() {
    if (_registered.isEmpty) {
      assert(false, '''
      Attempted to handle an overlay method without a Handler being registered.
      Make sure that an OverlayHandler is in the widget tree on the current page.
    ''');

      return false;
    }
    return true;
  }

  /// Registers an [OverlayHandlerElement] with the center.
  ///
  /// This method is intended to be called by [OverlayHandlerElement] when it is mounted.
  /// It should not be called directly.
  void registerHandlerElement(OverlayHandlerElement element) {
    assert(!_registered.contains(element), '''
        An overlay handler attempted to register itself to the center a second time. 
        This should not happen and it probably indicates an error in the package. 
        Please make an issue on overlay_center's github page.
      ''');

    if (debugThrowOnMultipleHandlers && _registered.length > 1) {
      assert(_registered.length > 1, '''
          Multiple overlay handlers were registered, this means that you have multiple handlers set up in the current app page.
          If this was intended, you can disable this assertion by setting OverlayCenter.instance.debugThrowOnMultipleHandlers to false.
        ''');
    }

    _registered.add(element);
  }

  /// Deregisters an [OverlayHandlerElement] from the center.
  ///
  /// This method is intended to be called by [OverlayHandlerElement] when it is unmounted.
  /// It should not be called directly.
  void deregisterHandlerElement(OverlayHandlerElement element) {
    assert(_registered.contains(element), '''
        An overlay handler attempted to deregister itself from the center while not being registered. 
        This should not happen and it probably indicates an error in the package. 
        Please make an issue on overlay_center's github page.
    ''');

    _registered.remove(element);
  }

  /// Registers a [TestOverlayHandler] for testing purposes.
  ///
  /// Throws a [StateError] if any other handler is already registered.
  @visibleForTesting
  void registerTestHandler(TestOverlayHandler handler) {
    if (_registered.isNotEmpty) {
      throw StateError(
        'Only one test handler can be registered for each test.',
      );
    }
    _registered.add(handler);
  }

  /// Deregisters a [TestOverlayHandler].
  ///
  /// Returns `true` if the handler was successfully removed.
  @visibleForTesting
  bool deregisterTestHandler(TestOverlayHandler handler) {
    return _registered.remove(handler);
  }

  /// Clears all the handlers in the [OverlayCenter], essentially resetting it.
  @visibleForTesting
  void reset() {
    _registered.clear();
  }
}

mixin ScaffoldMessengerExtension on w.BuildContext {
  void showSnackBar(
    m.SnackBar snackBar, {
    w.AnimationStyle? snackbarAnimationStyle,
  }) {
    m.ScaffoldMessenger.of(
      this,
    ).showSnackBar(snackBar, snackBarAnimationStyle: snackbarAnimationStyle);
  }
}
