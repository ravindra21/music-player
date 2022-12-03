import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/plugins/audio.dart';
import 'package:fluttertestdrive/providers/appProvider.dart';

class MyPlayer extends StatelessWidget {
  final List<File> data;
  final int index;
  final MyAudioPlayer player;

  const MyPlayer({
    Key? key,
    required this.data,
    required this.index,
    required this.player,
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
      body: MyPlayerUi(
        key: Key(index.toString()),
        player: player,
        source: data[index],
      ),
    );
  }
}

class MyPlayerUi extends ConsumerWidget {
  const MyPlayerUi({
    Key? key,
    required this.player,
    required this.source,
  }) : super(key: key);

  final MyAudioPlayer player;
  final File source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<Metadata> metadata = ref.watch(metadataProvider);

    return metadata.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: ()=> Text('loading'),
      error: (err, stack) => const Text('error'),
      data: (metadata) => SafeArea(
        child: Stack(
          children: [
            metadata.albumArt == null
                ? const Placeholder()
                : Image.memory(metadata.albumArt!),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: metadata.albumArt == null
                        ? const Placeholder()
                        : Image.memory(metadata.albumArt!),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Column(
                    children: [
                      Text(metadata.filePath?.split('/').last ?? ''),
                      const SizedBox(height: 12),
                      Text(metadata.trackArtistNames?[0] ?? ''),
                      const SizedBox(height: 20),
                      MyAudioPosition(
                        player: player,
                        duration:
                            Duration(milliseconds: metadata.trackDuration!),
                      ),
                      const SizedBox(height: 20),
                      MyAudioControl(
                        key: key,
                        player: player,
                        source: source,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyAudioControl extends ConsumerWidget {
  const MyAudioControl({
    Key? key,
    required this.player,
    required this.source,
  }) : super(key: key);

  final MyAudioPlayer player;
  final File source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStatus = ref.watch(playerStatusProvider);
    final playerStatusNotifier = ref.watch(playerStatusProvider.notifier);
    final currentFile = ref.watch(currentFileProvider);
    final currentFileNotifier = ref.watch(currentFileProvider.notifier);
    final currentIndex = ref.watch(nowPlayingIndexProvider);
    final currentIndexNotifier = ref.watch(nowPlayingIndexProvider.notifier);
    final playlist = ref.watch(playlistProvider);
    final currentDuration = ref.watch(currentDurationProvider);
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: () {
            int newIndex = currentIndex.value - 1;

            if(currentIndex.value == 0) {
              newIndex = (playlist.value?.length??0) - 1;
            }

            currentIndexNotifier.changeIndex(newIndex);
            currentFileNotifier.changeFile(playlist.value?[newIndex]?? File(''));
            currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
            if(playerStatus.value == PlayerState.playing) {
              player.play(playlist.value?[newIndex]?? File(''));
            } else {
              player.setSourceDeviceFile(playlist.value?[newIndex].path ?? '');
            }
          },
          icon: const Icon(Icons.fast_rewind),
          iconSize: 40,
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            player.resumeOrPause(
              file: source,
              currentFile: currentFile,
              currentFileNotifier: currentFileNotifier,
              playerStatus: playerStatus,
              playerStatusNotifier: playerStatusNotifier,
            );
          },
          icon: playerStatus.value == PlayerState.playing
              ? const Icon(Icons.pause_circle_filled)
              : const Icon(Icons.play_circle_filled),
          iconSize: 40,
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            int newIndex = currentIndex.value + 1;

            if(currentIndex.value == (playlist.value?.length??0)-1) {
              newIndex = 0;
            }

            currentIndexNotifier.changeIndex(newIndex);
            currentFileNotifier.changeFile(playlist.value?[newIndex]?? File(''));
            currentDurationNotifier.changeCurrentDuration(const Duration(seconds: 0));
            if(playerStatus.value == PlayerState.playing) {
              player.play(playlist.value?[newIndex]?? File(''));
            } else {
              player.setSourceDeviceFile(playlist.value?[newIndex].path ?? '');
            }
          },
          icon: const Icon(Icons.fast_forward),
          iconSize: 40,
        ),
      ],
    );
  }
}

class MyAudioPosition extends ConsumerStatefulWidget {
  const MyAudioPosition({
    Key? key,
    required this.player,
    required this.duration,
  }) : super(key: key);

  final MyAudioPlayer player;
  final Duration duration;

  @override
  ConsumerState<MyAudioPosition> createState() => _MyAudioPositionState();
}

class _MyAudioPositionState extends ConsumerState<MyAudioPosition> {
  late StreamSubscription<Duration> _currentDurationController;

  StreamSubscription<Duration> subscribePlayerCurrentDuration(
    MyAudioPlayer player,
    WidgetRef ref,
  ) {
    return player.onPositionChanged.listen(
      (Duration duration) {
        ref
            .watch(currentDurationProvider.notifier)
            .changeCurrentDuration(duration);
      },
    );
  }

  @override
  void initState() {
    if (mounted) {
      _currentDurationController =
          subscribePlayerCurrentDuration(widget.player, ref);

      widget.player.onPlayerStateChanged.listen((PlayerState s) {
        if (s == PlayerState.completed) {
          ref
              .watch(playerStatusProvider.notifier)
              .changeStatus(PlayerState.completed);
        }
      });
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentDuration = ref.watch(currentDurationProvider);
    final currentDurationNotifier = ref.watch(currentDurationProvider.notifier);

    return Row(
      children: [
        Text(
            '${currentDuration.value.inMinutes}:${currentDuration.value.inSeconds % 60}'),
        Expanded(
          child: Slider.adaptive(
              value: currentDuration.value.inSeconds.toDouble(),
              min: 0,
              max: widget.duration.inSeconds.toDouble(),
              onChangeEnd: (newValue) {
                widget.player.seek(Duration(seconds: newValue.toInt()));
                setState(() {
                  _currentDurationController =
                      subscribePlayerCurrentDuration(widget.player, ref);
                });
              },
              onChangeStart: (v) {
                _currentDurationController.cancel();
              },
              onChanged: (newValue) {
                currentDurationNotifier
                    .changeCurrentDuration(Duration(seconds: newValue.toInt()));
              }),
        ),
        Text('${widget.duration.inMinutes}:${widget.duration.inSeconds % 60}'),
      ],
    );
  }

  @override
  void dispose() {
    _currentDurationController.cancel();
    // TODO: implement dispose
    super.dispose();
  }
}