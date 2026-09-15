import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:developer' as dev;

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:infolocate/animation/custom_fade_animation.dart';
import 'package:infolocate/common_models/failure_model.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:sizer/sizer.dart';

import 'app_colors.dart';
import 'app_ui.dart';
import 'json_safe_parser.dart';

/// Shared helpers: form validation, network error mapping, Hive/session load,
/// theme, status icons/colors, and video URL building.
class AppHelper {
  // --- Form validators (used on login / forgot-password screens) ---

  static String? uerNameValidator(String? name) {
    if (name!.isEmpty) {
      return LocaliazationKey.please_enter_username.tr();
    } else if (name.length < 3 || name.length > 32
        // ||
        // !Global.validCharacters.hasMatch(name)
        ) {
      return LocaliazationKey.please_enter_proper_username.tr();
    }
    return null;
  }

  // static bool handleScroll(
  //     {Future<dynamic>? callBackFunction,
  //     required ScrollNotification scrollInfo}) {
  //   if (scrollInfo is ScrollEndNotification) {
  //     if (scrollInfo.metrics.extentAfter == 0) {
  //       print('need to load items');
  //       callBackFunction;
  //     }
  //   }
  //   return false;
  // }

  static String? passwordValidator(String? password) {
    if (password!.isEmpty) {
      return LocaliazationKey.please_enter_password.tr();
    } else if (password.length < 3 || password.length > 32
        // ||
        // !Global.passwordRegExp.hasMatch(password)
        ) {
      return LocaliazationKey.please_enter_proper_password.tr();
    }
    return null;
  }

  // --- Network connectivity & Dio error mapping ---

