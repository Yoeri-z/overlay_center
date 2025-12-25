import 'package:overlay_center/src/common.dart';
import 'package:overlay_center/src/handler.dart';

/// An implementation of [Handler] that can be manually insterted for testing using
/// [OverlayCenter.instance.registerTestHandler(...)]
///
/// At the end of the test it should also be deregistered using
/// [OverlayCenter.instance.deregisterTestHandler(...)]
class TestOverlayHandler implements Handler {
  @override
  Future<T?> request<T>(OverlayRequest<T> handler) {
    throw UnimplementedError();
  }

  @override
  void send(OverlaySend handler) {
    throw UnimplementedError();
  }
}
