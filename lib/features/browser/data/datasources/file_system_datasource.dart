import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/entities/audio_file.dart';

/// مصدر بيانات نظام الملفات
class FileSystemDataSource {
  /// فلاتر الملفات الصوتية المدعومة
  static const _supportedExtensions = [
    '.mp3', '.flac', '.wav', '.ogg', '.m4a', '.aac', '.wma', '.opus',
  ];

  /// فحص مجلد والحصول على القائمة
  Future<List<AudioFile>> listDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      throw Exception('Directory does not exist: $path');
    }

    final List<AudioFile> items = [];

    await for (final entity in dir.list()) {
      final name = p.basename(entity.path);

      // تجاهل الملفات المخفية
      if (name.startsWith('.')) continue;

      if (entity is Directory) {
        items.add(AudioFile(
          name: name,
          path: entity.path,
          isDirectory: true,
        ));
      } else if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (_supportedExtensions.contains(ext)) {
          final stat = await entity.stat();
          items.add(AudioFile(
            name: name,
            path: entity.path,
            size: stat.size,
            extension: ext.replaceFirst('.', ''),
          ));
        }
      }
    }

    // ترتيب: المجلدات أولاً ثم الملفات (أبجدياً)
    items.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return items;
  }

  /// الحصول على المجلد الرئيسي
  String getHomeDirectory() {
    return Platform.environment['HOME'] ?? '/home';
  }

  /// التحقق من وجود مسار
  Future<bool> pathExists(String path) async {
    return await Directory(path).exists() || await File(path).exists();
  }

  /// الحصول على المجلد الأب
  String getParentDirectory(String path) {
    return p.dirname(path);
  }
}
