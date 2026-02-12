import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/file_browser_repository.dart';
import 'browser_event.dart';
import 'browser_state.dart';

/// BLoC متصفح الملفات
class BrowserBloc extends Bloc<BrowserEvent, BrowserState> {
  final FileBrowserRepository repository;

  BrowserBloc({required this.repository}) : super(BrowserInitial()) {
    on<BrowserInitialize>(_onInitialize);
    on<NavigateToDir>(_onNavigateToDir);
    on<GoBack>(_onGoBack);
    on<GoToParent>(_onGoToParent);
    on<RefreshDir>(_onRefreshDir);
  }

  Future<void> _onInitialize(BrowserInitialize event, Emitter<BrowserState> emit) async {
    emit(BrowserLoading());
    try {
      final homePath = repository.getHomeDirectory();
      final items = await repository.listDirectory(homePath);
      emit(BrowserLoaded(
        currentPath: homePath,
        items: items,
        pathHistory: [homePath],
      ));
    } catch (e) {
      emit(BrowserError(e.toString()));
    }
  }

  Future<void> _onNavigateToDir(NavigateToDir event, Emitter<BrowserState> emit) async {
    final currentState = state;
    emit(BrowserLoading());
    try {
      final items = await repository.listDirectory(event.path);
      final history = currentState is BrowserLoaded
          ? [...currentState.pathHistory, event.path]
          : [event.path];
      emit(BrowserLoaded(
        currentPath: event.path,
        items: items,
        pathHistory: history,
      ));
    } catch (e) {
      emit(BrowserError(e.toString()));
    }
  }

  Future<void> _onGoBack(GoBack event, Emitter<BrowserState> emit) async {
    if (state is BrowserLoaded) {
      final loaded = state as BrowserLoaded;
      if (loaded.pathHistory.length > 1) {
        final newHistory = List<String>.from(loaded.pathHistory);
        newHistory.removeLast();
        final previousPath = newHistory.last;
        try {
          final items = await repository.listDirectory(previousPath);
          emit(BrowserLoaded(
            currentPath: previousPath,
            items: items,
            pathHistory: newHistory,
          ));
        } catch (e) {
          emit(BrowserError(e.toString()));
        }
      }
    }
  }

  Future<void> _onGoToParent(GoToParent event, Emitter<BrowserState> emit) async {
    if (state is BrowserLoaded) {
      final loaded = state as BrowserLoaded;
      final parentPath = repository.getParentDirectory(loaded.currentPath);
      if (parentPath != loaded.currentPath) {
        add(NavigateToDir(parentPath));
      }
    }
  }

  Future<void> _onRefreshDir(RefreshDir event, Emitter<BrowserState> emit) async {
    if (state is BrowserLoaded) {
      final loaded = state as BrowserLoaded;
      emit(BrowserLoading());
      try {
        final items = await repository.listDirectory(loaded.currentPath);
        emit(loaded.copyWith(items: items));
      } catch (e) {
        emit(BrowserError(e.toString()));
      }
    }
  }
}
