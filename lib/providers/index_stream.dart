import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/plugins/service_locator.dart';
import 'package:just_audio/just_audio.dart';

final indexStreamProvider = StreamProvider<int?>((ref) {
  return getIt<AudioPlayer>().currentIndexStream;
});
