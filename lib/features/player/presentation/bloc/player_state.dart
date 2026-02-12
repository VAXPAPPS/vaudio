import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_track.dart';
import '../../domain/entities/playback_state.dart';

/// حالات مُشغّل الصوت
abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

/// الحالة المبدئية
class PlayerInitial extends PlayerState {}

/// حالة التشغيل النشطة (تشمل التشغيل والإيقاف المؤقت)
class PlayerActive extends PlayerState {
  final AudioTrack currentTrack;
  final PlaybackState playbackState;
  final List<AudioTrack> queue;
  final int currentIndex;

  const PlayerActive({
    required this.currentTrack,
    required this.playbackState,
    this.queue = const [],
    this.currentIndex = 0,
  });

  PlayerActive copyWith({
    AudioTrack? currentTrack,
    PlaybackState? playbackState,
    List<AudioTrack>? queue,
    int? currentIndex,
  }) {
    return PlayerActive(
      currentTrack: currentTrack ?? this.currentTrack,
      playbackState: playbackState ?? this.playbackState,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [currentTrack, playbackState, queue, currentIndex];
}

/// حالة الخطأ
class PlayerError extends PlayerState {
  final String message;
  const PlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
