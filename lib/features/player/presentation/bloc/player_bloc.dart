import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/audio_track.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/repositories/audio_player_repository.dart';
import 'player_event.dart';
import 'player_state.dart' as ps;

/// BLoC مُشغّل الصوت
class PlayerBloc extends Bloc<PlayerEvent, ps.PlayerState> {
  final AudioPlayerRepository repository;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<bool>? _playingSub;

  // Queue management
  List<AudioTrack> _queue = [];
  List<AudioTrack> _originalQueue = [];
  int _currentIndex = 0;
  double _lastVolume = 1.0;

  PlayerBloc({required this.repository}) : super(ps.PlayerInitial()) {
    on<PlayRequested>(_onPlayRequested);
    on<PauseRequested>(_onPauseRequested);
    on<ResumeRequested>(_onResumeRequested);
    on<StopRequested>(_onStopRequested);
    on<SeekRequested>(_onSeekRequested);
    on<VolumeChanged>(_onVolumeChanged);
    on<SpeedChanged>(_onSpeedChanged);
    on<MuteToggled>(_onMuteToggled);
    on<RepeatModeChanged>(_onRepeatModeChanged);
    on<ShuffleToggled>(_onShuffleToggled);
    on<PositionUpdated>(_onPositionUpdated);
    on<DurationUpdated>(_onDurationUpdated);
    on<PlayingStateUpdated>(_onPlayingStateUpdated);
    on<NextRequested>(_onNextRequested);
    on<PreviousRequested>(_onPreviousRequested);
    on<QueueSet>(_onQueueSet);

    _listenToStreams();
  }

  void _listenToStreams() {
    _positionSub = repository.positionStream.listen((pos) {
      add(PositionUpdated(pos));
    });
    _durationSub = repository.durationStream.listen((dur) {
      if (dur != null) add(DurationUpdated(dur));
    });
    _playingSub = repository.playingStream.listen((playing) {
      add(PlayingStateUpdated(playing));
    });
  }

  Future<void> _onPlayRequested(PlayRequested event, Emitter<ps.PlayerState> emit) async {
    try {
      await repository.play(event.track);

      // إذا تم تشغيل مسار فردي بدون قائمة
      if (_queue.isEmpty || !_queue.contains(event.track)) {
        _queue = [event.track];
        _originalQueue = [event.track];
        _currentIndex = 0;
      } else {
        _currentIndex = _queue.indexOf(event.track);
      }

      emit(ps.PlayerActive(
        currentTrack: event.track,
        playbackState: const PlaybackState(isPlaying: true),
        queue: _queue,
        currentIndex: _currentIndex,
      ));
    } catch (e) {
      emit(ps.PlayerError(e.toString()));
    }
  }

