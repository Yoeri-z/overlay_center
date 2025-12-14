import 'package:flutter/widgets.dart' as w;

/// A builder that receives a [w.BuildContext] and returns a [w.Widget].
typedef ContextBuilder = w.Widget Function(w.BuildContext context);

/// A generic callback that receives a [w.BuildContext] and returns a value of type [T].
typedef OverlayAction<T> = T Function(w.BuildContext context);
