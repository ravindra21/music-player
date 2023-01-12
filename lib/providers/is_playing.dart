import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsPlayingState {
  IsPlayingState({
    this.value = false,
  });

  final bool value;

  IsPlayingState copyWith({required bool isPlaying}) {
    return IsPlayingState(value: isPlaying);
  }
}

class IsPlayingNotifier extends StateNotifier<IsPlayingState> {
  IsPlayingNotifier() : super(IsPlayingState());

  void changeStatus(bool isPlaying) =>
      state = state.copyWith(isPlaying: isPlaying);
}

final isPlayingProvider =
    StateNotifierProvider<IsPlayingNotifier, IsPlayingState>(
  (ref) => IsPlayingNotifier(),
);
