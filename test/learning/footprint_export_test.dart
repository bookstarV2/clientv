import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bookstar/modules/learning/data/footprint_export.dart';
import 'package:flutter_test/flutter_test.dart';
// The installed Gal version exposes its replaceable platform boundary here.
// ignore: implementation_imports
import 'package:gal/src/gal_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jJ1sAAAAASUVORK5CYII=');
const _origin = Rect.fromLTWH(16, 120, 220, 48);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory sandbox;
  late _Gallery gallery;
  late _Sharing sharing;
  late _Paths paths;
  late GalPlatform originalGallery;
  late SharePlatform originalShare;
  late PathProviderPlatform originalPaths;
  final service = FootprintExport();

  setUp(() async {
    sandbox = await Directory.systemTemp
        .createTemp('bookstar-footprint-export-test-');
    originalGallery = GalPlatform.instance;
    originalShare = SharePlatform.instance;
    originalPaths = PathProviderPlatform.instance;
    GalPlatform.instance = gallery = _Gallery();
    SharePlatform.instance = sharing = _Sharing();
    PathProviderPlatform.instance = paths = _Paths(sandbox.path);
  });

  tearDown(() async {
    GalPlatform.instance = originalGallery;
    SharePlatform.instance = originalShare;
    PathProviderPlatform.instance = originalPaths;
    await sandbox.delete(recursive: true);
  });

  test('denied photo permission never sends image bytes to the gallery',
      () async {
    gallery.allowed = false;

    await expectLater(
        service.save(_png, () => true), throwsA(isA<StateError>()));

    expect(gallery.permissionCalls, 1);
    expect(gallery.savedBytes, isEmpty);
    expect(sharing.calls, 0);
    expect(paths.calls, 0);
  });

  test('account change while photo permission is pending prevents saving',
      () async {
    gallery.permissionGate = Completer<bool>();
    var stillOwner = true;
    final save = service.save(_png, () => stillOwner);
    await gallery.permissionStarted.future;

    stillOwner = false;
    gallery.permissionGate!.complete(true);

    expect(await save, isFalse);
    expect(gallery.savedBytes, isEmpty);
    expect(paths.calls, 0);
  });

  test('authorized photo save passes exact bytes with an account-free name',
      () async {
    expect(await service.save(_png, () => true), isTrue);

    expect(gallery.savedBytes, hasLength(1));
    expect(gallery.savedBytes.single, orderedEquals(_png));
    expect(gallery.savedName, 'bookstar-reading-notes');
    expect(gallery.savedAlbum, isNull);
    expect(gallery.albumPermissionRequested, isFalse);
    expect(paths.calls, 0);
    expect(sharing.calls, 0);
  });

  test('native gallery failure is reported instead of claiming save success',
      () async {
    gallery.failSave = true;

    await expectLater(
        service.save(_png, () => true), throwsA(isA<StateError>()));

    expect(gallery.saveCalls, 1);
    expect(sharing.calls, 0);
  });

  test(
      'share passes only one PNG and the supplied origin then removes its file',
      () async {
    sharing.gate = Completer<ShareResult>();
    final share = service.share(_png, _origin, () => true);
    await sharing.started.future;

    expect(sharing.files, hasLength(1));
    expect(sharing.files.single.mimeType, 'image/png');
    expect(sharing.bytes.single, orderedEquals(_png));
    expect(sharing.origin, _origin);
    expect(sharing.text, isNull);
    expect(sharing.subject, isNull);
    expect(sharing.fileNames, isNull);
    final exported = File(sharing.files.single.path);
    expect(exported.parent.path, '${sandbox.path}/bookstar-footprint-exports');
    expect(exported.uri.pathSegments.last, matches(r'^record-[0-9]+\.png$'));
    expect(await exported.exists(), isTrue);
    sharing.gate!.complete(const ShareResult('', ShareResultStatus.dismissed));
    await share;

    expect(await exported.exists(), isFalse);
    expect(gallery.permissionCalls, 0);
    expect(gallery.savedBytes, isEmpty);
  });

  test('share platform exception still cleans the generated PNG', () async {
    sharing.fail = true;

    await expectLater(
        service.share(_png, _origin, () => true), throwsA(isA<StateError>()));

    expect(sharing.calls, 1);
    expect(await File(sharing.files.single.path).exists(), isFalse);
  });

  test(
      'account change while temporary directory lookup is pending prevents sharing',
      () async {
    paths.gate = Completer<String?>();
    var stillOwner = true;
    final share = service.share(_png, _origin, () => stillOwner);
    await paths.started.future;

    stillOwner = false;
    paths.gate!.complete(sandbox.path);
    await share;

    expect(sharing.calls, 0);
    expect(
        await sandbox
            .list(recursive: true)
            .where((entry) => entry is File)
            .toList(),
        isEmpty);
  });

  test(
      'account change after PNG write prevents share and removes the new image',
      () async {
    var ownershipChecks = 0;

    await service.share(_png, _origin, () => ++ownershipChecks == 1);

    expect(ownershipChecks, 2);
    expect(sharing.calls, 0);
    expect(
        await sandbox
            .list(recursive: true)
            .where((entry) => entry is File)
            .toList(),
        isEmpty);
  });

  test('cleanup deletes only expired PNG files inside its own export directory',
      () async {
    final directory =
        await Directory('${sandbox.path}/bookstar-footprint-exports').create();
    final oldOwn =
        await _seed(File('${directory.path}/record-old.png'), old: true);
    final freshOwn = await _seed(File('${directory.path}/record-fresh.png'));
    final otherExtension =
        await _seed(File('${directory.path}/keep.txt'), old: true);
    final outside =
        await _seed(File('${sandbox.path}/unrelated.png'), old: true);
    final nested =
        await _seed(File('${directory.path}/nested/keep.png'), old: true);
    final link =
        await Link('${directory.path}/linked.png').create(outside.path);

    await service.share(_png, _origin, () => true);

    expect(await oldOwn.exists(), isFalse);
    expect(await freshOwn.exists(), isTrue);
    expect(await otherExtension.exists(), isTrue);
    expect(await outside.exists(), isTrue);
    expect(await nested.exists(), isTrue);
    expect(await link.exists(), isTrue);
    expect(await File(sharing.files.single.path).exists(), isFalse);
  });
}

