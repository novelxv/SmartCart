// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCgCdJeT8xouH4yqDnK_o0e2JMFNIJEoMQ',
    appId: '1:894222291385:web:d1c2cb5866a6cec296a668',
    messagingSenderId: '894222291385',
    projectId: 'smartcart-pro',
    authDomain: 'smartcart-pro.firebaseapp.com',
    storageBucket: 'smartcart-pro.appspot.com',
    measurementId: 'G-GZS9V6BCGM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGQm4DRHz6l1dShPaot92_UCvxrqWgc3I',
    appId: '1:894222291385:android:619184e71ad5ae5496a668',
    messagingSenderId: '894222291385',
    projectId: 'smartcart-pro',
    storageBucket: 'smartcart-pro.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDF1Y2dLNJYvClPWMyUwTE_hH9ZmlWJs4A',
    appId: '1:894222291385:ios:2ea600548fc7932f96a668',
    messagingSenderId: '894222291385',
    projectId: 'smartcart-pro',
    storageBucket: 'smartcart-pro.appspot.com',
    iosBundleId: 'com.example.smartCart',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDF1Y2dLNJYvClPWMyUwTE_hH9ZmlWJs4A',
    appId: '1:894222291385:ios:aaf2c38b408bae8d96a668',
    messagingSenderId: '894222291385',
    projectId: 'smartcart-pro',
    storageBucket: 'smartcart-pro.appspot.com',
    iosBundleId: 'com.example.smartCart.RunnerTests',
  );
}