  Future<void> _onPauseRequested(PauseRequested event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive) {
      await repository.pause();
      final activeState = state as ps.PlayerActive;
      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(isPlaying: false),
      ));
    }
  }

  Future<void> _onResumeRequested(ResumeRequested event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive) {
      await repository.resume();
      final activeState = state as ps.PlayerActive;
      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(isPlaying: true),
      ));
    }
  }

  Future<void> _onStopRequested(StopRequested event, Emitter<ps.PlayerState> emit) async {
    await repository.stop();
    emit(ps.PlayerInitial());
  }

  Future<void> _onSeekRequested(SeekRequested event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive) {
      await repository.seek(event.position);
      final activeState = state as ps.PlayerActive;
      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(position: event.position),
      ));
    }
  }

  Future<void> _onVolumeChanged(VolumeChanged event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive) {
      await repository.setVolume(event.volume);
      _lastVolume = event.volume;
      final activeState = state as ps.PlayerActive;
      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(
          volume: event.volume,
          isMuted: false,
        ),
      ));
    }
  }

  Future<void> _onSpeedChanged(SpeedChanged event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive) {
      await repository.setSpeed(event.speed);
      final activeState = state as ps.PlayerActive;
      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(speed: event.speed),
      ));
    }
  }

  Future<void> _onMuteToggled(MuteToggled event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive) {
      final activeState = state as ps.PlayerActive;
      final isMuted = !activeState.playbackState.isMuted;

      if (isMuted) {
        _lastVolume = activeState.playbackState.volume;
        await repository.setVolume(0);
      } else {
        await repository.setVolume(_lastVolume);
      }

      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(
          isMuted: isMuted,
          volume: isMuted ? 0 : _lastVolume,
        ),
      ));
    }
  }

  Future<void> _onRepeatModeChanged(RepeatModeChanged event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive) {
      final activeState = state as ps.PlayerActive;
      final currentMode = activeState.playbackState.repeatMode;
      final nextMode = RepeatMode.values[
        (currentMode.index + 1) % RepeatMode.values.length
      ];
      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(repeatMode: nextMode),
      ));
    }
  }

  Future<void> _onShuffleToggled(ShuffleToggled event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive) {
      final activeState = state as ps.PlayerActive;
      final isShuffled = !activeState.playbackState.isShuffled;

      if (isShuffled) {
        _originalQueue = List.from(_queue);
        _queue = List.from(_queue)..shuffle(Random());
        // اجعل المسار الحالي في البداية
        final currentTrack = activeState.currentTrack;
        _queue.remove(currentTrack);
        _queue.insert(0, currentTrack);
        _currentIndex = 0;
      } else {
        _queue = List.from(_originalQueue);
        _currentIndex = _queue.indexOf(activeState.currentTrack);
      }

      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(isShuffled: isShuffled),
        queue: _queue,
        currentIndex: _currentIndex,
      ));
    }
  }

  void _onPositionUpdated(PositionUpdated event, Emitter<ps.PlayerState> emit) {
    if (state is ps.PlayerActive) {
      final activeState = state as ps.PlayerActive;
      final duration = activeState.playbackState.duration;

      // كشف انتهاء المسار
      if (duration > Duration.zero && event.position >= duration) {
        _handleTrackEnd(emit);
        return;
      }

      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(position: event.position),
      ));
    }
  }

  void _onDurationUpdated(DurationUpdated event, Emitter<ps.PlayerState> emit) {
    if (state is ps.PlayerActive) {
      final activeState = state as ps.PlayerActive;
      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(duration: event.duration),
      ));
    }
  }

  void _onPlayingStateUpdated(PlayingStateUpdated event, Emitter<ps.PlayerState> emit) {
    if (state is ps.PlayerActive) {
      final activeState = state as ps.PlayerActive;
      emit(activeState.copyWith(
        playbackState: activeState.playbackState.copyWith(isPlaying: event.isPlaying),
      ));
    }
  }

  Future<void> _onNextRequested(NextRequested event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive && _queue.isNotEmpty) {
      final activeState = state as ps.PlayerActive;
      final repeatMode = activeState.playbackState.repeatMode;

      if (repeatMode == RepeatMode.one) {
        await repository.seek(Duration.zero);
        await repository.resume();
        return;
      }

      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
        add(PlayRequested(_queue[_currentIndex]));
      } else if (repeatMode == RepeatMode.all) {
        _currentIndex = 0;
        add(PlayRequested(_queue[_currentIndex]));
      }
    }
  }

  Future<void> _onPreviousRequested(PreviousRequested event, Emitter<ps.PlayerState> emit) async {
    if (state is ps.PlayerActive && _queue.isNotEmpty) {
      final activeState = state as ps.PlayerActive;

      // إذا الموقع > 3 ثواني، أعد المسار الحالي
      if (activeState.playbackState.position.inSeconds > 3) {
        await repository.seek(Duration.zero);
        return;
      }

      if (_currentIndex > 0) {
        _currentIndex--;
        add(PlayRequested(_queue[_currentIndex]));
      } else if (activeState.playbackState.repeatMode == RepeatMode.all) {
        _currentIndex = _queue.length - 1;
        add(PlayRequested(_queue[_currentIndex]));
      }
    }
  }

  Future<void> _onQueueSet(QueueSet event, Emitter<ps.PlayerState> emit) async {
    _queue = List.from(event.tracks);
    _originalQueue = List.from(event.tracks);
    _currentIndex = event.startIndex;

    if (_queue.isNotEmpty) {
      add(PlayRequested(_queue[_currentIndex]));
    }
  }

  void _handleTrackEnd(Emitter<ps.PlayerState> emit) {
    if (state is ps.PlayerActive) {
      final activeState = state as ps.PlayerActive;
      final repeatMode = activeState.playbackState.repeatMode;

      if (repeatMode == RepeatMode.one) {
        repository.seek(Duration.zero);
        repository.resume();
      } else if (_currentIndex < _queue.length - 1) {
        add(NextRequested());
      } else if (repeatMode == RepeatMode.all) {
        _currentIndex = 0;
        add(PlayRequested(_queue[0]));
      } else {
        emit(activeState.copyWith(
          playbackState: activeState.playbackState.copyWith(
            isPlaying: false,
            position: Duration.zero,
          ),
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    repository.dispose();
    return super.close();
  }
}
