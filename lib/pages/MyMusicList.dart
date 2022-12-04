import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/pages/MyPlayer.dart';
import 'package:fluttertestdrive/plugins/audio.dart';
import 'package:fluttertestdrive/providers/appProvider.dart';

class MyMusicList extends ConsumerWidget {
  const MyMusicList({
    Key? key,
    required this.player,
  }) : super(key: key);

  final MyAudioPlayer player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your music List'),
      ),
      body: SafeArea(
        child: MyList(
          player: player,
        ),
      ),
    );
  }
}

class MyList extends ConsumerWidget {
  final MyAudioPlayer player;

  const MyList({
    required this.player,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStatus = ref.watch(playerStatusProvider);
    final playerStatusNotifier = ref.watch(playerStatusProvider.notifier);
    final nowPlayingIndex = ref.watch(nowPlayingIndexProvider);
    final nowPlayingIndexNotifier = ref.watch(nowPlayingIndexProvider.notifier);
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);
    final currentFileNotifier = ref.watch(currentFileProvider.notifier);
    AsyncValue<List<File>> files = ref.watch(filesProvider);
    final playlistNotifier = ref.watch(playlistProvider.notifier);

    return files.when(
        data: (files) => ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: files.length,
          itemBuilder: (context, index) {
            return Card(
              color:
              nowPlayingIndex.value == index ? Colors.blueGrey : Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                leading: const Icon(Icons.audiotrack),
                title: Text(files[index].path.split('/').last),
                trailing: playerStatus.value == PlayerState.playing &&
                    nowPlayingIndex.value == index
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                onTap: () {
                  if (nowPlayingIndex.value != index) {
                    player.playNew(
                      file: files[index],
                      index: index,
                      currentFileNotifier: currentFileNotifier,
                      nowPlayingIndexNotifier: nowPlayingIndexNotifier,
                      playerStatusNotifier: playerStatusNotifier,
                      currentDurationNotifier: currentDurationNotifier,
                      playlistNotifier: playlistNotifier,
                    );
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return MyPlayer(
                        data: files,
                        index: index,
                        player: player,
                      );
                      },
                    ),
                  );
                },
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
        error: (err, stack) => const Text(''),
        loading: () => const CircularProgressIndicator());
  }
}
