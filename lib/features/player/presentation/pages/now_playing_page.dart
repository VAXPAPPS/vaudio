import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/colors/vaxp_colors.dart';
import '../../../../core/theme/vaxp_theme.dart';
import '../bloc/player_bloc.dart';
import '../bloc/player_event.dart';
import '../bloc/player_state.dart' as ps;
import '../../domain/entities/playback_state.dart';
import '../widgets/ambient_visualizer.dart';

/// صفحة Now Playing الكاملة
class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, ps.PlayerState>(
      builder: (context, state) {
        if (state is! ps.PlayerActive) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.headphones_rounded,
                  size: 80,
                  color: Colors.white.withOpacity(0.1),
                ),
                const SizedBox(height: 24),
                Text(
                  'No track playing',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse files to start playing',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          );
        }

        final track = state.currentTrack;
        final playback = state.playbackState;

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              // Album Art كبير
              _AlbumArt(isPlaying: playback.isPlaying),
              const SizedBox(height: 32),
              // عنوان المسار
              Text(
                track.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                track.artist,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 32),
              // شريط التقدم الكبير
              _FullSeekBar(playback: playback),
              const SizedBox(height: 24),
              // أزرار التحكم الكبيرة
              _LargeControls(playback: playback),
              const SizedBox(height: 24),
              // Speed control
              _SpeedControl(playback: playback),
              const Spacer(),
              // Queue info
              if (state.queue.isNotEmpty)
                Text(
                  'Track ${state.currentIndex + 1} of ${state.queue.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// ألبوم آرت
class _AlbumArt extends StatelessWidget {
  final bool isPlaying;
  const _AlbumArt({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: isPlaying ? 1.0 : 0.9),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: AmbientVisualizer(
        isPlaying: isPlaying,
        child: VaxpGlass(
          radius: BorderRadius.circular(110),
          opacity: 0.15,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  VaxpColors.secondary.withOpacity(0.3),
                  VaxpColors.primary.withOpacity(0.5),
                  Colors.purple.withOpacity(0.2),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note_rounded,
                size: 80,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// شريط التقدم الكامل
class _FullSeekBar extends StatelessWidget {
  final PlaybackState playback;
  const _FullSeekBar({required this.playback});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final progress = playback.duration.inMilliseconds > 0
        ? playback.position.inMilliseconds / playback.duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: VaxpColors.secondary,
            inactiveTrackColor: Colors.white.withOpacity(0.08),
            thumbColor: VaxpColors.secondary,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (val) {
              final newPos = Duration(
                milliseconds: (playback.duration.inMilliseconds * val).round(),
              );
              bloc.add(SeekRequested(newPos));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(playback.position),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                _formatDuration(playback.duration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// أزرار التحكم الكبيرة
class _LargeControls extends StatelessWidget {
  final PlaybackState playback;
  const _LargeControls({required this.playback});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            size: 22,
            color: playback.isShuffled
                ? VaxpColors.secondary
                : Colors.white.withOpacity(0.4),
          ),
          onPressed: () => bloc.add(ShuffleToggled()),
          splashRadius: 22,
        ),
        const SizedBox(width: 16),
        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, size: 36),
          onPressed: () => bloc.add(PreviousRequested()),
          splashRadius: 24,
        ),
        const SizedBox(width: 12),
        // Play/Pause (كبير)
        GestureDetector(
          onTap: () {
            if (playback.isPlaying) {
              bloc.add(PauseRequested());
            } else {
              bloc.add(ResumeRequested());
            }
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  VaxpColors.secondary,
                  VaxpColors.secondary.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: VaxpColors.secondary.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              playback.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Next
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, size: 36),
          onPressed: () => bloc.add(NextRequested()),
          splashRadius: 24,
        ),
        const SizedBox(width: 16),
        // Repeat
        IconButton(
          icon: Icon(
            playback.repeatMode == RepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            size: 22,
            color: playback.repeatMode != RepeatMode.off
                ? VaxpColors.secondary
                : Colors.white.withOpacity(0.4),
          ),
          onPressed: () => bloc.add(RepeatModeChanged()),
          splashRadius: 22,
        ),
      ],
    );
  }
}

/// التحكم بالسرعة
class _SpeedControl extends StatelessWidget {
  final PlaybackState playback;
  const _SpeedControl({required this.playback});

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Speed',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(_speeds.length, (i) {
          final speed = _speeds[i];
          final isActive = (playback.speed - speed).abs() < 0.01;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => bloc.add(SpeedChanged(speed)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isActive
                      ? VaxpColors.secondary.withOpacity(0.25)
                      : Colors.transparent,
                ),
                child: Text(
                  '${speed}x',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? VaxpColors.secondary
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
