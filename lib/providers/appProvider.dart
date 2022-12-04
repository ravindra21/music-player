import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:riverpod/riverpod.dart';

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

class CurrentFileState {
  CurrentFileState({
    this.value,
  });

  final File? value;

  CurrentFileState copyWith(File? file) {
    return CurrentFileState(value: file ?? value);
  }
}

class CurrentFileNotifier extends StateNotifier<CurrentFileState> {
  CurrentFileNotifier() : super(CurrentFileState());

  void changeFile(File file) =>
      state = state.copyWith(file);
}

class PlaylistState {
  PlaylistState({
    this.value,
  });

  final List<File>? value;

  PlaylistState copyWith(List<File>? playlist) {
    return PlaylistState(value: playlist ?? value);
  }
}

class PlaylistNotifier extends StateNotifier<PlaylistState> {
  PlaylistNotifier({
    required this.ref
  }) : super(PlaylistState());

  final StateNotifierProviderRef ref;

  void set(List<File>? playlist) {
    if(playlist == null) {
      AsyncValue<List<File>> files = ref.watch(filesProvider);
      files.when(
        data: (value) {
          state = state.copyWith(value);
          },
        loading: () {},
        error: (err, stack) {
          if(kDebugMode) { print('err $err'); }
        },
      );
    } else {
      state = state.copyWith(playlist);
    }
  }
}

class OriginalPlaylistState {
  OriginalPlaylistState({
    this.value = const [],
  });

  final List<File?> value;

  OriginalPlaylistState copyWith(List<File?> playlist) {
    return OriginalPlaylistState(value: playlist);
  }
}

class OriginalPlaylistNotifier extends StateNotifier<OriginalPlaylistState> {
  OriginalPlaylistNotifier() : super(OriginalPlaylistState());

  void set(List<File?> playlist) {
      state = state.copyWith(playlist);
  }
}

enum PlaybackMode {
  repeatCurrent,
  repeat,
  noRepeat,
}

class PlaybackModeState {
  PlaybackModeState({
    this.value = PlaybackMode.repeatCurrent,
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

enum ShuffleMode {
  on,
  off,
}

class ShuffleModeState {
  ShuffleModeState({
    this.value = ShuffleMode.off,
  });

  final ShuffleMode value;

  ShuffleModeState copyWith(ShuffleMode shuffleMode) {
    return ShuffleModeState(value: shuffleMode);
  }
}

class ShuffleModeNotifier extends StateNotifier<ShuffleModeState> {
  ShuffleModeNotifier() : super(ShuffleModeState());

  void changeMode(ShuffleMode shuffleMode) =>
      state = state.copyWith(shuffleMode);
}

class PlayedIndexState {
  PlayedIndexState({
    this.value = const [],
  });

  final List<int?> value;

  PlayedIndexState copyWith(List<int?> playedIndex) {
    return PlayedIndexState(value: playedIndex);
  }
}

class PlayedIndexNotifier extends StateNotifier<PlayedIndexState> {
  PlayedIndexNotifier() : super(PlayedIndexState());

  void replace(List<int?> index) =>
      state = state.copyWith(index);
}

final playerStatusProvider =
    StateNotifierProvider<PlayerStatusNotifier, PlayerStatusState>(
  (ref) => PlayerStatusNotifier(),
);

final nowPlayingIndexProvider =
    StateNotifierProvider<NowPlayingIndexNotifier, NowPlayingIndexState>(
  (ref) => NowPlayingIndexNotifier(),
);

final currentDurationProvider =
    StateNotifierProvider<CurrentDurationNotifier, CurrentDurationState>(
  (ref) => CurrentDurationNotifier(),
);

final currentFileProvider = StateNotifierProvider<CurrentFileNotifier, CurrentFileState>((ref) => CurrentFileNotifier());

final metadataProvider = FutureProvider<Metadata>((ref) async {
  final file = ref.watch(currentFileProvider);
  final metadata = await MetadataRetriever.fromFile(file.value ?? File(''));
  return metadata;
});

final filesProvider = FutureProvider<List<File>>((ref) async {
  // get the directory for picking
  List<String> storageInfo =
  await ExternalPath.getExternalStorageDirectories();
  Directory dir = Directory('${storageInfo[0]}/Download');
  // get the musics from selected directory
  var files = dir
      .listSync(recursive: false)
      .whereType<File>()
      .where((e) => e.path.endsWith('.mp3'))
      .toList();

  return files;
});

final playlistProvider =
StateNotifierProvider<PlaylistNotifier, PlaylistState>(
      (ref) => PlaylistNotifier(ref:ref),
);

final playbackModeProvider = StateNotifierProvider<PlaybackModeNotifier, PlaybackModeState>((ref) => PlaybackModeNotifier());

final shuffleModeProvider = StateNotifierProvider<ShuffleModeNotifier, ShuffleModeState>((ref) => ShuffleModeNotifier());

final originalPlaylistProvider = StateNotifierProvider<OriginalPlaylistNotifier, OriginalPlaylistState>( (ref) => OriginalPlaylistNotifier());