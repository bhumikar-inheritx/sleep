// File generated manually from google-services.json and GoogleService-Info.plist.
// To regenerate, run `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4sbFGfSg1-2Sm-J4IKVked2H09wPZBW4',
    appId: '1:775759679374:android:50b6dd3b7431b63ed45edf',
    messagingSenderId: '775759679374',
    projectId: 'dreamdrift-372e2',
    storageBucket: 'dreamdrift-372e2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqLO0kjVyNhjU27VtjTdBnYZvooRpch-g',
    appId: '1:775759679374:ios:3b4c2bbc30406f47d45edf',
    messagingSenderId: '775759679374',
    projectId: 'dreamdrift-372e2',
    storageBucket: 'dreamdrift-372e2.firebasestorage.app',
    iosBundleId: 'com.inheritx.dreamdrift',
  );
}
