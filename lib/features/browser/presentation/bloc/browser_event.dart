import 'package:equatable/equatable.dart';
// ignore: unused_import
import '../../domain/entities/audio_file.dart';

/// أحداث متصفح الملفات
abstract class BrowserEvent extends Equatable {
  const BrowserEvent();
  @override
  List<Object?> get props => [];
}

/// الانتقال إلى مجلد
class NavigateToDir extends BrowserEvent {
  final String path;
  const NavigateToDir(this.path);
  @override
  List<Object?> get props => [path];
}

/// العودة للمجلد السابق
class GoBack extends BrowserEvent {}

/// الانتقال للمجلد الأب
class GoToParent extends BrowserEvent {}

/// تحديث المجلد الحالي
class RefreshDir extends BrowserEvent {}

/// تهيئة المتصفح (فتح المجلد الافتراضي)
class BrowserInitialize extends BrowserEvent {}
