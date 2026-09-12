import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final footprintExportProvider =
    Provider<FootprintExport>((ref) => FootprintExport());

class FootprintExport {
  Future<bool> save(Uint8List bytes, bool Function() stillOwner) async {
    final allowed = await Gal.requestAccess();
    if (!allowed) throw StateError('Photo access denied');
    if (!stillOwner()) return false;
    await Gal.putImageBytes(bytes, name: 'bookstar-reading-notes');
    return true;
  }

  Future<void> share(
      Uint8List bytes, Rect origin, bool Function() stillOwner) async {
    final cache = await getTemporaryDirectory();
    final directory =
        await Directory('${cache.path}/bookstar-footprint-exports')
            .create(recursive: true);
    // Only this feature's expired PNGs are eligible for cleanup; never the whole app cache.
    await for (final entry in directory.list(followLinks: false)) {
      if (entry is File &&
          entry.path.endsWith('.png') &&
          DateTime.now().difference((await entry.stat()).modified).inDays >=
              1) {
        await entry.delete();
      }
    }
    if (!stillOwner()) return;
    final file = File(
        '${directory.path}/record-${DateTime.now().microsecondsSinceEpoch}.png');
    try {
      await file.writeAsBytes(bytes, flush: true);
      if (!stillOwner()) return;
      await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')],
          sharePositionOrigin: origin);
    } finally {
      if (await file.exists()) await file.delete();
    }
  }
}
