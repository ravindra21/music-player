import 'dart:ffi';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/providers/appProvider.dart';

abstract class MyAudioPlayer {
  Future<void> setSourceDeviceFile(String path);
  Future<void> play(File file);
  Future<void> stop();
  void resume();
  void pause();
  void seek(Duration position);
  // void next({playlist, index, mode}){}
  // void prev({playlist, index, mode}){}
  void replayAudio({
    required WidgetRef ref,
    required StateNotifierProvider currentFileProvider
  });
  Stream<Duration> get onPositionChanged;
  Stream<PlayerState> get onPlayerStateChanged;
  Future<void> playNew({
    required File file,
    required CurrentFileNotifier currentFileNotifier,
    required int index,
    required NowPlayingIndexNotifier nowPlayingIndexNotifier,
    required PlayerStatusNotifier playerStatusNotifier,
    required CurrentDurationNotifier currentDurationNotifier,
    required PlaylistNotifier playlistNotifier,
  });

  void resumeOrPause({
    required File file,
    required CurrentFileState currentFile,
    required CurrentFileNotifier currentFileNotifier,
    required PlayerStatusState playerStatus,
    required PlayerStatusNotifier playerStatusNotifier,
  });
  void nextRepeat({required WidgetRef ref});
  void nextNoRepeat({required WidgetRef ref});
}

class MyAudioPlayerImpl extends MyAudioPlayer {
  final player = AudioPlayer();

  @override
  Future<void> setSourceDeviceFile(String path) async {
    player.setSourceDeviceFile(path);
  }

  @override
  Future<void> play(File file) async {
    player.play(DeviceFileSource(file.path));
  }

  @override
  Future<void> stop() async {
    player.stop();
  }

  @override
  void resume() {
    player.resume();
  }

  @override
  void pause() {
    player.pause();
  }

  @override
  void seek(Duration position) {
    player.seek(position);
  }

  // @override
  // void next(playlist, index, ) {
  //   super.next();
  // }
  //
  // @override
  // void prev() {
  //   super.prev();
  // }

  @override
  Stream<Duration> get onPositionChanged {
    return player.onPositionChanged;
  }

  @override
  Stream<PlayerState> get onPlayerStateChanged {
    return player.onPlayerStateChanged;
  }

  @override
  void resumeOrPause({
    required File file,
    required CurrentFileState currentFile,
    required CurrentFileNotifier currentFileNotifier,
    required PlayerStatusState playerStatus,
    required PlayerStatusNotifier playerStatusNotifier,
  }) {
    print('========================');
    print(playerStatus.value.name);
    print('=========================');
    if (playerStatus.value == PlayerState.playing) {
      pause();
      playerStatusNotifier.changeStatus(PlayerState.paused);
      return;
    } else if(playerStatus.value == PlayerState.completed) {
      play(currentFile.value??File(''));
      currentFileNotifier.changeFile(currentFile.value?? File(''));
      playerStatusNotifier.changeStatus(PlayerState.playing);
      return;
    } else {
      resume();
      playerStatusNotifier.changeStatus(PlayerState.playing);
    }
  }

  @override
  void replayAudio({
    required WidgetRef ref,
    required StateNotifierProvider currentFileProvider
  }) {
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);

    currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
    play(ref.watch(currentFileProvider).value);
  }

  @override
  Future<void> playNew({
    required File file,
    required int index,
    required CurrentFileNotifier currentFileNotifier,
    required NowPlayingIndexNotifier nowPlayingIndexNotifier,
    required PlayerStatusNotifier playerStatusNotifier,
    required CurrentDurationNotifier currentDurationNotifier,
    required PlaylistNotifier playlistNotifier,
  }) async {
    await play(file);

    nowPlayingIndexNotifier.changeIndex(index);
    playerStatusNotifier.changeStatus(PlayerState.playing);
    currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
    currentFileNotifier.changeFile(file);
    playlistNotifier.set(null);
  }

  @override
  void nextRepeat({required WidgetRef ref}) {
    final currentFileNotifier = ref.watch(currentFileProvider.notifier);
    final currentIndex = ref.watch(nowPlayingIndexProvider);
    final currentIndexNotifier = ref.watch(nowPlayingIndexProvider.notifier);
    final playlist = ref.watch(playlistProvider);
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);

    int newIndex = currentIndex.value + 1;

    if(currentIndex.value == (playlist.value?.length??0)-1) {
      newIndex = 0;
    }

    play(playlist.value?[newIndex]?? File(''));

    currentIndexNotifier.changeIndex(newIndex);
    currentFileNotifier.changeFile(playlist.value?[newIndex]?? File(''));
    currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
  }

  @override
  void nextNoRepeat({required WidgetRef ref}) {
    final playerStatusNotifier = ref.watch(playerStatusProvider.notifier);
    final currentFileNotifier = ref.watch(currentFileProvider.notifier);
    final currentIndex = ref.read(nowPlayingIndexProvider);
    final currentIndexNotifier = ref.watch(nowPlayingIndexProvider.notifier);
    final playlist = ref.watch(playlistProvider);
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);

    int newIndex = currentIndex.value + 1;

    if(currentIndex.value == (playlist.value?.length??0)-1) {
      stop();
      playerStatusNotifier.changeStatus(PlayerState.completed);
      return;
    }

    play(playlist.value?[newIndex]?? File(''));

    currentIndexNotifier.changeIndex(newIndex);
    currentFileNotifier.changeFile(playlist.value?[newIndex]?? File(''));
    currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
  }
}