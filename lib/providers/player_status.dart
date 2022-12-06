import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerStatusState {
  PlayerStatusState({
    this.value = PlayerState.playing,
  });

  final PlayerState value;

  PlayerStatusState copyWith({PlayerState? playerState}) {
    return PlayerStatusState(
      value: playerState ?? value,
    );
  }
}

class PlayerStatusNotifier extends StateNotifier<PlayerStatusState> {
  PlayerStatusNotifier() : super(PlayerStatusState());

  void changeStatus(PlayerState playerState) =>
      state = state.copyWith(playerState: playerState);
}

final playerStatusProvider =
    StateNotifierProvider<PlayerStatusNotifier, PlayerStatusState>(
  (ref) => PlayerStatusNotifier(),
);
