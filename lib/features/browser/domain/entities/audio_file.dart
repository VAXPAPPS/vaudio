import 'package:equatable/equatable.dart';

/// كيان ملف/مجلد في متصفح الملفات
class AudioFile extends Equatable {
  final String name;
  final String path;
  final int size;
  final String extension;
  final bool isDirectory;

  const AudioFile({
    required this.name,
    required this.path,
    this.size = 0,
    this.extension = '',
    this.isDirectory = false,
  });

  static const supportedExtensions = [
    'mp3', 'flac', 'wav', 'ogg', 'm4a', 'aac', 'wma', 'opus',
  ];

  bool get isAudioFile =>
      !isDirectory && supportedExtensions.contains(extension.toLowerCase());

  @override
  List<Object?> get props => [name, path, size, extension, isDirectory];
}
