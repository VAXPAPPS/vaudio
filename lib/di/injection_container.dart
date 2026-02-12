import 'package:get_it/get_it.dart';

// Data Sources
import 'package:vaudio/features/player/data/datasources/audio_player_datasource.dart';
import 'package:vaudio/features/browser/data/datasources/file_system_datasource.dart';
import 'package:vaudio/features/playlist/data/datasources/playlist_local_datasource.dart';

// Repositories
import 'package:vaudio/features/player/domain/repositories/audio_player_repository.dart';
import 'package:vaudio/features/player/data/repositories/audio_player_repository_impl.dart';
import 'package:vaudio/features/browser/domain/repositories/file_browser_repository.dart';
import 'package:vaudio/features/browser/data/repositories/file_browser_repository_impl.dart';
import 'package:vaudio/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:vaudio/features/playlist/data/repositories/playlist_repository_impl.dart';

// BLoCs
import 'package:vaudio/features/player/presentation/bloc/player_bloc.dart';
import 'package:vaudio/features/browser/presentation/bloc/browser_bloc.dart';
import 'package:vaudio/features/playlist/presentation/bloc/playlist_bloc.dart';

final sl = GetIt.instance;

/// تهيئة حاوية حقن التبعيات
Future<void> initDependencies() async {
  // ═══════════════════════════════════════════
  // Data Sources (Singletons)
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<AudioPlayerDataSource>(
    () => AudioPlayerDataSource(),
  );
  sl.registerLazySingleton<FileSystemDataSource>(
    () => FileSystemDataSource(),
  );
  sl.registerLazySingleton<PlaylistLocalDataSource>(
    () => PlaylistLocalDataSource(),
  );

  // ═══════════════════════════════════════════
  // Repositories (Singletons)
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<AudioPlayerRepository>(
    () => AudioPlayerRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FileBrowserRepository>(
    () => FileBrowserRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(sl()),
  );

  // ═══════════════════════════════════════════
  // BLoCs (Factories — كل شاشة تحصل على instance جديد)
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<PlayerBloc>(
    () => PlayerBloc(repository: sl()),
  );
  sl.registerFactory<BrowserBloc>(
    () => BrowserBloc(repository: sl()),
  );
  sl.registerFactory<PlaylistBloc>(
    () => PlaylistBloc(repository: sl()),
  );
}
