import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_track.dart';

/// أحداث مُشغّل الصوت
abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

/// طلب تشغيل مسار
class PlayRequested extends PlayerEvent {
  final AudioTrack track;
  const PlayRequested(this.track);

  @override
  List<Object?> get props => [track];
}

/// طلب إيقاف مؤقت
class PauseRequested extends PlayerEvent {}

/// طلب استئناف
class ResumeRequested extends PlayerEvent {}

/// طلب إيقاف كامل
class StopRequested extends PlayerEvent {}

/// طلب الانتقال لموقع
class SeekRequested extends PlayerEvent {
  final Duration position;
  const SeekRequested(this.position);

  @override
  List<Object?> get props => [position];
}

/// تغيير مستوى الصوت
class VolumeChanged extends PlayerEvent {
  final double volume;
  const VolumeChanged(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// تغيير سرعة التشغيل
class SpeedChanged extends PlayerEvent {
  final double speed;
  const SpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

/// تبديل كتم الصوت
class MuteToggled extends PlayerEvent {}

/// تبديل وضع التكرار
class RepeatModeChanged extends PlayerEvent {}

/// تبديل التشغيل العشوائي
class ShuffleToggled extends PlayerEvent {}

/// تحديث الموقع الحالي (من stream)
class PositionUpdated extends PlayerEvent {
  final Duration position;
  const PositionUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

/// تحديث المدة الكلية (من stream)
class DurationUpdated extends PlayerEvent {
  final Duration duration;
  const DurationUpdated(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// تحديث حالة التشغيل (من stream)
class PlayingStateUpdated extends PlayerEvent {
  final bool isPlaying;
  const PlayingStateUpdated(this.isPlaying);

  @override
  List<Object?> get props => [isPlaying];
}

/// تشغيل المسار التالي
class NextRequested extends PlayerEvent {}

/// تشغيل المسار السابق
class PreviousRequested extends PlayerEvent {}

/// تعيين قائمة انتظار
class QueueSet extends PlayerEvent {
  final List<AudioTrack> tracks;
  final int startIndex;
  const QueueSet(this.tracks, {this.startIndex = 0});

  @override
  List<Object?> get props => [tracks, startIndex];
}
