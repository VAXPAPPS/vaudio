import 'package:equatable/equatable.dart';

enum RepeatMode { off, one, all }

/// حالة التشغيل
class PlaybackState extends Equatable {
  final Duration position;
  final Duration duration;
  final double volume;
  final double speed;
  final bool isPlaying;
  final RepeatMode repeatMode;
  final bool isShuffled;
  final bool isMuted;

  const PlaybackState({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.speed = 1.0,
    this.isPlaying = false,
    this.repeatMode = RepeatMode.off,
    this.isShuffled = false,
    this.isMuted = false,
  });

  PlaybackState copyWith({
    Duration? position,
    Duration? duration,
    double? volume,
    double? speed,
    bool? isPlaying,
    RepeatMode? repeatMode,
    bool? isShuffled,
    bool? isMuted,
  }) {
    return PlaybackState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      isPlaying: isPlaying ?? this.isPlaying,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffled: isShuffled ?? this.isShuffled,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object?> get props => [
        position,
        duration,
        volume,
        speed,
        isPlaying,
        repeatMode,
        isShuffled,
        isMuted,
      ];
}
