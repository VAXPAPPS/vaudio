import 'package:just_audio/just_audio.dart';

/// مصدر بيانات مُشغّل الصوت — يغلّف just_audio
class AudioPlayerDataSource {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  /// تشغيل ملف صوتي من المسار المحلي
  Future<Duration?> setFilePath(String filePath) async {
    return await _player.setFilePath(filePath);
  }

  /// تشغيل
  Future<void> play() async {
    await _player.play();
  }

  /// إيقاف مؤقت
  Future<void> pause() async {
    await _player.pause();
  }

  /// إيقاف كامل
  Future<void> stop() async {
    await _player.stop();
  }

  /// الانتقال لموقع معين
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// تغيير مستوى الصوت
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  /// تغيير سرعة التشغيل
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// stream الموقع الحالي
  Stream<Duration> get positionStream => _player.positionStream;

  /// stream المدة الكلية
  Stream<Duration?> get durationStream => _player.durationStream;

  /// stream حالة التشغيل
  Stream<bool> get playingStream => _player.playingStream;

  /// stream حالة المُشغّل (لرصد انتهاء المسار)
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// stream عند اكتمال المسار
  Stream<void> get completeStream => _player.playerStateStream
      .where((state) => state.processingState == ProcessingState.completed)
      .map((_) => null);

  /// التخلص من الموارد
  Future<void> dispose() async {
    await _player.dispose();
  }
}
