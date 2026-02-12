import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/colors/vaxp_colors.dart';
// ignore: unused_import
import '../../../../core/theme/vaxp_theme.dart';
import '../../../player/presentation/bloc/player_bloc.dart';
import '../../../player/presentation/bloc/player_event.dart';
// ignore: unused_import
import '../../../player/presentation/bloc/player_state.dart' as ps;
// ignore: unused_import
import '../../../player/domain/entities/audio_track.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../bloc/playlist_state.dart';
import '../../domain/entities/playlist.dart';

/// صفحة قوائم التشغيل
class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: (context, state) {
        if (state is PlaylistInitial) {
          context.read<PlaylistBloc>().add(LoadPlaylists());
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlaylistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlaylistError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        final playlists = (state as PlaylistLoaded).playlists;

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.queue_music_rounded, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Playlists',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // زر إنشاء قائمة جديدة
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: VaxpColors.secondary.withOpacity(0.2),
                      ),
                      child: const Icon(Icons.add_rounded, size: 20),
                    ),
                    onPressed: () => _showCreateDialog(context),
                    splashRadius: 24,
                    tooltip: 'New Playlist',
                  ),
                ],
              ),
            ),
            // القوائم
            Expanded(
              child: playlists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.library_music_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No playlists yet',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create one to organize your music',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        return _PlaylistTile(playlist: playlists[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VaxpColors.glassSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Playlist name...',
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context.read<PlaylistBloc>().add(CreatePlaylist(value.trim()));
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<PlaylistBloc>().add(CreatePlaylist(controller.text.trim()));
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

/// بطاقة قائمة التشغيل
class _PlaylistTile extends StatefulWidget {
  final Playlist playlist;
  const _PlaylistTile({required this.playlist});

  @override
  State<_PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<_PlaylistTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // أيقونة
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          VaxpColors.secondary.withOpacity(0.3),
                          Colors.purple.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.queue_music_rounded,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // معلومات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.playlist.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${widget.playlist.tracks.length} tracks',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Play all
                  if (widget.playlist.tracks.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_filled_rounded,
                        size: 28,
                        color: VaxpColors.secondary,
                      ),
                      onPressed: () {
                        context.read<PlayerBloc>().add(
                          QueueSet(widget.playlist.tracks),
                        );
                      },
                      splashRadius: 20,
                      tooltip: 'Play All',
                    ),
                  // Delete
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: Colors.red.withOpacity(0.5),
                    ),
                    onPressed: () {
                      context.read<PlaylistBloc>().add(
                        DeletePlaylist(widget.playlist.id),
                      );
                    },
                    splashRadius: 18,
                    tooltip: 'Delete',
                  ),
                  // Toggle expand
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
          // Tracks (expanded)
          if (_isExpanded && widget.playlist.tracks.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  ...List.generate(widget.playlist.tracks.length, (i) {
                    final track = widget.playlist.tracks[i];
                    return ListTile(
                      dense: true,
                      leading: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 13,
                        ),
                      ),
                      title: Text(
                        track.title,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        track.artist,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow_rounded, size: 20),
                            onPressed: () {
                              context.read<PlayerBloc>().add(
                                QueueSet(widget.playlist.tracks, startIndex: i),
                              );
                            },
                            splashRadius: 16,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline_rounded,
                              size: 18,
                              color: Colors.red.withOpacity(0.4),
                            ),
                            onPressed: () {
                              context.read<PlaylistBloc>().add(
                                RemoveTrackFromPlaylist(
                                  widget.playlist.id,
                                  track.id,
                                ),
                              );
                            },
                            splashRadius: 16,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
