import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/plugins/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ShuffleMode {
  on,
  off,
}

class ShuffleModeState {
  ShuffleModeState({this.value = ShuffleMode.off});

  final ShuffleMode value;

  ShuffleModeState copyWith(ShuffleMode shuffleMode) {
    return ShuffleModeState(value: shuffleMode);
  }
}

class ShuffleModeNotifier extends StateNotifier<ShuffleModeState> {
  ShuffleModeNotifier(ShuffleMode shuffleMode)
      : super(ShuffleModeState(value: shuffleMode));

  void changeMode(ShuffleMode shuffleMode) {
    getIt<SharedPreferences>().setString(
      'shuffle_mode',
      shuffleMode == ShuffleMode.off ? 'off' : 'on',
    );

    state = state.copyWith(shuffleMode);
  }
}

final shuffleModeProvider =
    StateNotifierProvider<ShuffleModeNotifier, ShuffleModeState>((ref) {
  String? shuffleModePref =
      getIt<SharedPreferences>().getString('shuffle_mode');

  ShuffleMode? shuffleMode;
  if (shuffleModePref == 'on') {
    shuffleMode = ShuffleMode.on;
  } else if (shuffleModePref == 'off') {
    shuffleMode = ShuffleMode.off;
  }

  return ShuffleModeNotifier(shuffleMode ?? ShuffleMode.off);
});
