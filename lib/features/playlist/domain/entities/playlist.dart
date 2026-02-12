import 'package:equatable/equatable.dart';
import '../../../player/domain/entities/audio_track.dart';

/// كيان قائمة التشغيل
class Playlist extends Equatable {
  final String id;
  final String name;
  final List<AudioTrack> tracks;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.name,
    this.tracks = const [],
    required this.createdAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    List<AudioTrack>? tracks,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, tracks, createdAt];
}
