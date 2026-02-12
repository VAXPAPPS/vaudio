import '../../domain/entities/audio_track.dart';
import '../../domain/repositories/audio_player_repository.dart';
import '../datasources/audio_player_datasource.dart';

/// تنفيذ مستودع مُشغّل الصوت
class AudioPlayerRepositoryImpl implements AudioPlayerRepository {
  final AudioPlayerDataSource _dataSource;

  AudioPlayerRepositoryImpl(this._dataSource);

  @override
  Future<void> play(AudioTrack track) async {
    await _dataSource.setFilePath(track.filePath);
    await _dataSource.play();
  }

  @override
  Future<void> pause() async {
    await _dataSource.pause();
  }

  @override
  Future<void> resume() async {
    await _dataSource.play();
  }

  @override
  Future<void> stop() async {
    await _dataSource.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _dataSource.seek(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _dataSource.setVolume(volume);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _dataSource.setSpeed(speed);
  }

  @override
  Stream<Duration> get positionStream => _dataSource.positionStream;

  @override
  Stream<Duration?> get durationStream => _dataSource.durationStream;

  @override
  Stream<bool> get playingStream => _dataSource.playingStream;

  @override
  Future<void> dispose() async {
    await _dataSource.dispose();
  }
}
