import '../../../player/domain/entities/audio_track.dart';
import '../entities/playlist.dart';

/// واجهة مستودع قوائم التشغيل
abstract class PlaylistRepository {
  /// الحصول على جميع القوائم
  Future<List<Playlist>> getPlaylists();

  /// إنشاء قائمة جديدة
  Future<Playlist> createPlaylist(String name);

  /// حذف قائمة
  Future<void> deletePlaylist(String id);

  /// إضافة مسار لقائمة
  Future<Playlist> addTrackToPlaylist(String playlistId, AudioTrack track);

  /// إزالة مسار من قائمة
  Future<Playlist> removeTrackFromPlaylist(String playlistId, String trackId);

  /// إعادة ترتيب المسارات في قائمة
  Future<Playlist> reorderTracks(String playlistId, int oldIndex, int newIndex);

  /// حفظ القائمة
  Future<void> savePlaylist(Playlist playlist);
}
