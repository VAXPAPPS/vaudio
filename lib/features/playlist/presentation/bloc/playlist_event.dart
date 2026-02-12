import 'package:equatable/equatable.dart';
import '../../../player/domain/entities/audio_track.dart';

/// أحداث قوائم التشغيل
abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();
  @override
  List<Object?> get props => [];
}

/// تحميل جميع القوائم
class LoadPlaylists extends PlaylistEvent {}

/// إنشاء قائمة جديدة
class CreatePlaylist extends PlaylistEvent {
  final String name;
  const CreatePlaylist(this.name);
  @override
  List<Object?> get props => [name];
}

/// حذف قائمة
class DeletePlaylist extends PlaylistEvent {
  final String id;
  const DeletePlaylist(this.id);
  @override
  List<Object?> get props => [id];
}

/// إضافة مسار لقائمة
class AddTrackToPlaylist extends PlaylistEvent {
  final String playlistId;
  final AudioTrack track;
  const AddTrackToPlaylist(this.playlistId, this.track);
  @override
  List<Object?> get props => [playlistId, track];
}

/// إزالة مسار من قائمة
class RemoveTrackFromPlaylist extends PlaylistEvent {
  final String playlistId;
  final String trackId;
  const RemoveTrackFromPlaylist(this.playlistId, this.trackId);
  @override
  List<Object?> get props => [playlistId, trackId];
}

/// إعادة ترتيب المسارات
class ReorderTracks extends PlaylistEvent {
  final String playlistId;
  final int oldIndex;
  final int newIndex;
  const ReorderTracks(this.playlistId, this.oldIndex, this.newIndex);
  @override
  List<Object?> get props => [playlistId, oldIndex, newIndex];
}
