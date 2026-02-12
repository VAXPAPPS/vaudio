import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_file.dart';

/// حالات متصفح الملفات
abstract class BrowserState extends Equatable {
  const BrowserState();
  @override
  List<Object?> get props => [];
}

/// الحالة المبدئية
class BrowserInitial extends BrowserState {}

/// جاري التحميل
class BrowserLoading extends BrowserState {}

/// تم تحميل الملفات
class BrowserLoaded extends BrowserState {
  final String currentPath;
  final List<AudioFile> items;
  final List<String> pathHistory;

  const BrowserLoaded({
    required this.currentPath,
    required this.items,
    this.pathHistory = const [],
  });

  BrowserLoaded copyWith({
    String? currentPath,
    List<AudioFile>? items,
    List<String>? pathHistory,
  }) {
    return BrowserLoaded(
      currentPath: currentPath ?? this.currentPath,
      items: items ?? this.items,
      pathHistory: pathHistory ?? this.pathHistory,
    );
  }

  @override
  List<Object?> get props => [currentPath, items, pathHistory];
}

/// خطأ
class BrowserError extends BrowserState {
  final String message;
  const BrowserError(this.message);
  @override
  List<Object?> get props => [message];
}
