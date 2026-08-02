import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/injector.dart';
import 'core/notifications/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupInjector();
  // No-ops on web (see NotificationService) — safe to call unconditionally.
  await getIt<NotificationService>().init();
  runApp(const StudyRoutineApp());
}

