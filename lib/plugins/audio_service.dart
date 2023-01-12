import 'package:audio_service/audio_service.dart';
import 'package:fluttertestdrive/plugins/audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioPlayer(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycom.myapp.channel.audio',
      androidNotificationChannelName: 'Music',
      androidNotificationOngoing: true,
    ),
  );
}
