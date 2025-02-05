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
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDaGF57PbmUUq_3d5XsYKNJGG1QEw9qSm4',
    appId: '1:907412954714:web:3741ab1765aebbf7c18263',
    messagingSenderId: '907412954714',
    projectId: 'power-sure',
    authDomain: 'power-sure.firebaseapp.com',
    storageBucket: 'power-sure.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDaGF57PbmUUq_3d5XsYKNJGG1QEw9qSm4',
    appId: '1:907412954714:android:3741ab1765aebbf7c18263',
    messagingSenderId: '907412954714',
    projectId: 'power-sure',
    storageBucket: 'power-sure.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDaGF57PbmUUq_3d5XsYKNJGG1QEw9qSm4',
    appId: '1:907412954714:ios:3741ab1765aebbf7c18263',
    messagingSenderId: '907412954714',
    projectId: 'power-sure',
    storageBucket: 'power-sure.firebasestorage.app',
    iosClientId: '907412954714-ios.apps.googleusercontent.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDaGF57PbmUUq_3d5XsYKNJGG1QEw9qSm4',
    appId: '1:907412954714:macos:3741ab1765aebbf7c18263',
    messagingSenderId: '907412954714',
    projectId: 'power-sure',
    storageBucket: 'power-sure.firebasestorage.app',
    iosClientId: '907412954714-macos.apps.googleusercontent.com',
  );
}
