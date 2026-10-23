import 'package:flutter/widgets.dart';

/// Records whether the app left the foreground while some work was running.
///
/// On the web, a hidden tab (another tab selected, the browser minimized, the
/// phone locked) is reported as hidden/paused, which is when a browser may
/// suspend its in-flight requests.
abstract interface class AppBackgroundWatch {
  /// Whether the app was hidden or paused since the watch started.
  bool get wentToBackground;

  /// Stops watching.
  void dispose();
}

/// Starts an [AppBackgroundWatch]. [onBackground] runs the first time the app
/// leaves the foreground.
typedef AppBackgroundWatchStarter =
    AppBackgroundWatch Function({void Function()? onBackground});

/// [AppBackgroundWatch] backed by an [AppLifecycleListener].
class LifecycleAppBackgroundWatch implements AppBackgroundWatch {
  LifecycleAppBackgroundWatch._(this._onBackground) {
    _listener = AppLifecycleListener(
      onHide: _markBackground,
      onPause: _markBackground,
    );
  }

  /// Starts watching the app lifecycle.
  static AppBackgroundWatch start({void Function()? onBackground}) =>
      LifecycleAppBackgroundWatch._(onBackground);

  final void Function()? _onBackground;
  late final AppLifecycleListener _listener;
  bool _wentToBackground = false;

  @override
  bool get wentToBackground => _wentToBackground;

  void _markBackground() {
    if (_wentToBackground) {
      return;
    }
    _wentToBackground = true;
    _onBackground?.call();
  }

  @override
  void dispose() => _listener.dispose();
}
