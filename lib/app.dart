import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/colors/vaxp_colors.dart';
import '../core/theme/vaxp_theme.dart';
import '../core/venom_layout.dart';
import '../di/injection_container.dart';
import '../features/player/presentation/bloc/player_bloc.dart';
import '../features/player/presentation/bloc/player_event.dart';
import '../features/player/presentation/bloc/player_state.dart' as ps;
import '../features/player/presentation/widgets/now_playing_bar.dart';
import '../features/player/presentation/pages/now_playing_page.dart';
import '../features/browser/presentation/bloc/browser_bloc.dart';
import '../features/browser/presentation/pages/browser_page.dart';
import '../features/playlist/presentation/bloc/playlist_bloc.dart';
import '../features/playlist/presentation/pages/playlist_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

import 'package:path/path.dart' as p;
import '../features/player/domain/entities/audio_track.dart';

/// التطبيق الرئيسي مع BLoC Providers
class VenomAudioApp extends StatelessWidget {
  final String? initialAudioPath;
  const VenomAudioApp({super.key, this.initialAudioPath});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerBloc>(create: (_) => sl<PlayerBloc>()),
        BlocProvider<BrowserBloc>(create: (_) => sl<BrowserBloc>()),
        BlocProvider<PlaylistBloc>(create: (_) => sl<PlaylistBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Venom Audio',
        theme: VaxpTheme.dark,
        home: _AudioPlayerShell(initialAudioPath: initialAudioPath),
      ),
    );
  }
}

/// الهيكل الرئيسي للتطبيق
class _AudioPlayerShell extends StatefulWidget {
  final String? initialAudioPath;
  const _AudioPlayerShell({this.initialAudioPath});

  @override
  State<_AudioPlayerShell> createState() => _AudioPlayerShellState();
}

class _AudioPlayerShellState extends State<_AudioPlayerShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialAudioPath != null) {
      _selectedIndex = 1; // Switch to NowPlayingPage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final track = AudioTrack(
          id: widget.initialAudioPath!,
          title: p.basenameWithoutExtension(widget.initialAudioPath!),
          filePath: widget.initialAudioPath!,
        );
        context.read<PlayerBloc>().add(QueueSet([track], startIndex: 0));
      });
    }
  }

  final _pages = const [
    BrowserPage(),
    NowPlayingPage(),
    PlaylistPage(),
    SettingsPage(),
  ];

  final _navItems = const [
    _NavItem(Icons.folder_rounded, 'Browse'),
    _NavItem(Icons.music_note_rounded, 'Playing'),
    _NavItem(Icons.queue_music_rounded, 'Playlists'),
    _NavItem(Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKeyboard,
      child: VenomScaffold(
        title: 'Venom Audio',
        body: Column(
          children: [
            // المحتوى الرئيسي
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _pages[_selectedIndex],
              ),
            ),
            // شريط التشغيل السفلي
            const NowPlayingBar(),
            _BottomNav(
              items: _navItems,
              selectedIndex: _selectedIndex,
              onSelected: (index) => setState(() => _selectedIndex = index),
            ),
          ],
        ),
      ),
    );
  }

  void _handleKeyboard(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final bloc = context.read<PlayerBloc>();
    final state = bloc.state;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        if (state is ps.PlayerActive) {
          if (state.playbackState.isPlaying) {
            bloc.add(PauseRequested());
          } else {
            bloc.add(ResumeRequested());
          }
        }
        break;
      case LogicalKeyboardKey.arrowRight:
        if (state is ps.PlayerActive) {
          final newPos =
              state.playbackState.position + const Duration(seconds: 5);
          bloc.add(SeekRequested(newPos));
        }
        break;
      case LogicalKeyboardKey.arrowLeft:
        if (state is ps.PlayerActive) {
          final newPos =
              state.playbackState.position - const Duration(seconds: 5);
          bloc.add(
            SeekRequested(newPos < Duration.zero ? Duration.zero : newPos),
          );
        }
        break;
      case LogicalKeyboardKey.arrowUp:
        if (state is ps.PlayerActive) {
          final newVol = (state.playbackState.volume + 0.05).clamp(0.0, 1.0);
          bloc.add(VolumeChanged(newVol));
        }
        break;
      case LogicalKeyboardKey.arrowDown:
        if (state is ps.PlayerActive) {
          final newVol = (state.playbackState.volume - 0.05).clamp(0.0, 1.0);
          bloc.add(VolumeChanged(newVol));
        }
        break;
      case LogicalKeyboardKey.keyM:
        bloc.add(MuteToggled());
        break;
      case LogicalKeyboardKey.keyN:
        bloc.add(NextRequested());
        break;
      case LogicalKeyboardKey.keyP:
        bloc.add(PreviousRequested());
        break;
      default:
        break;
    }
  }
}

/// عنصر تنقل
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

/// شريط التنقل السفلي للمقاسات الشبيهة بالهاتف
class _BottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _BottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: VaxpGlass(
        blur: 22,
        opacity: 0.18,
        radius: BorderRadius.circular(24),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == selectedIndex;

              return Expanded(
                child: Tooltip(
                  message: item.label,
                  preferBelow: false,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onSelected(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: isSelected
                            ? VaxpColors.secondary.withValues(alpha: 0.18)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? VaxpColors.secondary.withValues(alpha: 0.35)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            scale: isSelected ? 1.08 : 1.0,
                            child: Icon(
                              item.icon,
                              size: 24,
                              color: isSelected
                                  ? VaxpColors.secondary
                                  : Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.white.withValues(alpha: 0.38),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
