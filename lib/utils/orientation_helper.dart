import 'package:flutter/services.dart';

/// Orientation helpers that work on iPhone and iPad.
///
/// On iPad, locking to a single orientation is unreliable unless the app
/// opts out of multitasking ([UIRequiresFullScreen] in Info.plist) and both
/// landscape sides are requested together.
class OrientationHelper {
  OrientationHelper._();

  static const portrait = <DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ];

  static const landscape = <DeviceOrientation>[
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static Future<void> lockPortrait() {
    return SystemChrome.setPreferredOrientations(portrait);
  }

  static Future<void> lockLandscape() {
    return SystemChrome.setPreferredOrientations(landscape);
  }

  static Future<void> toggle(bool currentlyLandscape) {
    return currentlyLandscape ? lockPortrait() : lockLandscape();
  }
}
