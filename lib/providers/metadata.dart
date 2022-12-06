import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertestdrive/providers/current_file.dart';

final metadataProvider = FutureProvider<Metadata>((ref) async {
  final file = ref.watch(currentFileProvider);
  final metadata = await MetadataRetriever.fromFile(file.value ?? File(''));

  return metadata;
});
