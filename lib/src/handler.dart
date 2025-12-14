import 'package:overlay_center/src/common.dart';

abstract interface class Handler {
  /// Handles an overlay request which is an overlay event that returns a value
  Future<T?> request<T>(OverlayAction<Future<T?>> handler);

  /// Handles an overlay request that can return anything, including controllers.
  T raw<T>(OverlayAction<T> handler);
}
