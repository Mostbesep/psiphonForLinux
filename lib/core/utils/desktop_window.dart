import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

Future<void> setupDesktopWindowSettings() async {
  WindowOptions windowOptions = WindowOptions(
    size: Size(500, 768),
    maximumSize: Size(1280, 768),
    minimumSize: Size(500, 768),
    center: true,
    skipTaskbar: false,
    title: 'Psiphon',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.focus();
  });
}