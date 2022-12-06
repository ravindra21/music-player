import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlaybackMode {
  repeatCurrent,
  repeat,
  noRepeat,
}

class PlaybackModeState {
  PlaybackModeState({
    this.value = PlaybackMode.repeat,
  });

  final PlaybackMode value;

  PlaybackModeState copyWith(PlaybackMode playbackMode) {
    return PlaybackModeState(value: playbackMode);
  }
}

class PlaybackModeNotifier extends StateNotifier<PlaybackModeState> {
  PlaybackModeNotifier() : super(PlaybackModeState());

  void changeMode(PlaybackMode playbackMode) =>
      state = state.copyWith(playbackMode);
}

final playbackModeProvider =
    StateNotifierProvider<PlaybackModeNotifier, PlaybackModeState>(
        (ref) => PlaybackModeNotifier());
