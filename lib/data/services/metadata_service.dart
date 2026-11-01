import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;
import 'package:path/path.dart' as p;
import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/text_encoding.dart';

/// Reads audio file metadata tags on a background isolate.
class MetadataService implements TrackMetadataReader {
  static _MetadataIsolateClient? _client;
  static Future<_MetadataIsolateClient>? _opening;

  @override
  Future<TrackMetadata> readMetadata(String filePath) async {
    try {
      final client = await _sharedClient();
      return await client.read(filePath);
    } on Object {
      return readMetadataSync(filePath);
    }
  }

  /// Embedded cover image bytes from [filePath], preferring a front cover.
  Uint8List? readEmbeddedArtwork(String filePath) {
    try {
      final metadata = amr.readMetadata(File(filePath), getImage: true);
      if (metadata.pictures.isEmpty) return null;
      final front = metadata.pictures.where(
        (picture) => picture.pictureType == amr.PictureType.coverFront,
      );
      final picture = front.isNotEmpty ? front.first : metadata.pictures.first;
      if (picture.bytes.isEmpty) return null;
      return picture.bytes;
    } catch (_) {
      return null;
    }
  }

  /// Same-isolate tag read used by the metadata worker and as a fallback.
  static TrackMetadata readMetadataSync(String filePath) {
    try {
      final metadata = amr.readMetadata(File(filePath));
      return TrackMetadata(
        title: repairMetadataText(metadata.title),
        artist: repairMetadataText(metadata.artist),
        album: repairMetadataText(metadata.album),
        trackNumber: metadata.trackNumber,
        discNumber: metadata.discNumber,
        year: metadata.year?.year,
        genre: metadata.genres.isNotEmpty
            ? repairMetadataText(metadata.genres.first)
            : null,
        duration: metadata.duration,
      );
    } catch (_) {
      return TrackMetadata(title: p.basenameWithoutExtension(filePath));
    }
  }

  static Future<_MetadataIsolateClient> _sharedClient() {
    final existing = _client;
    if (existing != null) return Future.value(existing);
    return _opening ??= _MetadataIsolateClient.spawn().then((client) {
      _client = client;
      _opening = null;
      return client;
    });
  }
}

class _MetadataIsolateClient {
  _MetadataIsolateClient(this._responses) {
    _responses.listen(_onMessage);
  }

  final ReceivePort _responses;
  final Completer<void> _ready = Completer<void>();
  SendPort? _commands;
  int _nextId = 0;
  final Map<int, Completer<TrackMetadata>> _pending = {};

  static Future<_MetadataIsolateClient> spawn() async {
    final responses = ReceivePort();
    await Isolate.spawn(_metadataWorker, responses.sendPort);
    final client = _MetadataIsolateClient(responses);
    await client._ready.future;
    return client;
  }

  void _onMessage(dynamic message) {
    if (_commands == null && message is SendPort) {
      _commands = message;
      if (!_ready.isCompleted) _ready.complete();
      return;
    }
    if (message is! List || message.length < 2) return;
    final id = message[0];
    final payload = message[1];
    if (id is! int || payload is! Map) return;
    final completer = _pending.remove(id);
    if (completer == null || completer.isCompleted) return;
    completer.complete(_metadataFromMap(Map<Object?, Object?>.from(payload)));
  }

  Future<TrackMetadata> read(String filePath) {
    final commands = _commands;
    if (commands == null) {
      return Future.error(StateError('Metadata isolate is not ready'));
    }
    final id = _nextId++;
    final completer = Completer<TrackMetadata>();
    _pending[id] = completer;
    commands.send(<Object?>[id, filePath]);
    return completer.future;
  }
}

void _metadataWorker(SendPort send) {
  final port = ReceivePort();
  send.send(port.sendPort);
  port.listen((message) {
    if (message == null) {
      port.close();
      return;
    }
    if (message is! List || message.length < 2) return;
    final id = message[0];
    final path = message[1];
    if (id is! int || path is! String) return;
    final metadata = MetadataService.readMetadataSync(path);
    send.send(<Object?>[id, _metadataToMap(metadata)]);
  });
}

Map<String, Object?> _metadataToMap(TrackMetadata metadata) => {
  'title': metadata.title,
  'artist': metadata.artist,
  'album': metadata.album,
  'albumArtist': metadata.albumArtist,
  'trackNumber': metadata.trackNumber,
  'discNumber': metadata.discNumber,
  'year': metadata.year,
  'genre': metadata.genre,
  'durationMs': metadata.duration?.inMilliseconds,
};

TrackMetadata _metadataFromMap(Map<Object?, Object?> map) {
  final durationMs = map['durationMs'];
  return TrackMetadata(
    title: map['title'] as String?,
    artist: map['artist'] as String?,
    album: map['album'] as String?,
    albumArtist: map['albumArtist'] as String?,
    trackNumber: map['trackNumber'] as int?,
    discNumber: map['discNumber'] as int?,
    year: map['year'] as int?,
    genre: map['genre'] as String?,
    duration: durationMs is int ? Duration(milliseconds: durationMs) : null,
  );
}
