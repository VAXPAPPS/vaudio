import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/playlist.dart';
import '../../../player/domain/entities/audio_track.dart';

/// مصدر بيانات محلي لقوائم التشغيل (JSON)
class PlaylistLocalDataSource {
  static const _fileName = 'playlists.json';

  Future<String> get _filePath async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, _fileName);
  }

  /// تحميل جميع القوائم
  Future<List<Playlist>> loadPlaylists() async {
    try {
      final file = File(await _filePath);
      if (!await file.exists()) return [];

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.map((data) => _playlistFromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  /// حفظ جميع القوائم
  Future<void> savePlaylists(List<Playlist> playlists) async {
    final file = File(await _filePath);
    final jsonList = playlists.map((pl) => _playlistToJson(pl)).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  /// تحويل JSON إلى Playlist
  Playlist _playlistFromJson(Map<String, dynamic> data) {
    return Playlist(
      id: data['id'] as String,
      name: data['name'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      tracks: (data['tracks'] as List<dynamic>?)
              ?.map((t) => _trackFromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// تحويل Playlist إلى JSON
  Map<String, dynamic> _playlistToJson(Playlist playlist) {
    return {
      'id': playlist.id,
      'name': playlist.name,
      'createdAt': playlist.createdAt.toIso8601String(),
      'tracks': playlist.tracks.map((t) => _trackToJson(t)).toList(),
    };
  }

  /// تحويل JSON إلى AudioTrack
  AudioTrack _trackFromJson(Map<String, dynamic> data) {
    return AudioTrack(
      id: data['id'] as String,
      title: data['title'] as String,
      artist: data['artist'] as String? ?? 'Unknown Artist',
      album: data['album'] as String? ?? 'Unknown Album',
      duration: Duration(milliseconds: data['durationMs'] as int? ?? 0),
      filePath: data['filePath'] as String,
    );
  }

  /// تحويل AudioTrack إلى JSON
  Map<String, dynamic> _trackToJson(AudioTrack track) {
    return {
      'id': track.id,
      'title': track.title,
      'artist': track.artist,
      'album': track.album,
      'durationMs': track.duration.inMilliseconds,
      'filePath': track.filePath,
    };
  }
}
