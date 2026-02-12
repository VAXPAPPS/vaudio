import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../../player/domain/entities/audio_track.dart';
import '../datasources/playlist_local_datasource.dart';

/// تنفيذ مستودع قوائم التشغيل
class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource _dataSource;
  List<Playlist> _cachedPlaylists = [];

  PlaylistRepositoryImpl(this._dataSource);

  @override
  Future<List<Playlist>> getPlaylists() async {
    _cachedPlaylists = await _dataSource.loadPlaylists();
    return _cachedPlaylists;
  }

  @override
  Future<Playlist> createPlaylist(String name) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    _cachedPlaylists.add(playlist);
    await _dataSource.savePlaylists(_cachedPlaylists);
    return playlist;
  }

  @override
  Future<void> deletePlaylist(String id) async {
    _cachedPlaylists.removeWhere((pl) => pl.id == id);
    await _dataSource.savePlaylists(_cachedPlaylists);
  }

  @override
  Future<Playlist> addTrackToPlaylist(String playlistId, AudioTrack track) async {
    final index = _cachedPlaylists.indexWhere((pl) => pl.id == playlistId);
    if (index == -1) throw Exception('Playlist not found');

    final playlist = _cachedPlaylists[index];
    final updatedPlaylist = playlist.copyWith(
      tracks: [...playlist.tracks, track],
    );
    _cachedPlaylists[index] = updatedPlaylist;
    await _dataSource.savePlaylists(_cachedPlaylists);
    return updatedPlaylist;
  }

  @override
  Future<Playlist> removeTrackFromPlaylist(String playlistId, String trackId) async {
    final index = _cachedPlaylists.indexWhere((pl) => pl.id == playlistId);
    if (index == -1) throw Exception('Playlist not found');

    final playlist = _cachedPlaylists[index];
    final updatedPlaylist = playlist.copyWith(
      tracks: playlist.tracks.where((t) => t.id != trackId).toList(),
    );
    _cachedPlaylists[index] = updatedPlaylist;
    await _dataSource.savePlaylists(_cachedPlaylists);
    return updatedPlaylist;
  }

  @override
  Future<Playlist> reorderTracks(String playlistId, int oldIndex, int newIndex) async {
    final index = _cachedPlaylists.indexWhere((pl) => pl.id == playlistId);
    if (index == -1) throw Exception('Playlist not found');

    final playlist = _cachedPlaylists[index];
    final tracks = List<AudioTrack>.from(playlist.tracks);
    final track = tracks.removeAt(oldIndex);
    tracks.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, track);

    final updatedPlaylist = playlist.copyWith(tracks: tracks);
    _cachedPlaylists[index] = updatedPlaylist;
    await _dataSource.savePlaylists(_cachedPlaylists);
    return updatedPlaylist;
  }

  @override
  Future<void> savePlaylist(Playlist playlist) async {
    final index = _cachedPlaylists.indexWhere((pl) => pl.id == playlist.id);
    if (index != -1) {
      _cachedPlaylists[index] = playlist;
    } else {
      _cachedPlaylists.add(playlist);
    }
    await _dataSource.savePlaylists(_cachedPlaylists);
  }
}
