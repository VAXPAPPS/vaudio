import 'package:equatable/equatable.dart';
import '../../domain/entities/playlist.dart';

/// حالات قوائم التشغيل
abstract class PlaylistState extends Equatable {
  const PlaylistState();
  @override
  List<Object?> get props => [];
}

/// الحالة المبدئية
class PlaylistInitial extends PlaylistState {}

/// جاري التحميل
class PlaylistLoading extends PlaylistState {}

/// تم تحميل القوائم
class PlaylistLoaded extends PlaylistState {
  final List<Playlist> playlists;

  const PlaylistLoaded(this.playlists);

  @override
  List<Object?> get props => [playlists];
}

/// خطأ
class PlaylistError extends PlaylistState {
  final String message;
  const PlaylistError(this.message);
  @override
  List<Object?> get props => [message];
}
