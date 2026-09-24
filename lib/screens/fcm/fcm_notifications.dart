import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:infolocate/app.dart';
import 'package:infolocate/screens/alerts/view/alert_screen.dart';
import 'package:infolocate/utils/app_globals.dart';

const String kFcmChannelId = 'infolocate_alerts';
const String kFcmChannelName = 'InfoLocate Alerts';

/// Shows FCM messages in the tray (foreground / data-only) and handles taps.
class FcmNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static bool _listening = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    kFcmChannelId,
    kFcmChannelName,
    description: 'Fleet alerts and push notifications',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> initialize() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@drawable/ic_infolocate');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        _openAlerts(payload: response.payload);
      },
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();
    _ready = true;
  }

  static void listen() {
    if (_listening) return;
    _listening = true;
    FirebaseMessaging.onMessage.listen((message) {
      _logMessage('foreground', message);
      show(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _logMessage('opened', message);
      _openAlerts(payload: jsonEncode(message.data));
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) return;
      _logMessage('terminated-tap', message);
      _openAlerts(payload: jsonEncode(message.data));
    });
  }

  static Future<void> show(RemoteMessage message) async {
    try {
      await initialize();
      final title = message.notification?.title ??
          message.data['title'] ??
          message.data['Title'] ??
          'InfoLocate';
      final body = message.notification?.body ??
          message.data['body'] ??
          message.data['message'] ??
          message.data['Message'] ??
          '';
      await _plugin.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_infolocate',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      log('FCM: failed to show notification: $e');
      print('FCM: failed to show notification: $e');
    }
  }

  static void _logMessage(String source, RemoteMessage message) {
    final text =
        'FCM $source id=${message.messageId} title=${message.notification?.title} '
        'body=${message.notification?.body} data=${message.data}';
    log(text);
    print(text);
  }

  static void _openAlerts({String? payload}) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    if (Global.savedUserAuthData == null) return;
    nav.pushNamed(AlertDashboardScreen.routeName);
  }
}