Future<File> _seed(File file, {bool old = false}) async {
  await file.parent.create(recursive: true);
  await file.writeAsBytes(_png);
  if (old) {
    await file
        .setLastModified(DateTime.now().subtract(const Duration(days: 2)));
  }
  return file;
}

final class _Gallery extends GalPlatform {
  bool allowed = true;
  bool failSave = false;
  bool? albumPermissionRequested;
  Completer<bool>? permissionGate;
  final permissionStarted = Completer<void>();
  int permissionCalls = 0;
  int saveCalls = 0;
  final savedBytes = <Uint8List>[];
  String? savedName;
  String? savedAlbum;

  @override
  Future<bool> requestAccess({bool toAlbum = false}) async {
    permissionCalls++;
    albumPermissionRequested = toAlbum;
    permissionStarted.complete();
    return await permissionGate?.future ?? allowed;
  }

  @override
  Future<void> putImageBytes(Uint8List bytes,
      {String? album, required String name}) async {
    saveCalls++;
    if (failSave) throw StateError('isolated gallery failure');
    savedBytes.add(Uint8List.fromList(bytes));
    savedName = name;
    savedAlbum = album;
  }
}

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  Completer<String?>? gate;
  final started = Completer<void>();
  int calls = 0;

  @override
  Future<String?> getTemporaryPath() async {
    calls++;
    if (!started.isCompleted) started.complete();
    return await gate?.future ?? path;
  }
}

class _Sharing extends SharePlatform {
  Completer<ShareResult>? gate;
  final started = Completer<void>();
  bool fail = false;
  int calls = 0;
  List<XFile> files = [];
  final bytes = <Uint8List>[];
  String? subject;
  String? text;
  Rect? origin;
  List<String>? fileNames;

  @override
  Future<ShareResult> shareXFiles(List<XFile> files,
      {String? subject,
      String? text,
      Rect? sharePositionOrigin,
      List<String>? fileNameOverrides}) async {
    calls++;
    this.files = files;
    this.subject = subject;
    this.text = text;
    origin = sharePositionOrigin;
    fileNames = fileNameOverrides;
    for (final file in files) {
      bytes.add(await file.readAsBytes());
    }
    if (!started.isCompleted) started.complete();
    if (fail) throw StateError('isolated share failure');
    return await gate?.future ??
        const ShareResult('', ShareResultStatus.dismissed);
  }
}
