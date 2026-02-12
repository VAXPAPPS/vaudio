import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import '../../../../core/colors/vaxp_colors.dart';
// ignore: unused_import
import '../../../../core/theme/vaxp_theme.dart';
import '../bloc/player_bloc.dart';
import '../bloc/player_event.dart';
import '../bloc/player_state.dart' as ps;
import '../../domain/entities/playback_state.dart';

/// شريط التشغيل السفلي — Now Playing Bar
class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, ps.PlayerState>(
      builder: (context, state) {
        if (state is! ps.PlayerActive) {
          return const SizedBox.shrink();
        }

        final track = state.currentTrack;
        final playback = state.playbackState;

        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 0, 0, 0),
            
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط التقدم العلوي (رفيع)
              _MiniSeekBar(playback: playback),
              // المحتوى الرئيسي
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // أيقونة الموسيقى
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            VaxpColors.secondary.withOpacity(0.5),
                            VaxpColors.primary.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    // معلومات المسار
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 20,
                            child: track.title.length > 30
                                ? Marquee(
                                    text: track.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    scrollAxis: Axis.horizontal,
                                    blankSpace: 60,
                                    velocity: 30,
                                    pauseAfterRound: const Duration(seconds: 2),
                                  )
                                : Text(
                                    track.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artist,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // أزرار التحكم الرئيسية
                    _PlaybackControls(playback: playback),
                    const SizedBox(width: 16),
                    // الوقت
                    Text(
                      '${_formatDuration(playback.position)} / ${_formatDuration(playback.duration)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // التحكم بالصوت
                    _VolumeWidget(playback: playback),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// شريط التقدم المصغر (أعلى NowPlayingBar)
class _MiniSeekBar extends StatelessWidget {
  final PlaybackState playback;
  const _MiniSeekBar({required this.playback});

  @override
  Widget build(BuildContext context) {
    final progress = playback.duration.inMilliseconds > 0
        ? playback.position.inMilliseconds / playback.duration.inMilliseconds
        : 0.0;

    return GestureDetector(
      onTapDown: (details) {
        final width = context.size?.width ?? 1;
        final ratio = details.localPosition.dx / width;
        final newPos = Duration(
          milliseconds: (playback.duration.inMilliseconds * ratio).round(),
        );
        context.read<PlayerBloc>().add(SeekRequested(newPos));
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: (MediaQuery.of(context).size.width * progress).clamp(0, double.infinity),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VaxpColors.secondary,
                  VaxpColors.secondary.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// أزرار التحكم بالتشغيل
class _PlaybackControls extends StatelessWidget {
  final PlaybackState playback;
  const _PlaybackControls({required this.playback});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            size: 18,
            color: playback.isShuffled
                ? VaxpColors.secondary
                : Colors.white.withOpacity(0.5),
          ),
          onPressed: () => bloc.add(ShuffleToggled()),
          splashRadius: 18,
          tooltip: 'Shuffle',
        ),
        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, size: 24),
          onPressed: () => bloc.add(PreviousRequested()),
          splashRadius: 20,
          tooltip: 'Previous',
        ),
        // Play/Pause
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: VaxpColors.secondary.withOpacity(0.3),
          ),
          child: IconButton(
            icon: Icon(
              playback.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 24,
            ),
            onPressed: () {
              if (playback.isPlaying) {
                bloc.add(PauseRequested());
              } else {
                bloc.add(ResumeRequested());
              }
            },
            splashRadius: 20,
            tooltip: playback.isPlaying ? 'Pause' : 'Play',
          ),
        ),
        // Next
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, size: 24),
          onPressed: () => bloc.add(NextRequested()),
          splashRadius: 20,
          tooltip: 'Next',
        ),
        // Repeat
        IconButton(
          icon: Icon(
            playback.repeatMode == RepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            size: 18,
            color: playback.repeatMode != RepeatMode.off
                ? VaxpColors.secondary
                : Colors.white.withOpacity(0.5),
          ),
          onPressed: () => bloc.add(RepeatModeChanged()),
          splashRadius: 18,
          tooltip: 'Repeat',
        ),
      ],
    );
  }
}

/// ويدجت التحكم بالصوت
class _VolumeWidget extends StatelessWidget {
  final PlaybackState playback;
  const _VolumeWidget({required this.playback});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            playback.isMuted || playback.volume == 0
                ? Icons.volume_off_rounded
                : playback.volume < 0.5
                    ? Icons.volume_down_rounded
                    : Icons.volume_up_rounded,
            size: 18,
            color: Colors.white.withOpacity(0.6),
          ),
          onPressed: () => bloc.add(MuteToggled()),
          splashRadius: 16,
          tooltip: 'Mute',
        ),
        SizedBox(
          width: 100,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: VaxpColors.secondary,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: VaxpColors.secondary,
            ),
            child: Slider(
              value: playback.volume,
              min: 0,
              max: 1,
              onChanged: (val) => bloc.add(VolumeChanged(val)),
            ),
          ),
        ),
      ],
    );
  }
}
