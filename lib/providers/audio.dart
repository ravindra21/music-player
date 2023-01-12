import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioState {
  AudioState({
    this.duration = const Duration(seconds: 0),
    this.position = const Duration(seconds: 0),
    this.index = 1,
    this.shuffleModeEnabled = false,
    this.playlist = const [],
    this.currentFile,
    this.metadata,
    this.isPlaying = false,
    this.loopMode = LoopMode.off,
  });

  final Duration duration;
  final Duration position;
  final int index;
  final bool shuffleModeEnabled;
  final List<UriAudioSource> playlist;
  final File? currentFile;
  final Metadata? metadata;
  final bool isPlaying;
  final LoopMode loopMode;

  AudioState copyWith({
    Duration? duration,
    Duration? position,
    int? index,
    bool? shuffleModeEnabled,
    List<UriAudioSource>? playlist,
    File? currentFile,
    Metadata? metadata,
    bool? isPlaying,
    LoopMode? loopMode,
  }) {
    return AudioState(
      duration: duration ?? this.duration,
      position: position ?? this.position,
      index: index ?? this.index,
      shuffleModeEnabled: shuffleModeEnabled ?? this.shuffleModeEnabled,
      playlist: playlist ?? this.playlist,
      currentFile: currentFile ?? this.currentFile,
      metadata: metadata ?? this.metadata,
      isPlaying: isPlaying ?? this.isPlaying,
      loopMode: loopMode ?? this.loopMode,
    );
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  AudioNotifier() : super(AudioState());

  void setPlaylist(List<UriAudioSource> playlist) =>
      state = state.copyWith(playlist: playlist);

  void setCurrentFile(File file) => state = state.copyWith(currentFile: file);

  void setIndex(int index) => state = state.copyWith(index: index);

  void setIsPlaying(bool isPlaying) =>
      state = state.copyWith(isPlaying: isPlaying);

  void setShuffleModeEnabled(bool shuffleModeEnabled) =>
      state = state.copyWith(shuffleModeEnabled: shuffleModeEnabled);

  void setMetadata(Metadata metadata) =>
      state = state.copyWith(metadata: metadata);

  void setDuration(Duration duration) =>
      state = state.copyWith(duration: duration);

  void setPosition(Duration position) =>
      state = state.copyWith(position: position);

  void setLoopMode(LoopMode loopMode) =>
      state = state.copyWith(loopMode: loopMode);
}

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>(
  (ref) => AudioNotifier(),
);
