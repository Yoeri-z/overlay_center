import 'dart:async';

import 'package:async/async.dart';

import '../center.dart';
import '../effect.dart';
import 'handler.dart';

/// An implementation of [Handler] for testing purposes.
///
/// This handler does not render any UI. Instead, it adds effects
/// to queues, allowing tests to asynchronously await and inspect them.
///
/// Due to the asynchronous nature of ui side effects, it is recommended
/// to create a new handler for each test and dispose it
/// between tests to ensure a clean state.
///
/// Example:
/// ```dart
/// test('Show and test a dialog', () async {
///   final handler = InspectableEffectHandler();
///
///   final future = UICenter.instance.showDialog(AlertDialog(title: Text('Hi')));
///
///   final event = await handler.requests.next;
///   expect(event.eventType, RequestEventType.showDialog);
///
///   event.complete(true);
///   expect(await future, isTrue);
///
///   handler.dispose
/// });
/// ```
class InspectableEffectHandler implements Handler {
  /// Creates a new [InspectableEffectHandler].
  InspectableEffectHandler()
    : _requestsController = StreamController<RequestEffect>.broadcast(),
      _sendsController = StreamController<SendEffect>.broadcast() {
    requests = StreamQueue(_requestsController.stream);
    sends = StreamQueue(_sendsController.stream);
    UICenter.instance.registerHandler(this);
  }

  final StreamController<RequestEffect> _requestsController;
  final StreamController<SendEffect> _sendsController;

  /// A queue of all [RequestEffect]s that have been recorded.
  ///
  /// Use `await requests.next` to get the next event.
  late StreamQueue<RequestEffect> requests;

  /// A queue of all [SendEffect]s that have been recorded.
  ///
  /// Use `await sends.next` to get the next event.
  late StreamQueue<SendEffect> sends;

  @override
  void request<T>(RequestEffect<T> event) {
    _requestsController.add(event);
  }

  @override
  void send(SendEffect event) {
    _sendsController.add(event);
  }

  /// Closes the event streams.
  ///
  /// This should be called when the handler is no longer needed, typically
  /// at the end of a test suite.
  void dispose() {
    _requestsController.close();
    _sendsController.close();
    UICenter.instance.deregisterHandler(this);
  }
}
