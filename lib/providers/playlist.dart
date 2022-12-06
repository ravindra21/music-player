import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/providers/files.dart';

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
  PlaylistNotifier({required this.ref}) : super(PlaylistState());

  final StateNotifierProviderRef ref;

  Future<void> set(List<File>? playlist) async {
    if (playlist == null) {
      AsyncValue<List<File>> files = await ref.watch(filesProvider);
      files.when(
        data: (value) {
          state = state.copyWith(value);
        },
        loading: () {},
        error: (err, stack) {
          if (kDebugMode) {
            print('err $err');
          }
        },
      );
    } else {
      state = state.copyWith(playlist);
    }
  }
}

final playlistProvider = StateNotifierProvider<PlaylistNotifier, PlaylistState>(
  (ref) => PlaylistNotifier(ref: ref),
);
