import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import '../../../../core/colors/vaxp_colors.dart';
// ignore: unused_import
import '../../../../core/theme/vaxp_theme.dart';
import '../../../player/domain/entities/audio_track.dart';
import '../../../player/presentation/bloc/player_bloc.dart';
import '../../../player/presentation/bloc/player_event.dart';
import '../../../player/presentation/bloc/player_state.dart' as ps;
import '../bloc/browser_bloc.dart';
import '../bloc/browser_event.dart';
import '../bloc/browser_state.dart';
import '../../domain/entities/audio_file.dart';

/// صفحة متصفح الملفات
class BrowserPage extends StatelessWidget {
  const BrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserBloc, BrowserState>(
      builder: (context, state) {
        if (state is BrowserInitial) {
          // تهيئة المتصفح
          context.read<BrowserBloc>().add(BrowserInitialize());
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BrowserLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BrowserError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.withOpacity(0.7)),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<BrowserBloc>().add(BrowserInitialize()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final loaded = state as BrowserLoaded;

        return Column(
          children: [
            // شريط التنقل (Breadcrumb + أزرار)
            _BreadcrumbBar(
              currentPath: loaded.currentPath,
              canGoBack: loaded.pathHistory.length > 1,
            ),
            // قائمة الملفات
            Expanded(
              child: loaded.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No audio files found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: loaded.items.length,
                      itemBuilder: (context, index) {
                        return _AudioFileTile(
                          file: loaded.items[index],
                          allFiles: loaded.items,
                          index: index,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// شريط التنقل (Breadcrumb)
class _BreadcrumbBar extends StatelessWidget {
  final String currentPath;
  final bool canGoBack;

  const _BreadcrumbBar({
    required this.currentPath,
    required this.canGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final parts = currentPath.split('/').where((p) => p.isNotEmpty).toList();
    final bloc = context.read<BrowserBloc>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      child: Row(
        children: [
          // زر العودة
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: canGoBack ? () => bloc.add(GoBack()) : null,
            splashRadius: 18,
            tooltip: 'Back',
          ),
          // زر المجلد الأب
          IconButton(
            icon: const Icon(Icons.arrow_upward_rounded, size: 20),
            onPressed: () => bloc.add(GoToParent()),
            splashRadius: 18,
            tooltip: 'Up',
          ),
          // زر التحديث
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () => bloc.add(RefreshDir()),
            splashRadius: 18,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          // عرض المسار كـ breadcrumb
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Root
                  _BreadcrumbItem(
                    label: '/',
                    onTap: () => bloc.add(NavigateToDir('/')),
                  ),
                  for (int i = 0; i < parts.length; i++) ...[
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _BreadcrumbItem(
                      label: parts[i],
                      isLast: i == parts.length - 1,
                      onTap: () {
                        final path = '/${parts.sublist(0, i + 1).join('/')}';
                        bloc.add(NavigateToDir(path));
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final bool isLast;
  final VoidCallback onTap;

  const _BreadcrumbItem({
    required this.label,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
            color: isLast ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

/// بطاقة ملف/مجلد
class _AudioFileTile extends StatelessWidget {
  final AudioFile file;
  final List<AudioFile> allFiles;
  final int index;

  const _AudioFileTile({
    required this.file,
    required this.allFiles,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _onTap(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // أيقونة
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: file.isDirectory
                      ? Colors.amber.withOpacity(0.15)
                      : VaxpColors.secondary.withOpacity(0.1),
                ),
                child: Icon(
                  file.isDirectory
                      ? Icons.folder_rounded
                      : _getFileIcon(file.extension),
                  color: file.isDirectory
                      ? Colors.amber
                      : VaxpColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // اسم الملف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!file.isDirectory)
                      Text(
                        '${file.extension.toUpperCase()} • ${_formatSize(file.size)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                  ],
                ),
              ),
              // أيقونة التشغيل/الدخول
              if (!file.isDirectory)
                BlocBuilder<PlayerBloc, ps.PlayerState>(
                  builder: (context, state) {
                    final isPlaying = state is ps.PlayerActive &&
                        state.currentTrack.filePath == file.path;
                    return IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.equalizer_rounded
                            : Icons.play_circle_outline_rounded,
                        color: isPlaying
                            ? VaxpColors.secondary
                            : Colors.white.withOpacity(0.3),
                        size: 24,
                      ),
                      onPressed: () => _onTap(context),
                      splashRadius: 18,
                    );
                  },
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (file.isDirectory) {
      context.read<BrowserBloc>().add(NavigateToDir(file.path));
    } else {
      // تشغيل الملف + تعيين كل ملفات الصوت كقائمة انتظار
      final audioFiles = allFiles.where((f) => !f.isDirectory).toList();
      final tracks = audioFiles.map((f) => AudioTrack(
        id: f.path,
        title: p.basenameWithoutExtension(f.name),
        filePath: f.path,
      )).toList();
      final audioIndex = audioFiles.indexWhere((f) => f.path == file.path);
      context.read<PlayerBloc>().add(QueueSet(tracks, startIndex: audioIndex));
    }
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'flac':
        return Icons.high_quality_rounded;
      case 'wav':
        return Icons.graphic_eq_rounded;
      case 'mp3':
        return Icons.music_note_rounded;
      default:
        return Icons.audiotrack_rounded;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}
