import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filesProvider = FutureProvider<List<File>>((ref) async {
  // get the directory for picking
  List<String> storageInfo = await ExternalPath.getExternalStorageDirectories();
  Directory dir = Directory('${storageInfo[0]}/Download');
  // get the musics from selected directory
  var files = dir
      .listSync(recursive: false)
      .whereType<File>()
      .where((e) => e.path.endsWith('.mp3'))
      .toList();

  return files;
});
