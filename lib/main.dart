import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:venom_config/venom_config.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'core/colors/vaxp_colors.dart';
import 'di/injection_container.dart';
import 'app.dart';

Future<void> main() async {
  // Initialize Flutter bindings first
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize media_kit for Linux audio support
  JustAudioMediaKit.ensureInitialized();

  // Initialize Venom Config System
  await VenomConfig().init();

  // Initialize VaxpColors listeners
  VaxpColors.init();

  // Initialize Dependency Injection
  await initDependencies();

  // Initialize window manager for desktop controls
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1100, 750),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Vaxp Audio',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const VenomAudioApp());
}
