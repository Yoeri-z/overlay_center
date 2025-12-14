import 'dart:async';
import 'dart:collection';

import 'package:overlay_center/src/common.dart';
import 'package:overlay_center/src/handler.dart';

/// An implementation of [Handler] that can be manually insterted for testing using
/// [OverlayCenter.instance.registerTestHandler(...)]
///
/// At the end of the test it should also be deregistered using
/// [OverlayCenter.instance.deregisterTestHandler(...)]
class TestOverlayHandler implements Handler {
  final Queue<Object?> _valueQueue;

  /// Creates a [TestOverlayHandler] with [returnValues] that will be returned for each overlay event in the order that they are called.
  TestOverlayHandler(List<Object?> returnValues)
    : _valueQueue = Queue.from(returnValues);

  T _next<T>() {
    if (_valueQueue.isEmpty) {
      throw StateError('No more test overlay return values available');
    }
    final next = _valueQueue.removeFirst();
    if (next is! T) {
      throw StateError(
        'Return value in overlay handler does not match expected value $T of handler.',
      );
    }

    return _valueQueue.removeFirst() as T;
  }

  @override
  T raw<T>(OverlayAction<T> handler) => _next<T>();

  @override
  Future<T?> request<T>(OverlayAction<Future<T?>> handler) =>
      Future.microtask(() => _next<FutureOr<T?>>());
}
