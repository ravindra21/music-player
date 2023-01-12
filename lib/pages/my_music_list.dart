import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/pages/my_player.dart';
import 'package:fluttertestdrive/plugins/service_locator.dart';
import 'package:fluttertestdrive/providers/audio.dart';
import 'package:fluttertestdrive/providers/current_file.dart';
import 'package:fluttertestdrive/providers/files.dart';
import 'package:fluttertestdrive/providers/is_playing.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class MyMusicList extends ConsumerWidget {
  const MyMusicList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your music List'),
      ),
      body: const SafeArea(
        child: MyList(),
      ),
    );
  }
}

class MyList extends ConsumerWidget {
  const MyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<File>> files = ref.watch(filesProvider);

    return files.when(
      data: (files) => ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: files.length,
        itemBuilder: (context, index) {
          return MyMusicListItem(
            files: files,
            index: index,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),
      error: (err, stack) => const Text(''),
      loading: () => const CircularProgressIndicator(),
    );
  }
}

class MyMusicListItem extends ConsumerWidget {
  const MyMusicListItem({
    Key? key,
    required this.files,
    required this.index,
  }) : super(key: key);

  final List<File> files;
  final int index;

  onTapListItem(context, ref) async {
    final AudioNotifier audioNotifier = ref.watch(audioProvider.notifier);
    audioNotifier.setCurrentFile(files[index]);
    audioNotifier.setIndex(index);
    audioNotifier.setIsPlaying(true);
    audioNotifier.setMetadata(await MetadataRetriever.fromFile(files[index]));

    var playlist = files.map((file) {
      return AudioSource.uri(
        Uri.file(file.path),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: file.path,
          // Metadata to display in the notification:
          album: "Album name",
          title: "Song name",
        ),
      );
    }).toList();

    audioNotifier.setPlaylist(playlist);

    final duration = await getIt<AudioPlayer>().setAudioSource(
        ConcatenatingAudioSource(children: playlist),
        initialIndex: index);
    audioNotifier.setDuration(duration ?? Duration.zero);
    getIt<AudioPlayer>().play();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioProvider);
    final isPlaying = audio.isPlaying;
    final isCurrentItem = audio.currentFile?.path == files[index].path;

    return Card(
      color: isCurrentItem ? Colors.blueGrey : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        leading: const Icon(Icons.audiotrack),
        title: Text(files[index].path.split('/').last),
        trailing: (() {
          if (isCurrentItem) {
            return isPlaying
                ? const Icon(Icons.pause_circle)
                : const Icon(Icons.play_arrow);
          }
        }()),
        onTap: () {
          if (!isCurrentItem) {
            onTapListItem(context, ref);
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const MyPlayer();
              },
            ),
          );
        },
      ),
    );
  }
}
