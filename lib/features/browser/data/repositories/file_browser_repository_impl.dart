import '../../domain/entities/audio_file.dart';
import '../../domain/repositories/file_browser_repository.dart';
import '../datasources/file_system_datasource.dart';

/// تنفيذ مستودع متصفح الملفات
class FileBrowserRepositoryImpl implements FileBrowserRepository {
  final FileSystemDataSource _dataSource;

  FileBrowserRepositoryImpl(this._dataSource);

  @override
  Future<List<AudioFile>> listDirectory(String path) async {
    return await _dataSource.listDirectory(path);
  }

  @override
  String getHomeDirectory() {
    return _dataSource.getHomeDirectory();
  }

  @override
  Future<bool> pathExists(String path) async {
    return await _dataSource.pathExists(path);
  }

  @override
  String getParentDirectory(String path) {
    return _dataSource.getParentDirectory(path);
  }
}
