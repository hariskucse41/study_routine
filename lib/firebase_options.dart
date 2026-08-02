// ⚠️ PLACEHOLDER FILE — NOT REAL FIREBASE CONFIG ⚠️
//
// This file was hand-written as a stand-in because no Firebase project has
// been wired up yet in this environment (no `firebase`/`flutterfire` CLI,
// no existing project). The values below are fake and will NOT connect to
// any real Firebase project — Firebase.initializeApp() will throw at
// runtime until this file is regenerated for real.
//
// To replace it with a working file, run from the project root:
//   npm install -g firebase-tools
//   firebase login
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<your-firebase-project-id>
// This overwrites this file automatically with real per-platform config.
// See §3.2 of the implementation guide.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform. '
          'Run `flutterfire configure` to generate real options.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'com.yourname.studyRoutine',
  );
}
