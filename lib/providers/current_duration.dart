import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentDurationState {
  CurrentDurationState({
    this.value = const Duration(seconds: 0),
  });

  final Duration value;

  CurrentDurationState copyWith(Duration? duration) {
    return CurrentDurationState(value: duration ?? value);
  }
}

class CurrentDurationNotifier extends StateNotifier<CurrentDurationState> {
  CurrentDurationNotifier() : super(CurrentDurationState());

  void changeCurrentDuration(Duration duration) =>
      state = state.copyWith(duration);
}

final currentDurationProvider =
    StateNotifierProvider<CurrentDurationNotifier, CurrentDurationState>(
  (ref) => CurrentDurationNotifier(),
);
