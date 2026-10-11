import 'dart:async';

/// Whether [error] means a network request was interrupted or never completed
/// (offline, dropped connection, or a browser that suspended the page while
/// the request was in flight) as opposed to the server rejecting it.
///
/// `package:http` is only a transitive dependency, so its `ClientException`
/// (and `dart:io`'s `SocketException`, which is not importable on web) are
/// matched through their `toString()` prefix rather than their type. Their
/// `toString()` is a literal, unlike `runtimeType`, which dart2js minifies in
/// release builds.
bool isNetworkInterruption(Object? error) {
  if (error == null) {
    return false;
  }
  if (error is TimeoutException) {
    return true;
  }
  final description = error.toString();
  return description.startsWith('ClientException') ||
      description.startsWith('SocketException');
}
