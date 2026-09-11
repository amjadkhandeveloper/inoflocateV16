import 'dart:convert';

/// Safe JSON type conversion for `fromJson`.
///
/// APIs sometimes send `{}`, `[]`, or `""` instead of the expected type.
/// Mix this into a model and use [asInt], [asDouble], [asString], [asBool],
/// [asMap], [asList] so parsing returns the same value when it is valid,
/// otherwise a typed empty default (never throws).
///
/// ```dart
/// class MyModel with JsonSafeParser {
///   MyModel.fromJson(Map<String, dynamic> json) {
///     status = asInt(json['status']); // 0 when {}, [], ""
///     name = asString(json['name']);  // "" when {}, [], null
///     extra = asMap(json['extra']);   // {} when [], ""
///     items = asList(json['items']);  // [] when {}, ""
///   }
/// }
/// ```
///
/// Call [JsonSafe] from top-level helpers without mixing the class in.
mixin JsonSafeParser {
  int asInt(dynamic value, {int fallback = 0}) =>
      JsonSafe.asInt(value, fallback: fallback);

  int? asIntOrNull(dynamic value) => JsonSafe.asIntOrNull(value);

  double asDouble(dynamic value, {double fallback = 0}) =>
      JsonSafe.asDouble(value, fallback: fallback);

  double? asDoubleOrNull(dynamic value) => JsonSafe.asDoubleOrNull(value);

  String asString(dynamic value, {String fallback = ''}) =>
      JsonSafe.asString(value, fallback: fallback);

  String? asStringOrNull(dynamic value) => JsonSafe.asStringOrNull(value);

  bool asBool(dynamic value, {bool fallback = false}) =>
      JsonSafe.asBool(value, fallback: fallback);

  bool? asBoolOrNull(dynamic value) => JsonSafe.asBoolOrNull(value);

  Map<String, dynamic> asMap(dynamic value) => JsonSafe.asMap(value);

  Map<String, dynamic>? asMapOrNull(dynamic value) =>
      JsonSafe.asMapOrNull(value);

  List<dynamic> asList(dynamic value) => JsonSafe.asList(value);

  List<dynamic>? asListOrNull(dynamic value) => JsonSafe.asListOrNull(value);

  List<Map<String, dynamic>> asListOfMaps(dynamic value) =>
      JsonSafe.asListOfMaps(value);

  dynamic firstValue(Map json, List<String> keys) =>
      JsonSafe.firstValue(json, keys);

  int asIntFrom(Map json, List<String> keys, {int fallback = 0}) =>
      JsonSafe.asInt(JsonSafe.firstValue(json, keys), fallback: fallback);

  double asDoubleFrom(Map json, List<String> keys, {double fallback = 0}) =>
      JsonSafe.asDouble(JsonSafe.firstValue(json, keys), fallback: fallback);

  String asStringFrom(Map json, List<String> keys, {String fallback = ''}) =>
      JsonSafe.asString(JsonSafe.firstValue(json, keys), fallback: fallback);

  bool asBoolFrom(Map json, List<String> keys, {bool fallback = false}) =>
      JsonSafe.asBool(JsonSafe.firstValue(json, keys), fallback: fallback);

  Map<String, dynamic> asMapFrom(Map json, List<String> keys) =>
      JsonSafe.asMap(JsonSafe.firstValue(json, keys));

  List<dynamic> asListFrom(Map json, List<String> keys) =>
      JsonSafe.asList(JsonSafe.firstValue(json, keys));
}

/// Static version of [JsonSafeParser] for use outside a mixed-in class.
class JsonSafe {
  JsonSafe._();

  static int asInt(dynamic value, {int fallback = 0}) {
    return asIntOrNull(value) ?? fallback;
  }

  static int? asIntOrNull(dynamic value) {
    if (_isEmpty(value) || value is Map || value is Iterable) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    if (value is String) return int.tryParse(value.trim());
    return int.tryParse(value.toString().trim());
  }

  static double asDouble(dynamic value, {double fallback = 0}) {
    return asDoubleOrNull(value) ?? fallback;
  }

  static double? asDoubleOrNull(dynamic value) {
    if (_isEmpty(value) || value is Map || value is Iterable) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is bool) return value ? 1.0 : 0.0;
    if (value is String) return double.tryParse(value.trim());
    return double.tryParse(value.toString().trim());
  }

  static String asString(dynamic value, {String fallback = ''}) {
    return asStringOrNull(value) ?? fallback;
  }

  static String? asStringOrNull(dynamic value) {
    if (_isEmpty(value) || value is Map || value is Iterable) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return value.toString();
  }

  static bool asBool(dynamic value, {bool fallback = false}) {
    return asBoolOrNull(value) ?? fallback;
  }

  static bool? asBoolOrNull(dynamic value) {
    if (_isEmpty(value) || value is Map || value is Iterable) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final text = value.trim().toLowerCase();
      if (text == 'true' || text == '1' || text == 'yes' || text == 'on') {
        return true;
      }
      if (text == 'false' || text == '0' || text == 'no' || text == 'off') {
        return false;
      }
    }
    return null;
  }

  static Map<String, dynamic> asMap(dynamic value) {
    return asMapOrNull(value) ?? <String, dynamic>{};
  }

  static Map<String, dynamic>? asMapOrNull(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    if (value is String) {
      final decoded = _tryDecode(value.trim());
      if (decoded is Map) {
        return decoded.map((key, val) => MapEntry(key.toString(), val));
      }
    }
    return null;
  }

  static List<dynamic> asList(dynamic value) {
    return asListOrNull(value) ?? <dynamic>[];
  }

  static List<dynamic>? asListOrNull(dynamic value) {
    if (value is List) return List<dynamic>.from(value);
    if (value is Iterable) return List<dynamic>.from(value);
    if (value is String) {
      final decoded = _tryDecode(value.trim());
      if (decoded is List) return List<dynamic>.from(decoded);
    }
    return null;
  }

  static List<Map<String, dynamic>> asListOfMaps(dynamic value) {
    return asList(value)
        .whereType<Map>()
        .map((item) => asMap(item))
        .toList();
  }

  /// First non-empty value among [keys]. Skips `null`, `""`, `{}`, and `[]`.
  static dynamic firstValue(Map json, List<String> keys) {
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (!_isEmpty(value)) return value;
    }
    return null;
  }

  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String && value.trim().isEmpty) return true;
    if (value is Map && value.isEmpty) return true;
    if (value is Iterable && value.isEmpty) return true;
    return false;
  }

  static dynamic _tryDecode(String value) {
    if (value.isEmpty) return null;
    if (!(value.startsWith('{') || value.startsWith('['))) return null;
    try {
      return jsonDecode(value);
    } catch (_) {
      return null;
    }
  }
}
