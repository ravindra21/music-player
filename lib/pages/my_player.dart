import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/plugins/service_locator.dart';
import 'package:fluttertestdrive/providers/audio.dart';
import 'package:just_audio/just_audio.dart';

class MyPlayer extends StatelessWidget {
  const MyPlayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.chevron_left),
        ),
        title: const Text('Music Player App'),
      ),
      body: const MyPlayerUi(),
    );
  }
}

class MyPlayerUi extends ConsumerWidget {
  const MyPlayerUi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AudioState audio = ref.watch(audioProvider);
    final Metadata? metadata = audio.metadata;

    return SafeArea(
      child: Stack(
        children: [
          metadata?.albumArt == null
              ? const Placeholder()
              : Image.memory(metadata!.albumArt!),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: metadata?.albumArt == null
                      ? const Placeholder()
                      : Image.memory(metadata!.albumArt!),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  children: [
                    Text(metadata?.filePath?.split('/').last ?? ''),
                    const SizedBox(height: 12),
                    Text(metadata?.trackArtistNames?[0] ?? ''),
                    const SizedBox(height: 20),
                    const MyAudioPosition(),
                    const SizedBox(height: 20),
                    const MyAudioControl(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyAudioControl extends ConsumerWidget {
  const MyAudioControl({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AudioState audio = ref.watch(audioProvider);
    final AudioNotifier audioNotifier = ref.watch(audioProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: () {
            if (!audio.shuffleModeEnabled) {
              getIt<AudioPlayer>().shuffle();
              getIt<AudioPlayer>().setShuffleModeEnabled(true);
              audioNotifier.setShuffleModeEnabled(true);
              return;
            }

            getIt<AudioPlayer>().setShuffleModeEnabled(false);
            audioNotifier.setShuffleModeEnabled(false);
          },
          icon: audio.shuffleModeEnabled
              ? const Icon(Icons.shuffle)
              : const Icon(Icons.shuffle, color: Colors.grey),
          iconSize: 20,
        ),
        IconButton(
          onPressed: () {
            getIt<AudioPlayer>().seekToPrevious();
          },
          icon: const Icon(Icons.fast_rewind),
          iconSize: 40,
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            if (audio.isPlaying) {
              getIt<AudioPlayer>().pause();
              audioNotifier.setIsPlaying(false);
              return;
            }

            getIt<AudioPlayer>().play();
            audioNotifier.setIsPlaying(true);
          },
          icon: (() {
            return audio.isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_circle_filled);
          }()),
          iconSize: 40,
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            getIt<AudioPlayer>().seekToNext();
          },
          icon: const Icon(Icons.fast_forward),
          iconSize: 40,
        ),
        IconButton(
          onPressed: () {
            if (audio.loopMode == LoopMode.off) {
              getIt<AudioPlayer>().setLoopMode(LoopMode.all);
              audioNotifier.setLoopMode(LoopMode.all);
              return;
            } else if (audio.loopMode == LoopMode.all) {
              getIt<AudioPlayer>().setLoopMode(LoopMode.one);
              audioNotifier.setLoopMode(LoopMode.one);
              return;
            }

            getIt<AudioPlayer>().setLoopMode(LoopMode.off);
            audioNotifier.setLoopMode(LoopMode.off);
          },
          icon: (() {
            if (audio.loopMode == LoopMode.off) {
              return const Icon(Icons.repeat, color: Colors.grey);
            } else if (audio.loopMode == LoopMode.all) {
              return const Icon(Icons.repeat);
            }

            return const Icon(Icons.repeat_one);
          }()),
          iconSize: 20,
        ),
      ],
    );
  }
}

class MyAudioPosition extends ConsumerStatefulWidget {
  const MyAudioPosition({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MyAudioPosition> createState() => _MyAudioPositionState();
}

class _MyAudioPositionState extends ConsumerState<MyAudioPosition> {
  late StreamSubscription<Duration> _positionController;
  late StreamSubscription<int?> _indexController;
  late StreamSubscription<Duration?> _durationController;

  @override
  void initState() {
    if (mounted) {
      final AudioNotifier audioNotifier = ref.read(audioProvider.notifier);
      final AudioState audio = ref.read(audioProvider);

      _positionController =
          getIt<AudioPlayer>().positionStream.listen((Duration position) async {
        audioNotifier.setPosition(position);
      });

      // final indexStream = ref.watch(indexStreamProvider);
      // indexStream.whenData((value) => print('=================$value'));

      _indexController =
          getIt<AudioPlayer>().currentIndexStream.listen((index) async {
        if (index != audio.index) {
          var file = File.fromUri(
            audio.playlist[getIt<AudioPlayer>().currentIndex!].uri,
          );

          audioNotifier.setCurrentFile(file);
          audioNotifier.setIndex(index!);
          audioNotifier.setMetadata(await MetadataRetriever.fromFile(file));
        }
      });

      _durationController =
          getIt<AudioPlayer>().durationStream.listen((duration) async {
        if (duration != audio.duration) {
          audioNotifier.setDuration(duration!);
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AudioState audio = ref.watch(audioProvider);
    final AudioNotifier audioNotifier = ref.watch(audioProvider.notifier);

    return Row(
      children: [
        Text("${audio.position.inMinutes}:${audio.position.inSeconds % 60}"),
        Expanded(
          child: Slider.adaptive(
            value: audio.position.inSeconds.toDouble(),
            min: 0,
            max: audio.duration.inSeconds.toDouble(),
            onChangeEnd: (newValue) {
              getIt<AudioPlayer>().seek(Duration(seconds: newValue.toInt()));
              _positionController.resume();
            },
            onChangeStart: (value) {
              _positionController.pause();
            },
            onChanged: (newValue) {
              audioNotifier.setPosition(Duration(seconds: newValue.toInt()));
            },
          ),
        ),
        Text("${audio.duration.inMinutes}:${audio.duration.inSeconds % 60}"),
      ],
    );
  }

  @override
  void dispose() {
    _positionController.cancel();
    _indexController.cancel();
    _durationController.cancel();
    super.dispose();
  }
}
