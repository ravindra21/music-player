import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final originalPlaylistProvider =
    StateNotifierProvider<OriginalPlaylistNotifier, OriginalPlaylistState>(
        (ref) => OriginalPlaylistNotifier());
