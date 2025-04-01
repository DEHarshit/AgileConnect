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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBI7rN6_JUSAYp-kRoExizdanOBPAI9nKg',
    appId: '1:244137628596:web:0e92985828a9bfd61158e1',
    messagingSenderId: '244137628596',
    projectId: 'resky-46ea1',
    authDomain: 'resky-46ea1.firebaseapp.com',
    storageBucket: 'resky-46ea1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCw_8bftBkV_3kopY14i8ZxSCKbb9jWyZ0',
    appId: '1:244137628596:android:12ea952f07082bda1158e1',
    messagingSenderId: '244137628596',
    projectId: 'resky-46ea1',
    storageBucket: 'resky-46ea1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCw7nYj-h7-omhU8QjyaK0Lsb8JveSlh7I',
    appId: '1:244137628596:ios:052fb12e3beaaae81158e1',
    messagingSenderId: '244137628596',
    projectId: 'resky-46ea1',
    storageBucket: 'resky-46ea1.firebasestorage.app',
    iosClientId: '244137628596-l1nfvdoud3k7i78pkf5c1rckb7cr5t3i.apps.googleusercontent.com',
    iosBundleId: 'com.example.resky',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBI7rN6_JUSAYp-kRoExizdanOBPAI9nKg',
    appId: '1:244137628596:web:48e95ca572ad99551158e1',
    messagingSenderId: '244137628596',
    projectId: 'resky-46ea1',
    authDomain: 'resky-46ea1.firebaseapp.com',
    storageBucket: 'resky-46ea1.firebasestorage.app',
  );
}
