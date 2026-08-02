import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a Stream (e.g. a Bloc's state stream) into a [Listenable] so
/// go_router's `refreshListenable` can re-evaluate `redirect` whenever it
/// fires, without go_router needing to know anything about Blocs.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
