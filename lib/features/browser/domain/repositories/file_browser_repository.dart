import '../entities/audio_file.dart';

/// واجهة مستودع متصفح الملفات
abstract class FileBrowserRepository {
  /// فحص مجلد والحصول على الملفات
  Future<List<AudioFile>> listDirectory(String path);

  /// الحصول على المجلد الرئيسي (Home)
  String getHomeDirectory();

  /// التحقق من وجود مسار
  Future<bool> pathExists(String path);

  /// الحصول على المجلد الأب
  String getParentDirectory(String path);
}
