import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filesProvider = FutureProvider<List<File>>((ref) async {
  // get the directory for picking
  List<String> storageInfo = await ExternalPath.getExternalStorageDirectories();

  List<String> rootDirs = ['Download', 'Music', 'UCDownloads'];

  List<File> files = [];

  for (String rootDir in rootDirs) {
    Directory dir = Directory('${storageInfo[0]}/$rootDir');

    // get the musics from selected directory
    List<File> dirFile = dir
        .listSync(recursive: false)
        .whereType<File>()
        .where((e) => e.path.endsWith('.mp3'))
        .toList();

    files.addAll(dirFile);
  }

  return files;
});
