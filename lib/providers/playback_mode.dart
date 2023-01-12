import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/plugins/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  PlaybackModeNotifier(PlaybackMode playbackMode)
      : super(PlaybackModeState(value: playbackMode));

  void changeMode(PlaybackMode playbackMode) {
    String playbackModePref = 'repeat';
    if (playbackMode == PlaybackMode.noRepeat) {
      playbackModePref = 'noRepeat';
    } else if (playbackMode == PlaybackMode.repeatCurrent) {
      playbackModePref = 'repeatCurrent';
    }

    getIt<SharedPreferences>().setString('playback_mode', playbackModePref);
    state = state.copyWith(playbackMode);
  }
}

final playbackModeProvider =
    StateNotifierProvider<PlaybackModeNotifier, PlaybackModeState>((ref) {
  String? playbackModePref =
      getIt<SharedPreferences>().getString('playback_mode');

  PlaybackMode? playbackMode;
  if (playbackModePref == 'noRepeat') {
    playbackMode = PlaybackMode.noRepeat;
  } else if (playbackModePref == 'repeat') {
    playbackMode = PlaybackMode.repeat;
  } else if (playbackModePref == 'repeatCurrent') {
    playbackMode = PlaybackMode.repeatCurrent;
  }

  return PlaybackModeNotifier(playbackMode ?? PlaybackMode.repeat);
});
