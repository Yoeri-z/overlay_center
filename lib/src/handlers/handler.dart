import '../effect.dart';

/// Defines the contract for an effect handler.
///
/// A [Handler] is responsible for processing effects dispatched
/// by the [UICenter]. This allows for different implementations, such
/// as one that renders UI and another for testing.
abstract interface class Handler {
  /// Handles an [RequestEffect] that expects a value in return.
  ///
  /// The handler should execute the effect and complete the event's
  /// future when the effect is dismissed.
  void request<T>(RequestEffect<T> event);

  /// Handles an [SendEffect] that is fire-and-forget.
  ///
  /// The handler should execute the effect without needing
  /// to return a value.
  void send(SendEffect event);
}