  /// Quick DNS lookup check (not used by all screens; repos use Dio directly).
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  /// True when Dio failed before getting a valid HTTP response (timeouts, sockets, etc.).
  static bool isNetworkDioError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.badCertificate ||
        error.error is SocketException ||
        error.error is HttpException;
  }

  /// True for typical "device is offline / no DNS" socket messages (Android errno 7 etc.).
  static bool _isLikelyOffline(Object? err) {
    if (err is SocketException) {
      final msg = '${err.message} ${err.osError ?? ''}'.toLowerCase();
      return msg.contains('failed host lookup') ||
          msg.contains('name or service not known') ||
          msg.contains('no address associated with hostname') ||
          msg.contains('nodename nor servname provided') ||
          msg.contains('network is unreachable') ||
          msg.contains('network unreachable') ||
          msg.contains('socketexception: failed host lookup');
    }
    return false;
  }

  /// True when the device likely has network but the API host is down / refused.
  static bool _isServerUnreachable(Object? err) {
    if (err is SocketException) {
      if (_isLikelyOffline(err)) return false;
      final msg = (err.message).toLowerCase();
      return msg.contains('connection refused') ||
          msg.contains('connection reset') ||
          msg.contains('host is down') ||
          msg.contains('host is unreachable');
    }
    return false;
  }

  /// Maps API/network exceptions to user-friendly [Failure] messages shown in toasts/popups.
  ///
  /// Priority:
  /// 1. Re-throw existing [Failure] from API error payloads.
  /// 2. Network errors → [no_internet_connection] when offline/DNS fails,
  ///    [server_unreachable] when host refuses while online.
  /// 3. HTTP parse issues → [bad_response_format].
  /// 4. Everything else → [could_not_login] (avoids exposing raw exception text).
  static Failure failureFromError(Object error) {
    if (error is Failure) return error;

    if (error is DioException) {
      if (isNetworkDioError(error)) {
        // Internet off → Failed host lookup (errno 7) must show No Internet, not Server unreachable.
        if (_isLikelyOffline(error.error)) {
          return Failure(LocaliazationKey.no_internet_connection.tr());
        }
        if (_isServerUnreachable(error.error)) {
          return Failure(LocaliazationKey.server_unreachable.tr());
        }
        return Failure(LocaliazationKey.no_internet_connection.tr());
      }
      if (error.type == DioExceptionType.badResponse) {
        // Many backends return structured JSON errors for 4xx/5xx like:
        // { "data": { "status": 400, "error": [ { "message": "Authentication failed" } ] } }
        // Treat these as normal API failures and surface the message to the user.
        final data = error.response?.data;
        final extracted = _tryExtractApiMessage(data);
        if (extracted != null && extracted.trim().isNotEmpty) {
          return Failure(extracted);
        }
        return Failure(LocaliazationKey.bad_response_format.tr());
      }
      return Failure(LocaliazationKey.could_not_login.tr());
    }

    if (error is SocketException || error is HttpException) {
      if (_isLikelyOffline(error)) {
        return Failure(LocaliazationKey.no_internet_connection.tr());
      }
      if (_isServerUnreachable(error)) {
        return Failure(LocaliazationKey.server_unreachable.tr());
      }
      return Failure(LocaliazationKey.no_internet_connection.tr());
    }
    if (error is FormatException) {
      return Failure(LocaliazationKey.bad_response_format.tr());
    }

    return Failure(LocaliazationKey.could_not_login.tr());
  }

  /// Like [failureFromError], but verifies connectivity via DNS lookup when the
  /// error is network-related so offline devices always get "No Internet Connection".
  static Future<Failure> failureFromErrorAsync(Object error) async {
    if (error is Failure) return error;

    final isNetwork = (error is DioException && isNetworkDioError(error)) ||
        error is SocketException ||
        error is HttpException;

    if (isNetwork) {
      final online = await checkInternetConnection();
      if (!online) {
        return Failure(LocaliazationKey.no_internet_connection.tr());
      }
      return Failure(LocaliazationKey.server_unreachable.tr());
    }

    return failureFromError(error);
  }

  /// Attempts to extract an API error message from common response shapes.
  /// Returns null when extraction is not possible.
  static String? _tryExtractApiMessage(Object? data) {
    try {
      // Most of our APIs wrap payload inside "data".
      if (data is Map && data['data'] is Map) {
        final inner = data['data'];
        if (inner is Map) {
          // Preferred: data.error[0].message
          final err = inner['error'];
          if (err is List && err.isNotEmpty) {
            final first = err.first;
            if (first is Map && first['message'] != null) {
              return first['message'].toString();
            }
          }
          // Some APIs may use direct "message".
          if (inner['message'] != null) return inner['message'].toString();
        }
      }

      // Some APIs may respond without "data" wrapper.
      if (data is Map) {
        final err = data['error'];
        if (err is List && err.isNotEmpty) {
          final first = err.first;
          if (first is Map && first['message'] != null) {
            return first['message'].toString();
          }
        }
        if (data['message'] != null) return data['message'].toString();
      }
    } catch (_) {
      // Ignore parsing issues and fall back to generic messages.
    }
    return null;
  }

  // --- Dio request/response logging (debugging support) ---

  static int _apiTraceId = 0;

  /// Prints URL, request, and response without Flutter's debugPrint throttle.
  static void logApiTrace(String message) {
    debugPrintSynchronously(message, wrapWidth: 1024);
    print(message);
    dev.log(message, name: 'API');
  }

  /// Attaches a logger to [dio] that prints the full call:
  /// method, URL, query, request headers, request body, status, duration,
  /// response headers, and response body. Password fields are redacted.
  ///
  /// Safe to call multiple times. Tag is updated so reused Dio instances
  /// still show the correct API name.
  static void attachApiLogger(Dio dio, {String tag = 'API'}) {
    final existing = dio.interceptors.whereType<_ApiLogInterceptor>();
    if (existing.isNotEmpty) {
      existing.first.tag = tag;
      return;
    }
    dio.interceptors.add(_ApiLogInterceptor(tag: tag));
  }

  static Object? _redact(Object? data) {
    const sensitiveKeys = {
      'LoginPwd',
      'loginPwd',
      'password',
      'Password',
      'pwd',
      'Pwd',
    };

    if (data is Map) {
      return data.map((k, v) {
        final key = k?.toString();
        if (key != null && sensitiveKeys.contains(key)) {
          return MapEntry(k, '***');
        }
        return MapEntry(k, _redact(v));
      });
    }
    if (data is List) return data.map(_redact).toList();
    return data;
  }

  static String _prettyJson(Object? data) {
    if (data == null) return '(null)';
    try {
      Object? value = data;
      if (data is String) {
        final trimmed = data.trim();
        if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
          value = jsonDecode(trimmed);
        } else {
          return data;
        }
      }
      if (value is Map || value is List) {
        return const JsonEncoder.withIndent('  ').convert(value);
      }
    } catch (_) {}
    return data.toString();
  }

  static String _formatHeaders(Map<String, dynamic> headers) {
    if (headers.isEmpty) return '  (none)';
    final lines = <String>[];
    headers.forEach((key, value) {
      lines.add('  $key: $value');
    });
    return lines.join('\n');
  }

  static void _logBlock(String msg) {
    logApiTrace(msg);
  }

  static String _compactJson(Object? data) {
    if (data == null) return '(null)';
    try {
      return jsonEncode(_redact(data));
    } catch (_) {
      return data.toString();
    }
  }

  /// True when HTTP succeeded but the payload is a business failure
  /// (`status` 0 / non-1-or-200, or an explicit fail message).
  static bool isApiBusinessFailure(Object? response) {
    final map = JsonSafe.asMapOrNull(response);
    if (map == null) return false;
    final nested = JsonSafe.asMapOrNull(map['data'] ?? map['Data']);
    final status = JsonSafe.asIntOrNull(map['status'] ?? map['Status']) ??
        JsonSafe.asIntOrNull(nested?['status'] ?? nested?['Status']);
    if (status != null && status != 1 && status != 200) return true;
    final message = (JsonSafe.asStringOrNull(
              map['message'] ?? map['Message'] ?? map['remark'],
            ) ??
            JsonSafe.asStringOrNull(
              nested?['message'] ?? nested?['Message'] ?? nested?['remark'],
            ) ??
            '')
        .toLowerCase();
    if (message.contains('fail') ||
        message.contains('invalid') ||
        message.contains('unauthor')) {
      return true;
    }
    return false;
  }

  /// Trace helper for repositories: URL + request + response/error.
  static void logApiCall({
    required String tag,
    required String method,
    required String url,
    Object? request,
    int? status,
    Object? response,
    Object? error,
  }) {
    final businessFailure = error == null && isApiBusinessFailure(response);
    logApiTrace('API_CALL [$tag] $method $url');
    logApiTrace('API_CALL [$tag] REQUEST: ${_compactJson(request)}');
    if (error != null || businessFailure) {
      logApiTrace(
        'API_CALL [$tag] FAILURE: ${error ?? 'Business status is not success'}',
      );
      logApiTrace('API_CALL [$tag] FAILURE BODY: ${_compactJson(response)}');
    } else {
      logApiTrace('API_CALL [$tag] STATUS: $status');
      logApiTrace('API_CALL [$tag] RESPONSE: ${_compactJson(response)}');
    }
  }

  /// Dio 5.x+ SSL hook — [onHttpClientCreate] is deprecated and may not apply
  /// certificate bypass (seen with Dio 5.9). Prefer [configureDio] / [createDio].
  @Deprecated('Use configureDio / createDio — Dio 5.9 ignores onHttpClientCreate reliably')
  HttpClient? Function(HttpClient)? onHttpClientCreate = (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  /// Configures [dio] for native HTTPS: trusts staging/self-signed certs on :7009
  /// hosts and attaches API logging. Call once before each request (idempotent).
  ///
  /// Root cause of "API works in browser but Dio fails": browser trusts/ignores
  /// the cert, while Dio 5.9 needs [IOHttpClientAdapter.createHttpClient].
  static void configureDio(Dio dio, {String tag = 'API'}) {
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
    attachApiLogger(dio, tag: tag);
  }

  /// Creates a Dio instance already configured for this app's APIs.
  static Dio createDio({String tag = 'API'}) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    configureDio(dio, tag: tag);
    return dio;
  }

  // --- Theme ---

  void setCustomTheme({
    required BuildContext context,
    required Color? primaryColor,
    String? fontFamily,
    bool reset = false,
  }) async {
    // ignore: use_build_context_synchronously
    AdaptiveTheme.of(context).setTheme(
      light: AppStyles.appLightTheme(
          primaryColor: primaryColor,
          ctx: context,
          fontFamily: fontFamily ?? montserrat),
      dark: AppStyles.appDarkTheme(
          primaryColor: primaryColor,
          ctx: context,
          fontFamily: fontFamily ?? montserrat),
    );
    if (reset == true) {
      return; //* if we rest the theme then we dont want to store it in Hive
    }
    await Global.box.put(primaryColorKey, primaryColor.toIntColor());
  }

  // --- Vehicle / alert status helpers (dashboard, maps, cards) ---

  static int returnStatusId({required String status}) {
    int statusId = 6;
    switch (status) {
      case "Idle":
        statusId = 1;
        break;
      case "Stopped":
        statusId = 2;
        break;
      case "Moving":
        statusId = 3;
        break;
      case "Inactive":
        statusId = 4;
        break;
      case "Operation":
        statusId = 5;
        break;
      case "All vehicles":
        statusId = 6;
        break;
      case "Working":
        statusId = 7;
        break;
      default:
        statusId = 6;
    }
    return statusId;
  }

  static String returnAlertStatus({required String? alertStatus}) {
    String newAlertStatus = "";
    switch (alertStatus) {
      case "Over Speed":
        newAlertStatus = "Over Speed";
        break;
      case "yaccel end":
        newAlertStatus = "Sharp turn";
        break;
      case "xaccel end":
        newAlertStatus = "Harsh brake";
        break;
      case "tilt end":
        newAlertStatus = "Tilt end";
        break;
      default:
        newAlertStatus = alertStatus?.trim().isNotEmpty == true
            ? alertStatus!
            : LocaliazationKey.alert_type.tr();
    }
    return newAlertStatus;
  }

  static double returnPercentage(
      {required int value, required int totalcount}) {
    double percentage = (value / totalcount) * 100;
    return percentage;
  }

  static Future<Color?> showColorPicker(
      {required BuildContext context, Color? pickerColor}) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomFadeScaleTransition(
            duration: const Duration(milliseconds: 400),
            child: AlertDialog(
              title: Text(LocaliazationKey.pick_a_color.tr()),
              content: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return BlockPicker(
                      availableColors: const [
                        primeryColorConstant,
                        Colors.red,
                        Colors.blue,
                        Colors.pink,
                        Colors.green,
                        Colors.deepPurpleAccent,
                        Colors.orange,
                        Colors.cyan
                      ],
                      layoutBuilder: (context, colors, child) {
                        return Wrap(
                          children: [for (Color color in colors) child(color)],
                        );
                      },
                      itemBuilder: defaultItemBuilder,
                      pickerColor: pickerColor ??
                          Theme.of(context)
                              .colorScheme
                              .onPrimary, //default color
                      onColorChanged: (Color color) {
                        pickerColor = color;
                        print('inside dailog color--> $pickerColor');
                      },
                    );
                  },
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text(LocaliazationKey.apply.tr()),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(pickerColor); //dismiss the color picker
                  },
                ),
              ],
              actionsAlignment: MainAxisAlignment.center,
            ),
          );
        });
  }

  // --- Hive: reload [Global] fields after login/logout/language change ---

  static Future<void> getHiveBoxData() async {
    Global.box = await Hive.openBox(myBox);
    Global.savedLanguageCode = Global.box.get(languageCodeKey);
    Global.savedContryCode = Global.box.get(countryCodeKey);
    Global.savedClientAuthData = Global.box.get(clientAuthBoxKey);
    Global.savedUserAuthData = Global.box.get(userAuthBoxKey);
    Global.savedPrimeryColor = Global.box.get(primaryColorKey) != null
        ? Color(Global.box.get(primaryColorKey))
        : null;
    Global.savedVehicleStatusCardTypeId =
        Global.box.get(vehicleStatusCardTypeIdKey);
    Global.savedAlertStatusCardTypeId =
        Global.box.get(alertStatusCardTypeIdKey);
    Global.locationPermission = Global.box.get(locationPermission) ?? false;
    // Global.cardTypeSetting = Global.box.get(cardTypeSettingKey);
  }

  // --- Localization assets: icons, flags, alert titles ---

  static returnIcons({required String title}) {
    String path = 'assets/icons/default_alert.svg';
    switch (title) {
      case 'Idle':
        path = 'assets/icons/idle.svg';
        break;
      case 'Stopped':
        path = 'assets/icons/stopped.svg';
        break;
      case 'Moving':
        path = 'assets/icons/moving.svg';
        break;
      case 'Inactive':
        path = 'assets/icons/inactive.svg';
        break;
      case 'Working':
        path = 'assets/icons/working.svg';
        break;
      case 'Operational':
        path = 'assets/icons/working.svg';
        break;
      case 'Operation':
        path = 'assets/icons/working.svg';
        break;
      case 'Over Speed':
      case 'OverSpeed':
      case 'Over Speed - Hwy':
      case 'Over Speed - NonHwy':
        path = "assets/icons/overspeed.svg";
        break;
      case 'Stop':
        path = 'assets/icons/stopped.svg';
        break;
      case 'tilt end':
        path = 'assets/icons/tilt_end.svg';
        break;
      case 'Tilt end':
        path = 'assets/icons/tilt_end.svg';
        break;
      case "Sharp turn":
        path = 'assets/icons/sharp_turn.svg';
        break;
      case "Harsh brake":
        path = 'assets/icons/harsh_break.svg';
        break;
      default:
        path = 'assets/icons/default_alert.svg';
    }
    return path;
  }

  static returnLanguageTranslation({required String title}) {
    String subtitle = title;
    switch (title) {
      case 'English':
        subtitle = 'english';
        break;
      case 'Hindi':
        subtitle = 'हिंदी';
        break;
      case 'Kannada':
        subtitle = 'ಕನ್ನಡ';
        break;
      case 'Tamil':
        subtitle = 'தமிழ்';
        break;
      case 'Telugu':
        subtitle = 'తెలుగు';
        break;
      case 'Urdu':
        subtitle = 'اردو';
        break;
      case 'Japanese':
        subtitle = '日本語';
        break;
      case 'English (United States)':
        subtitle = 'english';
        break;
    }
    return subtitle;
  }

  static returnCountryFlag({required String title}) {
    String path = 'assets/images/ic_lang_eng.png';
    switch (title) {
      case 'India':
        path = 'assets/images/ic_lang_ind.png';
        break;
      case 'Japan':
        path = 'assets/images/ic_lang_jap.png';
        break;
      case 'United States':
        path = 'assets/images/ic_lang_eng.png';
        break;
      case 'Bangladesh':
        path = 'assets/images/ic_lang_bang.png';
        break;
      default:
        path = 'assets/images/ic_lang_eng.png';
    }
    return path;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: 10.h.toInt());
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static imagePathByStatusName({required String? statusName}) {
    String path = 'assets/icons/idle.svg';
    if (statusName == null) return 'assets/images/inactive_marker.png';

    switch (statusName) {
      case 'Idle':
        path = 'assets/images/idle_marker.png';
        break;
      case 'Stopped':
        path = 'assets/images/stopped_marker.png';
        break;
      case 'Moving':
        path = 'assets/images/moving_marker.png';
        break;
      case 'Inactive':
        path = 'assets/images/inactive_marker.png';
        break;
      case 'Working':
        path = 'assets/images/working_marker.png';
        break;
      case 'Operational':
        path = 'assets/images/working_marker.png';
        break;
      case 'Source':
        path = 'assets/images/source_marker.png';
        break;
      case 'Destination':
        path = 'assets/images/destination_marker.png';
        break;
      case 'Over Speed':
        path = 'assets/images/stopped_marker.png';
        break;
      case 'Tilt end':
        path = 'assets/images/stopped_marker.png';
        break;
      case "Sharp turn":
        path = 'assets/images/stopped_marker.png';
        break;
      case "Harsh brake":
        path = 'assets/images/stopped_marker.png';
        break;
      default:
        path = 'assets/images/inactive_marker.png';
    }
    return path;
  }

  static List<String?> decodeVideoPath(
      {required String? urlPath, required String unitNo}) {
    if (urlPath == null || urlPath.trim().isEmpty) return [];

    final urlList = <String?>[];
    const baseUrl = kVideDecodeUrl;
    const token = kToken;

    for (final data in urlPath.split(',')) {
      final parts = data.split('|');
      if (parts.length < 2) continue;
      final channel = parts[0].trim();
      final encoded = parts[1].trim();
      if (channel.isEmpty || encoded.isEmpty) continue;
      urlList.add(
        "$baseUrl?token=$token&deviceId=$unitNo&chs=$channel&fpath=$encoded\n",
      );
    }

    return urlList;
  }

  static returnIconColor({required String? title}) {
    Color color = Colors.blue;
    switch ((title ?? '').toLowerCase().trim()) {
      case 'idle':
        color = const Color(0xffEE9229);
        break;
      case 'stopped':
        color = const Color(0xffed220d);
        break;
      case 'moving':
        color = const Color(0xff289348);
        break;
      case 'working':
      case 'operational':
      case 'operation':
        color = const Color(0xff6c4bf1);
        break;
      case 'inactive':
        color = const Color(0xff929292);
        break;
      default:
        color = AppUi.accent;
    }
    return color;
  }

  static double? getMarkerColorByStatus({required String? status}) {
    double? color = BitmapDescriptor.hueRed;
    switch (status) {
      case 'Idle':
        color = BitmapDescriptor.hueOrange;
        break;
      case 'Stopped':
        color = BitmapDescriptor.hueRed;
        break;
      case 'Moving':
        color = BitmapDescriptor.hueGreen;
        break;
      case 'Working':
        color = BitmapDescriptor.hueViolet;
        break;
      case 'Operational':
        color = BitmapDescriptor.hueAzure;
        break;
      case 'Inactive':
        color = BitmapDescriptor.hueCyan;
        break;
      default:
        color = BitmapDescriptor.hueRed;
    }
    return color;
  }

  static String getSpeedometerIcon(int speed) {
    String imagePath = "assets/icons/new_icons/green.svg";

    if (speed >= 0 && speed <= 60) {
      imagePath = "assets/icons/new_icons/green.svg";
    } else if (speed > 60 && speed <= 80) {
      imagePath = "assets/icons/new_icons/yellow.svg";
    } else if (speed > 80 && speed <= 90) {
      imagePath = "assets/icons/new_icons/orange.svg";
    } else {
      imagePath = "assets/icons/new_icons/red.svg";
    }

    return imagePath;
  }

  static Color getSpeedometerColor(int speed) {
    Color color = AppColors.primeryColor;
    if (speed >= 0 && speed <= 60) {
      color = Colors.green;
    } else if (speed > 60 && speed <= 80) {
      color = Colors.yellow;
    } else if (speed > 80 && speed <= 90) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return color;
  }

  static String? getCustomTimeFormat(
      {required DateTime? dateTime, String? defaultTime}) {
    String? resultDateTime;
    try {
      var dateList = dateTime!.toLocal().toString().split(" ");
      var dateValue = dateList.first;
      var timeValue = dateList[1];
      var timeList = timeValue.split(':');
      var res = double.tryParse(timeList.last)!.toInt();
      var resEdited = res.toString().length == 1 ? '0$res' : res.toString();
      // log(res.toString());
      timeList.removeAt(timeList.length - 1);
      timeList.add(resEdited);
      dateList.removeAt(dateList.length - 1);
      dateList.add(timeList.join(":"));
      dateValue = dateList.first;
      timeValue = dateList[1];
      resultDateTime = "$dateValue ${defaultTime ?? timeValue}";
      debugPrint(resultDateTime);
      return resultDateTime;
    } catch (err) {
      debugPrint(err.toString());
    }
    return resultDateTime = dateTime!.toLocal().toString();
  }

  static String returnJapaneseText({required String? title}) {
    String newtitle = title.toString();
    switch (title) {
      case "Over Speed":
        newtitle = LocaliazationKey.over_speed.tr();
        break;
      case "Sharp turn":
        newtitle = LocaliazationKey.sharp_turn.tr();
        break;
      case "Harsh brake":
        newtitle = LocaliazationKey.harsh_break.tr();
        break;
      case "tilt end":
        newtitle = LocaliazationKey.tilt_end.tr();
        break;
      case "Tilt end":
        newtitle = LocaliazationKey.tilt_end.tr();
        break;
      case "Idle":
        newtitle = LocaliazationKey.idle.tr();
        break;
      case "Moving":
        newtitle = LocaliazationKey.moving.tr();
        break;
      case "Stopped":
        newtitle = LocaliazationKey.stopped.tr();
        break;
      case "Inactive":
        newtitle = LocaliazationKey.inactive.tr();
        break;
      case "Working":
        newtitle = LocaliazationKey.operational.tr();
        break;
      case "Operational":
        newtitle = LocaliazationKey.operational.tr();
        break;
      case "Operation":
        newtitle = LocaliazationKey.operational.tr();
        break;
      // New Alert Type
      case "User Request":
        newtitle = LocaliazationKey.alert_type.tr();
        break;
      case "Video Lost":
        newtitle = LocaliazationKey.video_lost.tr();
        break;
      case "Motion Detection":
        newtitle = LocaliazationKey.motion_detection.tr();
        break;
      case "Harsh Acceleration":
        newtitle = LocaliazationKey.harsh_acceleration.tr();
        break;
      case "Alarm Input triggered--?":
        newtitle = LocaliazationKey.alarm_input_triggered.tr();
        break;
      case "Alarm of emergency":
        newtitle = LocaliazationKey.emergency_alarm.tr();
        break;
      case "Alarm of low speed":
        newtitle = LocaliazationKey.low_speed_alarm.tr();
        break;
      case "Video Overshadowed--?":
        newtitle = LocaliazationKey.video_overshadowed.tr();
        break;
      case "Alarm of low temperature":
        newtitle = LocaliazationKey.low_temperature_alarm.tr();
        break;
      case "Alarm of humidity":
        newtitle = LocaliazationKey.humidity_alarm.tr();
        break;
      case "Geofence Entry":
        newtitle = LocaliazationKey.geofence_entry.tr();
        break;
      case "Geofence Exit":
        newtitle = LocaliazationKey.geofence_exit.tr();
        break;
      case "Electronic fence ー？":
        newtitle = LocaliazationKey.electronic_fence.tr();
        break;
      case "Electronic route":
        newtitle = LocaliazationKey.electronic_route.tr();
        break;
      case "Exceptionof open or close door":
        newtitle = LocaliazationKey.exception_open_close_door.tr();
        break;
      case "Storage abnormal":
        newtitle = LocaliazationKey.storage_abnormal.tr();
        break;
      case "Fatigue driving":
        newtitle = LocaliazationKey.fatigue_driving.tr();
        break;
      case "Exceptional Volume of Gas":
        newtitle = LocaliazationKey.exceptional_gas_volume.tr();
        break;
      case "Illegal ignition":
        newtitle = LocaliazationKey.illegal_ignition.tr();
        break;
      case "Location module abnormal":
        newtitle = LocaliazationKey.location_module_abnormal.tr();
        break;
      case "Front panel open":
        newtitle = LocaliazationKey.front_panel_open.tr();
        break;
      case "RFID tagged":
        newtitle = LocaliazationKey.rfid_tagged.tr();
        break;
      case "IBUTTON":
        newtitle = LocaliazationKey.ibutton.tr();
        break;
      case "Rapid acceleration":
        newtitle = LocaliazationKey.rapid_acceleration.tr();
        break;
      case "Rapid deceleration":
        newtitle = LocaliazationKey.rapid_deceleration.tr();
        break;
      case "Low speed pre-alarm":
        newtitle = LocaliazationKey.low_speed_pre_alarm.tr();
        break;
      case "High speed pre-alarm":
        newtitle = LocaliazationKey.high_speed_pre_alarm.tr();
        break;
      case "X-Acceleration End":
        newtitle = LocaliazationKey.x_accel_end.tr();
        break;
      case "DMS/ADAS Alarm(Active safety alarm)":
        newtitle = LocaliazationKey.dms_adas_alarm.tr();
        break;
      case "Forward collision warning":
        newtitle = LocaliazationKey.forward_collision_warning.tr();
        break;
      case "Lane departure warning":
        newtitle = LocaliazationKey.lane_departure_warning.tr();
        break;
      case "Front vehicle distance is too close warning":
        newtitle = LocaliazationKey.front_vehicle_distance_warning.tr();
        break;
      case "Pedestrian collision warning":
        newtitle = LocaliazationKey.pedestrian_collision_warning.tr();
        break;
      case "Frequent lane change alarm":
        newtitle = LocaliazationKey.frequent_lane_change_alarm.tr();
        break;
      case "Road sign violation alarm":
        newtitle = LocaliazationKey.road_sign_violation_alarm.tr();
        break;
      case "Road sign recognition incidentー?":
        newtitle = LocaliazationKey.road_sign_recognition_incident.tr();
        break;
      case "FCW Forward relative velocity collision":
        newtitle =
            LocaliazationKey.fcw_forward_relative_velocity_collision.tr();
        break;
      case "HMW Forward absolute velocity collision":
        newtitle =
            LocaliazationKey.hmw_forward_absolute_velocity_collision.tr();
        break;
      case "LDW_LLeftlanedeparture":
        newtitle = LocaliazationKey.ldw_left_lane_departure.tr();
        break;
      case "LDW_RRightlanedeparture":
        newtitle = LocaliazationKey.ldw_right_lane_departure.tr();
        break;
      case "VB Low-speedforwardcollisionalarm":
        newtitle = LocaliazationKey.vb_low_speed_forward_collision_alarm.tr();
        break;
      case "Fatiguedrivingalarm":
        newtitle = LocaliazationKey.fatigue_driving_alarm.tr();
        break;
      case "Callingalarm":
        newtitle = LocaliazationKey.calling_alarm.tr();
        break;
      case "Smoking alarm":
        newtitle = LocaliazationKey.smoking_alarm.tr();
        break;
      case "Distracteddrivingalarm":
        newtitle = LocaliazationKey.distracted_driving_alarm.tr();
        break;
      case "Driverabnormalalarm":
        newtitle = LocaliazationKey.driver_abnormal_alarm.tr();
        break;
      case "Driverchangeevent":
        newtitle = LocaliazationKey.driver_change_event.tr();
        break;
      case "Eyes closed":
        newtitle = LocaliazationKey.eyes_closed.tr();
        break;
      case "Yawning":
        newtitle = LocaliazationKey.yawning.tr();
        break;
      case "Cameracoveralarm":
        newtitle = LocaliazationKey.camera_cover_alarm.tr();
        break;
      case "Glance right and left":
        newtitle = LocaliazationKey.glance_right_and_left.tr();
        break;
      case "Not wearing a seatbelt":
        newtitle = LocaliazationKey.not_wearing_seatbelt.tr();
        break;
      case "No driver":
        newtitle = LocaliazationKey.no_driver.tr();
        break;
      case "Drinking water":
        newtitle = LocaliazationKey.drinking_water.tr();
        break;
      case "Driver changing":
        newtitle = LocaliazationKey.driver_changing.tr();
        break;
      case "Driver erturns":
        newtitle = LocaliazationKey.driver_returns.tr();
        break;
      case "Infrared sunglasses":
        newtitle = LocaliazationKey.infrared_sunglasses.tr();
        break;
      case "Driver authentication succeeded":
        newtitle = LocaliazationKey.driver_authentication_succeeded.tr();
        break;
      case "Driver authentication failed":
        newtitle = LocaliazationKey.driver_authentication_failed.tr();
        break;
      case "No face detected":
        newtitle = LocaliazationKey.no_face_detected.tr();
        break;
      case "Alarm of high temperature":
        newtitle = LocaliazationKey.high_temperature_alarm.tr();
        break;
      case "Park overtime":
        newtitle = LocaliazationKey.park_overtime.tr();
        break;
      case "Voltage alarm":
        newtitle = LocaliazationKey.voltage_alarm.tr();
        break;
      case "Population statistics":
        newtitle = LocaliazationKey.population_statistics.tr();
        break;
      case "Y-Acceleration End":
        newtitle = LocaliazationKey.y_accel_end.tr();
        break;
      case "Z-Acceleration End":
        newtitle = LocaliazationKey.z_accel_end.tr();
        break;
      case "impact end":
        newtitle = LocaliazationKey.impact_end.tr();
        break;
      default:
        newtitle = title.toString();
    }
    return newtitle;
  }
}

