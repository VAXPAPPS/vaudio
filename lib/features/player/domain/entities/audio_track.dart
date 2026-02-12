import 'package:equatable/equatable.dart';

/// كيان المسار الصوتي
class AudioTrack extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String filePath;

  const AudioTrack({
    required this.id,
    required this.title,
    this.artist = 'Unknown Artist',
    this.album = 'Unknown Album',
    this.duration = Duration.zero,
    required this.filePath,
  });

  @override
  List<Object?> get props => [id, title, artist, album, duration, filePath];
}
