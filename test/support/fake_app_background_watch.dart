import 'package:travel_assistant/common/utils/helpers/app_background_watch.dart';

/// Starts a [FakeAppBackgroundWatch]. With [wentToBackground], the app is
/// treated as backgrounded right after the watch starts.
AppBackgroundWatchStarter fakeBackgroundWatch({
  bool wentToBackground = false,
}) => ({onBackground}) {
  if (wentToBackground) {
    onBackground?.call();
  }
  return FakeAppBackgroundWatch(wentToBackground: wentToBackground);
};

/// [AppBackgroundWatch] that needs no `WidgetsBinding`.
class FakeAppBackgroundWatch implements AppBackgroundWatch {
  FakeAppBackgroundWatch({required this.wentToBackground});

  @override
  final bool wentToBackground;

  @override
  void dispose() {}
}
