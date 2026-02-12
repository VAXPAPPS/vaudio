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

/// التطبيق الرئيسي مع BLoC Providers
class VenomAudioApp extends StatelessWidget {
  const VenomAudioApp({super.key});

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
        home: const _AudioPlayerShell(),
      ),
    );
  }
}

/// الهيكل الرئيسي للتطبيق
class _AudioPlayerShell extends StatefulWidget {
  const _AudioPlayerShell();

  @override
  State<_AudioPlayerShell> createState() => _AudioPlayerShellState();
}

class _AudioPlayerShellState extends State<_AudioPlayerShell> {
  int _selectedIndex = 0;

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
        body: Row(
          children: [
            // الشريط الجانبي
            _SideNav(
              items: _navItems,
              selectedIndex: _selectedIndex,
              onSelected: (index) => setState(() => _selectedIndex = index),
            ),
            // المحتوى الرئيسي
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                  // شريط التشغيل السفلي
                  const NowPlayingBar(),
                ],
              ),
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
          final newPos = state.playbackState.position + const Duration(seconds: 5);
          bloc.add(SeekRequested(newPos));
        }
        break;
      case LogicalKeyboardKey.arrowLeft:
        if (state is ps.PlayerActive) {
          final newPos = state.playbackState.position - const Duration(seconds: 5);
          bloc.add(SeekRequested(newPos < Duration.zero ? Duration.zero : newPos));
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

/// الشريط الجانبي
class _SideNav extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _SideNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final isSelected = i == selectedIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Tooltip(
                message: item.label,
                preferBelow: false,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? VaxpColors.secondary.withOpacity(0.15)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isSelected
                              ? VaxpColors.secondary
                              : Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected
                                ? VaxpColors.secondary
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
