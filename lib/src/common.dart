import 'package:flutter/widgets.dart' as w;

/// A builder that receives a [w.BuildContext] and returns a [w.Widget].
typedef ContextBuilder = w.Widget Function(w.BuildContext context);

/// A generic callback that receives a [w.BuildContext] and returns a value of type `Future<T?>`.
typedef OverlayRequest<T> = Future<T?> Function(w.BuildContext context);

typedef OverlaySend = void Function(w.BuildContext context);
