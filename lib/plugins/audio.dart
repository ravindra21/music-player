import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/providers/current_duration.dart';
import 'package:fluttertestdrive/providers/current_file.dart';
import 'package:fluttertestdrive/providers/now_playing_index.dart';
import 'package:fluttertestdrive/providers/original_playlist.dart';
import 'package:fluttertestdrive/providers/playback_mode.dart';
import 'package:fluttertestdrive/providers/player_status.dart';
import 'package:fluttertestdrive/providers/playlist.dart';
import 'package:fluttertestdrive/providers/shuffle_mode.dart';

abstract class MyAudioPlayer {
  Future<void> setSourceDeviceFile(String path);
  Future<void> play(File file);
  Future<void> stop();
  void resume();
  void pause();
  void seek(Duration position);
  // void prev({playlist, index, mode}){}
  void replayAudio({required WidgetRef ref});
  Stream<Duration> get onPositionChanged;
  Stream<PlayerState> get onPlayerStateChanged;

  Future<void> playNew({
    required WidgetRef ref,
    required File file,
    required int index,
  });
  void resumeOrPause({required WidgetRef ref});
  void next({required WidgetRef ref});
  void prev({required WidgetRef ref});
  void nextRepeat({required WidgetRef ref});
  void nextNoRepeat({required WidgetRef ref});
  void shuffle({required WidgetRef ref});
  void shuffleOff({required WidgetRef ref});
  void changePlaybackMode({required WidgetRef ref});
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

  @override
  Stream<Duration> get onPositionChanged {
    return player.onPositionChanged;
  }

  @override
  Stream<PlayerState> get onPlayerStateChanged {
    return player.onPlayerStateChanged;
  }

  @override
  void resumeOrPause({required WidgetRef ref}) {
    final currentFile = ref.watch(currentFileProvider);
    final currentFileNotifier = ref.watch(currentFileProvider.notifier);
    final playerStatus = ref.watch(playerStatusProvider);
    final playerStatusNotifier = ref.watch(playerStatusProvider.notifier);

    if (playerStatus.value == PlayerState.playing) {
      pause();
      playerStatusNotifier.changeStatus(PlayerState.paused);
      return;
    } else if (playerStatus.value == PlayerState.completed) {
      play(currentFile.value ?? File(''));
      currentFileNotifier.changeFile(currentFile.value ?? File(''));
      playerStatusNotifier.changeStatus(PlayerState.playing);
      return;
    } else {
      resume();
      playerStatusNotifier.changeStatus(PlayerState.playing);
    }
  }

  @override
  void replayAudio({required WidgetRef ref}) {
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);
    final currentFile = ref.watch(currentFileProvider);

    currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
    play(currentFile.value ?? File(''));
  }

  @override
  Future<void> playNew({
    required WidgetRef ref,
    required File file,
    required int index,
  }) async {
    final currentFileNotifier = ref.watch(currentFileProvider.notifier);
    final nowPlayingIndexNotifier = ref.watch(nowPlayingIndexProvider.notifier);
    final playerStatusNotifier = ref.watch(playerStatusProvider.notifier);
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);
    final playlistNotifier = ref.watch(playlistProvider.notifier);
    final shuffleMode = ref.watch(shuffleModeProvider);

    await play(file);

    playerStatusNotifier.changeStatus(PlayerState.playing);
    currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
    currentFileNotifier.changeFile(file);
    if (shuffleMode.value == ShuffleMode.off) {
      playlistNotifier.set(null);
      nowPlayingIndexNotifier.changeIndex(index);
    } else {
      await playlistNotifier.set(null);
      shuffle(ref: ref);
      final playlist = ref.watch(playlistProvider);
      int? index = playlist.value?.indexWhere((el) => el.path == file.path);
      nowPlayingIndexNotifier.changeIndex(index ?? 0);
    }
  }

  @override
  void next({required WidgetRef ref}) {
    final currentIndex = ref.watch(nowPlayingIndexProvider);
    final currentIndexNotifier = ref.watch(nowPlayingIndexProvider.notifier);
    final playlist = ref.watch(playlistProvider);
    final currentFileNotifier = ref.watch(currentFileProvider.notifier);
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);
    final playerStatus = ref.watch(playerStatusProvider);

    int newIndex = currentIndex.value + 1;

    if (currentIndex.value == (playlist.value?.length ?? 0) - 1) {
      newIndex = 0;
    }

    currentIndexNotifier.changeIndex(newIndex);
    currentFileNotifier.changeFile(playlist.value?[newIndex] ?? File(''));
    currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));

    if (playerStatus.value == PlayerState.playing) {
      play(playlist.value?[newIndex] ?? File(''));
    } else {
      setSourceDeviceFile(playlist.value?[newIndex].path ?? '');
    }
  }

  @override
  void prev({required WidgetRef ref}) {
    final currentIndex = ref.watch(nowPlayingIndexProvider);
    final currentIndexNotifier = ref.watch(nowPlayingIndexProvider.notifier);
    final currentFileNotifier = ref.watch(currentFileProvider.notifier);
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);
    final playlist = ref.watch(playlistProvider);
    final playerStatus = ref.watch(playerStatusProvider);

    int newIndex = currentIndex.value - 1;

    if (currentIndex.value == 0) {
      newIndex = (playlist.value?.length ?? 0) - 1;
    }

    currentIndexNotifier.changeIndex(newIndex);
    currentFileNotifier.changeFile(playlist.value?[newIndex] ?? File(''));
    currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
    if (playerStatus.value == PlayerState.playing) {
      play(playlist.value?[newIndex] ?? File(''));
    } else {
      setSourceDeviceFile(playlist.value?[newIndex].path ?? '');
    }
  }

  @override
  void nextRepeat({required WidgetRef ref}) {
    final currentFileNotifier = ref.watch(currentFileProvider.notifier);
    final currentIndex = ref.watch(nowPlayingIndexProvider);
    final currentIndexNotifier = ref.watch(nowPlayingIndexProvider.notifier);
    final playlist = ref.watch(playlistProvider);
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);

    int newIndex = currentIndex.value + 1;

    if (currentIndex.value == (playlist.value?.length ?? 0) - 1) {
      newIndex = 0;
    }

    play(playlist.value?[newIndex] ?? File(''));

    currentIndexNotifier.changeIndex(newIndex);
    currentFileNotifier.changeFile(playlist.value?[newIndex] ?? File(''));
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

    if (currentIndex.value == (playlist.value?.length ?? 0) - 1) {
      stop();
      playerStatusNotifier.changeStatus(PlayerState.completed);
      return;
    }

    play(playlist.value?[newIndex] ?? File(''));

    currentIndexNotifier.changeIndex(newIndex);
    currentFileNotifier.changeFile(playlist.value?[newIndex] ?? File(''));
    currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
  }

  @override
  void shuffle({required WidgetRef ref}) {
    final shuffleModeNotifier = ref.watch(shuffleModeProvider.notifier);
    final playlistNotifier = ref.watch(playlistProvider.notifier);
    final playlist = ref.watch(playlistProvider);
    final originalPlaylistNotifier =
        ref.watch(originalPlaylistProvider.notifier);

    shuffleModeNotifier.changeMode(ShuffleMode.on);
    originalPlaylistNotifier.set(playlist.value ?? []);
    List<File>? n = playlist.value?.toList();
    n?.shuffle();
    playlistNotifier.set(n);
  }

  @override
  void shuffleOff({required WidgetRef ref}) {
    final originalPlaylist = ref.watch(originalPlaylistProvider);
    final shuffleModeNotifier = ref.watch(shuffleModeProvider.notifier);
    final playlistNotifier = ref.watch(playlistProvider.notifier);
    final nowPlayingIndexNotifier = ref.watch(nowPlayingIndexProvider.notifier);
    final currentFile = ref.watch(currentFileProvider);

    shuffleModeNotifier.changeMode(ShuffleMode.off);
    int newIndex = originalPlaylist.value
        .indexWhere((el) => el?.path == currentFile.value?.path);
    playlistNotifier.set(originalPlaylist.value.cast());
    nowPlayingIndexNotifier.changeIndex(newIndex);
  }

  @override
  void changePlaybackMode({required WidgetRef ref}) {
    final playbackMode = ref.watch(playbackModeProvider);
    final playbackModeNotifier = ref.watch(playbackModeProvider.notifier);

    if (playbackMode.value == PlaybackMode.repeatCurrent) {
      playbackModeNotifier.changeMode(PlaybackMode.noRepeat);
      return;
    } else if (playbackMode.value == PlaybackMode.repeat) {
      playbackModeNotifier.changeMode(PlaybackMode.repeatCurrent);
      return;
    }

    playbackModeNotifier.changeMode(PlaybackMode.repeat);
    return;
  }
}
