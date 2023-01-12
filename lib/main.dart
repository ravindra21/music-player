import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/plugins/service_locator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/my_music_list.dart';

Future<void> injectService() async {
  getIt.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  getIt.registerSingleton<AudioPlayer>(AudioPlayer());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await injectService();

  if (await Permission.storage.request().isGranted) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    );

    runApp(
      const ProviderScope(child: MyApp()),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyMusicList(),
    );
  }
}
