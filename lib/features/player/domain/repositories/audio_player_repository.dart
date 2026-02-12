import '../entities/audio_track.dart';

/// واجهة مستودع مُشغّل الصوت
abstract class AudioPlayerRepository {
  /// تشغيل مسار صوتي
  Future<void> play(AudioTrack track);

  /// إيقاف مؤقت
  Future<void> pause();

  /// استئناف التشغيل
  Future<void> resume();

  /// إيقاف كامل
  Future<void> stop();

  /// الانتقال لموقع معين
  Future<void> seek(Duration position);

  /// تغيير مستوى الصوت (0.0 - 1.0)
  Future<void> setVolume(double volume);

  /// تغيير سرعة التشغيل
  Future<void> setSpeed(double speed);

  /// الحصول على stream حالة التشغيل
  Stream<Duration> get positionStream;

  /// الحصول على stream المدة الكلية
  Stream<Duration?> get durationStream;

  /// الحصول على stream حالة المُشغّل
  Stream<bool> get playingStream;

  /// stream اكتمال المسار
  Stream<void> get completeStream;

  /// التخلص من الموارد
  Future<void> dispose();
}