class _ApiLogInterceptor extends Interceptor {
  String tag;
  static const _startKey = 'apiLogStartMs';
  static const _idKey = 'apiLogId';
  _ApiLogInterceptor({required this.tag});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final id = ++AppHelper._apiTraceId;
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    options.extra[_idKey] = id;
    final fullUrl = options.uri.toString();
    final query = options.queryParameters.isEmpty
        ? '(none)'
        : AppHelper._prettyJson(options.queryParameters);
    final body = options.data == null
        ? '(empty)'
        : AppHelper._prettyJson(AppHelper._redact(options.data));
    AppHelper.logApiTrace(
      'API_TRACE #$id REQUEST [$tag] ${options.method} $fullUrl',
    );
    AppHelper.logApiTrace(
      'API_TRACE #$id REQUEST BODY [$tag]: ${AppHelper._compactJson(options.data)}',
    );
    AppHelper._logBlock('''
========== API REQUEST #$id [$tag] ==========
METHOD : ${options.method}
URL    : $fullUrl
QUERY  : $query
CONTENT-TYPE : ${options.contentType}
REQUEST HEADERS:
${AppHelper._formatHeaders(options.headers)}
REQUEST BODY:
$body
========================================''');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final started = response.requestOptions.extra[_startKey];
    final id = response.requestOptions.extra[_idKey];
    final duration = started is int
        ? '${DateTime.now().millisecondsSinceEpoch - started}ms'
        : '(unknown)';
    final fullUrl = response.requestOptions.uri.toString();
    final businessFailure = AppHelper.isApiBusinessFailure(response.data);
    final label = businessFailure ? 'FAILURE' : 'RESPONSE';
    AppHelper.logApiTrace(
      'API_TRACE #$id $label [$tag] ${response.statusCode} $fullUrl ($duration)',
    );
    AppHelper.logApiTrace(
      'API_TRACE #$id $label BODY [$tag]: ${AppHelper._compactJson(response.data)}',
    );
    AppHelper._logBlock('''
========== API $label #$id [$tag] ==========
STATUS   : ${response.statusCode} ${response.statusMessage ?? ''}
URL      : $fullUrl
DURATION : $duration
RESPONSE HEADERS:
${AppHelper._formatHeaders(Map<String, dynamic>.from(response.headers.map))}
RESPONSE BODY:
${AppHelper._prettyJson(response.data)}
=========================================''');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final started = err.requestOptions.extra[_startKey];
    final id = err.requestOptions.extra[_idKey];
    final duration = started is int
        ? '${DateTime.now().millisecondsSinceEpoch - started}ms'
        : '(unknown)';
    final responseHeaders = err.response?.headers.map;
    final fullUrl = err.requestOptions.uri.toString();
    AppHelper.logApiTrace(
      'API_TRACE #$id ERROR [$tag] ${err.response?.statusCode ?? err.type} $fullUrl',
    );
    AppHelper.logApiTrace(
      'API_TRACE #$id REQUEST BODY [$tag]: ${AppHelper._compactJson(err.requestOptions.data)}',
    );
    AppHelper.logApiTrace(
      'API_TRACE #$id RESPONSE BODY [$tag]: ${AppHelper._compactJson(err.response?.data)}',
    );
    AppHelper._logBlock('''
========== API ERROR #$id [$tag] ==========
TYPE     : ${err.type}
MESSAGE  : ${err.message}
URL      : $fullUrl
METHOD   : ${err.requestOptions.method}
DURATION : $duration
STATUS   : ${err.response?.statusCode} ${err.response?.statusMessage ?? ''}
REQUEST HEADERS:
${AppHelper._formatHeaders(err.requestOptions.headers)}
REQUEST BODY:
${err.requestOptions.data == null ? '(empty)' : AppHelper._prettyJson(AppHelper._redact(err.requestOptions.data))}
RESPONSE HEADERS:
${responseHeaders == null ? '  (none)' : AppHelper._formatHeaders(Map<String, dynamic>.from(responseHeaders))}
RESPONSE BODY:
${err.response?.data == null ? '(none)' : AppHelper._prettyJson(err.response!.data)}
ERROR    : ${err.error}
======================================''');
    handler.next(err);
  }
}

Widget defaultItemBuilder(
    Color color, bool isCurrentColor, void Function() changeColor) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      color: color,
      // margin: const EdgeInsets.all(7),
      height: 5.h,
      width: 5.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          // borderRadius: BorderRadius.circular(50),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 210),
            opacity: isCurrentColor ? 1 : 0,
            child: Icon(Icons.done,
                color: useWhiteForeground(color) ? Colors.white : Colors.black),
          ),
        ),
      ),
    ),
  );
}

bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
  int v = sqrt(pow(backgroundColor.red, 2) * 0.299 +
          pow(backgroundColor.green, 2) * 0.587 +
          pow(backgroundColor.blue, 2) * 0.114)
      .round();
  return v < 130 + bias ? true : false;
}

class VideoModel {
  final String? video;
  final String? channel;
  VideoModel({this.video, this.channel});
}
