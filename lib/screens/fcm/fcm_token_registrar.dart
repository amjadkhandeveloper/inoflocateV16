import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:infolocate/screens/fcm/fcm_notifications.dart';
import 'package:infolocate/screens/fcm/model/fcm_token_request_model.dart';
import 'package:infolocate/screens/fcm/repository/fcm_token_repo.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_globals.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  print(
    'FCM background id=${message.messageId} title=${message.notification?.title} '
    'body=${message.notification?.body} data=${message.data}',
  );
  // System already shows a tray item when `notification` is set. Show our own
  // only for data-only payloads so the user still sees something.
  if (message.notification == null) {
    await FcmNotifications.show(message);
  }
}

/// Gets an FCM token (once Firebase JSON is present) and POSTs [RegisterToken].
class FcmTokenRegistrar {
  static bool _initialized = false;
  static bool _listeningRefresh = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (e) {
      log('FCM: Firebase not ready. Add google-services.json / GoogleService-Info.plist. $e');
      print('FCM: Firebase not ready. $e');
      return;
    }
    await _logCurrentToken();
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await FcmNotifications.initialize();
    FcmNotifications.listen();
    if (_listeningRefresh) return;
    _listeningRefresh = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _printToken(token, source: 'refresh');
      registerCurrentToken(token: token);
    });
  }

  static Future<void> _logCurrentToken() async {
    await _readToken(source: 'getToken');
  }

  static const int _maxTokenAttempts = 8;

  /// On iOS, FCM token is empty until APNs has issued a device token.
  static Future<String?> _readToken({
    required String source,
    int attempt = 0,
  }) async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (Platform.isIOS) {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          _scheduleTokenRetry(source: source, attempt: attempt);
          return null;
        }
      }
      final token = await messaging.getToken();
      _printToken(token, source: source);
      return token;
    } catch (e) {
      log('FCM: could not read token: $e');
      print('FCM: could not read token (attempt ${attempt + 1}): $e');
      _scheduleTokenRetry(source: source, attempt: attempt);
      return null;
    }
  }

  static void _scheduleTokenRetry({
    required String source,
    required int attempt,
  }) {
    if (attempt >= _maxTokenAttempts) {
      log('FCM: APNS token not ready; waiting for onTokenRefresh');
      print('FCM: APNS token not ready; waiting for onTokenRefresh');
      return;
    }
    final delaySeconds = attempt < 3 ? 1 : 2;
    Future<void>.delayed(Duration(seconds: delaySeconds), () async {
      final token = await _readToken(source: source, attempt: attempt + 1);
      if (source == 'register' && token != null && token.isNotEmpty) {
        await registerCurrentToken(token: token);
      }
    });
  }

  static void _printToken(String? token, {required String source}) {
    if (token == null || token.isEmpty) {
      log('FCM token ($source): <empty>');
      print('FCM token ($source): <empty>');
      return;
    }
    log('FCM token ($source): $token');
    print('======== FCM TOKEN ($source) ========');
    print(token);
    print('=====================================');
  }

  static Future<void> registerAfterLogin() async {
    await initialize();
    await registerCurrentToken();
  }

  static Future<void> registerCurrentToken({String? token}) async {
    if (!Global.isSequelClient) return;
    final clientId = Global.savedUserAuthData?.clientid ??
        Global.savedClientAuthData?.clientId;
    final userId = Global.savedUserAuthData?.userid;
    if (clientId == null || clientId <= 0 || userId == null || userId <= 0) {
      return;
    }

    String? fcmToken = token;
    if (fcmToken == null && _initialized) {
      fcmToken = await _readToken(source: 'register');
    }
    if (fcmToken == null || fcmToken.isEmpty) return;
    _printToken(fcmToken, source: 'register');

    try {
      await FcmTokenService().registerToken(
        request: FcmTokenRequestModel(
          clientId: clientId,
          userId: userId,
          fcmToken: fcmToken,
          deviceId: _deviceId(),
          platform: Platform.isIOS ? 'ios' : 'android',
          appVersion: kAppVersion.toString(),
        ),
      );
    } catch (e) {
      log('FCM: RegisterToken failed: $e');
    }
  }

  static String _deviceId() {
    final existing = Global.box.get(fcmDeviceIdKey);
    if (existing is String && existing.isNotEmpty) return existing;
    final id = _newDeviceId();
    Global.box.put(fcmDeviceIdKey, id);
    return id;
  }

  static String _newDeviceId() {
    final rand = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
