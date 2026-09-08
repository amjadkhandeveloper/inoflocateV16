import 'client_model.dart';
import 'package:hive/hive.dart';

part 'user_login_response_model.g.dart';

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

bool _hasUserId(Map<String, dynamic> json) {
  return json['userid'] != null ||
      json['userId'] != null ||
      json['UserId'] != null ||
      json['UserID'] != null;
}

Map<String, dynamic>? _extractUserMap(Map<String, dynamic> json) {
  for (final key in [
    'user',
    'User',
    'userData',
    'UserData',
    'userInfo',
    'result',
    'Result',
  ]) {
    final map = _asMap(json[key]);
    if (map != null) {
      if (_hasUserId(map) ||
          map['Username'] != null ||
          map['userName'] != null ||
          map['username'] != null) {
        return map;
      }
      final nested = _extractUserMap(map);
      if (nested != null) return nested;
    }
    final list = json[key];
    if (list is List && list.isNotEmpty) {
      final first = _asMap(list.first);
      if (first != null && _hasUserId(first)) return first;
    }
  }
  for (final key in ['data', 'Data']) {
    final map = _asMap(json[key]);
    if (map != null) {
      final nested = _extractUserMap(map);
      if (nested != null) return nested;
      if (_hasUserId(map)) return map;
    }
    final list = json[key];
    if (list is List && list.isNotEmpty) {
      final first = _asMap(list.first);
      if (first != null && _hasUserId(first)) return first;
    }
  }
  if (_hasUserId(json)) return json;
  return null;
}

@HiveType(typeId: 0)
class UserLoginResponseModelDataUser {
/*
{
  "userid": 3,
  "Username": "Infotrack",
  "Theme": 1,
  "Language": "en"
  "IsAdvertise": false
} 
*/

  @HiveField(0)
  int? userid;
  @HiveField(1)
  String? username;
  @HiveField(2)
  int? theme;
  @HiveField(3)
  String? language;
  @HiveField(4)
  int? clientid;
  @HiveField(5)
  bool? showAdvertise;

  UserLoginResponseModelDataUser(
      {this.userid, this.username, this.theme, this.language, this.clientid, this.showAdvertise});

  UserLoginResponseModelDataUser.fromJson(Map<String, dynamic> json) {
    userid = _asInt(json['userid'] ??
        json['userId'] ??
        json['UserId'] ??
        json['UserID']);
    username = (json['Username'] ??
            json['username'] ??
            json['userName'] ??
            json['UserName'])
        ?.toString();
    theme = _asInt(json['Theme'] ?? json['theme']);
    language = (json['Language'] ?? json['language'])?.toString();
    clientid = _asInt(
        json['ClientId'] ?? json['clientId'] ?? json['clientid']);
    showAdvertise = json['IsAdvertise'] ??
        json['isAdvertise'] ??
        json['showAdvertise'] ??
        false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['userid'] = userid;
    data['Username'] = username;
    data['Theme'] = theme;
    data['Language'] = language;
    data['ClientId'] = clientid;
    data['IsAdvertise'] = showAdvertise;

    return data;
  }
}

class UserLoginResponseModelData {
/*
{
  "status": 200,
  "user": {
    "userid": 3,
    "Username": "Infotrack",
    "Theme": 1,
    "Language": "en"
  }
}
*/

  int? status;
  UserLoginResponseModelDataUser? user;
  List<DataError?>? error;

  UserLoginResponseModelData({this.status, this.user, this.error});

  UserLoginResponseModelData.fromJson(Map<String, dynamic> json) {
    status = _asInt(json['status'] ?? json['Status']);
    final userJson = _extractUserMap(json);
    if (userJson != null) {
      user = UserLoginResponseModelDataUser.fromJson(userJson);
    }
    if (json['error'] != null) {
      final v = json['error'];
      final arr0 = <DataError>[];
      v.forEach((v) {
        arr0.add(DataError.fromJson(v));
      });
      error = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class UserLoginResponseModel {
/*
{
  "data": {
    "status": 200,
    "user": {
      "userid": 3,
      "Username": "Infotrack",
      "Theme": 1,
      "Language": "en"
    }
  }
}
*/

  UserLoginResponseModelData? data;

  UserLoginResponseModel({
    this.data,
  });

  UserLoginResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = _extractUserMap(json);
    final nestedData = _asMap(json['data']) ?? _asMap(json['Data']);
    data = UserLoginResponseModelData(
      status: _asInt(json['status'] ??
          json['Status'] ??
          nestedData?['status'] ??
          nestedData?['Status']),
      user: userJson == null
          ? null
          : UserLoginResponseModelDataUser.fromJson(userJson),
    );
    if (nestedData != null && nestedData['error'] != null) {
      final v = nestedData['error'];
      final arr0 = <DataError>[];
      v.forEach((item) {
        arr0.add(DataError.fromJson(item));
      });
      data!.error = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final res = <String, dynamic>{};
    res['data'] = data!.toJson();
    return res;
  }
}
