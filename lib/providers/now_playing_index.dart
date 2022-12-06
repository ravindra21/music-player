import 'package:flutter_riverpod/flutter_riverpod.dart';

class NowPlayingIndexState {
  NowPlayingIndexState({
    this.value = -1,
  });

  final int value;

  NowPlayingIndexState copyWith({required int index}) {
    return NowPlayingIndexState(value: index);
  }
}

class NowPlayingIndexNotifier extends StateNotifier<NowPlayingIndexState> {
  NowPlayingIndexNotifier() : super(NowPlayingIndexState());

  void changeIndex(int newIndex) => state = state.copyWith(index: newIndex);
}

final nowPlayingIndexProvider =
    StateNotifierProvider<NowPlayingIndexNotifier, NowPlayingIndexState>(
  (ref) => NowPlayingIndexNotifier(),
);
