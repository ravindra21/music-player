import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void changeFile(File file) => state = state.copyWith(file);
}

final currentFileProvider =
    StateNotifierProvider<CurrentFileNotifier, CurrentFileState>(
        (ref) => CurrentFileNotifier());
