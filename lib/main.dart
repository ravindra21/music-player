import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/plugins/audio.dart';
import 'package:fluttertestdrive/plugins/service_locator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/my_music_list.dart';

Future<void> injectService() async {
  getIt.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await injectService();
  if (await Permission.storage.request().isGranted) {
    runApp(
      const ProviderScope(child: MyApp()),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _player = MyAudioPlayerImpl();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: MyMusicList(
        player: _player,
      ),
    );
  }
}
