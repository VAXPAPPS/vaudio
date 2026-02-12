import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/playlist_repository.dart';
import 'playlist_event.dart';
import 'playlist_state.dart';

/// BLoC قوائم التشغيل
class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository repository;

  PlaylistBloc({required this.repository}) : super(PlaylistInitial()) {
    on<LoadPlaylists>(_onLoadPlaylists);
    on<CreatePlaylist>(_onCreatePlaylist);
    on<DeletePlaylist>(_onDeletePlaylist);
    on<AddTrackToPlaylist>(_onAddTrack);
    on<RemoveTrackFromPlaylist>(_onRemoveTrack);
    on<ReorderTracks>(_onReorderTracks);
  }

  Future<void> _onLoadPlaylists(LoadPlaylists event, Emitter<PlaylistState> emit) async {
    emit(PlaylistLoading());
    try {
      final playlists = await repository.getPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onCreatePlaylist(CreatePlaylist event, Emitter<PlaylistState> emit) async {
    try {
      await repository.createPlaylist(event.name);
      final playlists = await repository.getPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onDeletePlaylist(DeletePlaylist event, Emitter<PlaylistState> emit) async {
    try {
      await repository.deletePlaylist(event.id);
      final playlists = await repository.getPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onAddTrack(AddTrackToPlaylist event, Emitter<PlaylistState> emit) async {
    try {
      await repository.addTrackToPlaylist(event.playlistId, event.track);
      final playlists = await repository.getPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onRemoveTrack(RemoveTrackFromPlaylist event, Emitter<PlaylistState> emit) async {
    try {
      await repository.removeTrackFromPlaylist(event.playlistId, event.trackId);
      final playlists = await repository.getPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onReorderTracks(ReorderTracks event, Emitter<PlaylistState> emit) async {
    try {
      await repository.reorderTracks(event.playlistId, event.oldIndex, event.newIndex);
      final playlists = await repository.getPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }
}
