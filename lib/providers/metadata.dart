import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final FutureProviderFamily<Metadata, File> metadataProvider =
    FutureProvider.family<Metadata, File>((
  ref,
  file,
) async {
  final metadata = await MetadataRetriever.fromFile(file);

  return metadata;
});
