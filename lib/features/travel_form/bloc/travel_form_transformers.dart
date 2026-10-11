import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

/// How long the user must stop typing before a search runs.
const Duration searchDebounceDuration = Duration(milliseconds: 300);

/// Event transformer for "search as you type" events.
///
/// The events are debounced first, so a request only starts once the user has
/// paused typing for [duration]. [restartable] then cancels the handler of an
/// older event when a newer one gets through, which drops the stale response
/// of a slow request.
///
/// The order matters: `switchMap(...).debounceTime(...)` would debounce the
/// handler's *emissions* instead of the input, so every keystroke would still
/// start a request.
EventTransformer<E> debounceRestartable<E>([
  Duration duration = searchDebounceDuration,
]) {
  return (events, mapper) =>
      restartable<E>().call(events.debounceTime(duration), mapper);
}
