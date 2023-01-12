import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioPlayer extends BaseAudioHandler {
  final _player = AudioPlayer();

  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    await _player.setAudioSource(source,
        preload: preload,
        initialIndex: initialIndex,
        initialPosition: initialPosition);
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    await _player.seek(position, index: index);
  }
}
