// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClIYdTMn7lfItz4fHXeASszUXWz9MGzN0',
    appId: '1:244079569882:android:f1f8a9dc05b1c4b88aaee3',
    messagingSenderId: '244079569882',
    projectId: 'geolocation-attendance-tracker',
    storageBucket: 'geolocation-attendance-tracker.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2_3hs4bgcuYiVmmvlPTLaKb47Hvdq0Aw',
    appId: '1:244079569882:ios:29433763e1038c1a8aaee3',
    messagingSenderId: '244079569882',
    projectId: 'geolocation-attendance-tracker',
    storageBucket: 'geolocation-attendance-tracker.appspot.com',
    iosClientId: '244079569882-3fkl519ihhfj9aejr805trfhsa82lq40.apps.googleusercontent.com',
    iosBundleId: 'com.example.geolocationAttendanceTracker',
  );

}