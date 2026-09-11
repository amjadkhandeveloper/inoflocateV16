import 'package:hive/hive.dart';

import '../../../utils/json_safe_parser.dart';
import 'client_model.dart';

part 'user_login_response_model.g.dart';

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
    final map = JsonSafe.asMapOrNull(json[key]);
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
    final list = JsonSafe.asListOrNull(json[key]);
    if (list != null && list.isNotEmpty) {
      final first = JsonSafe.asMapOrNull(list.first);
      if (first != null && _hasUserId(first)) return first;
    }
  }
  for (final key in ['data', 'Data']) {
    final map = JsonSafe.asMapOrNull(json[key]);
    if (map != null) {
      final nested = _extractUserMap(map);
      if (nested != null) return nested;
      if (_hasUserId(map)) return map;
    }
    final list = JsonSafe.asListOrNull(json[key]);
    if (list != null && list.isNotEmpty) {
      final first = JsonSafe.asMapOrNull(list.first);
      if (first != null && _hasUserId(first)) return first;
    }
  }
  if (_hasUserId(json)) return json;
  return null;
}

@HiveType(typeId: 0)
class UserLoginResponseModelDataUser with JsonSafeParser {
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
    userid = asIntFrom(json, ['userid', 'userId', 'UserId', 'UserID']);
    username = asStringFrom(json, [
      'Username',
      'username',
      'userName',
      'UserName',
    ]);
    theme = asIntFrom(json, ['Theme', 'theme']);
    language = asStringFrom(json, ['Language', 'language']);
    clientid = asIntFrom(json, ['ClientId', 'clientId', 'clientid']);
    showAdvertise = asBoolFrom(json, [
      'IsAdvertise',
      'isAdvertise',
      'showAdvertise',
    ]);
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

class UserLoginResponseModelData with JsonSafeParser {
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
    status = asIntFrom(json, ['status', 'Status']);
    final userJson = _extractUserMap(json);
    if (userJson != null) {
      user = UserLoginResponseModelDataUser.fromJson(userJson);
    }
    if (json['error'] != null) {
      error = asListOfMaps(json['error']).map(DataError.fromJson).toList();
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

class UserLoginResponseModel with JsonSafeParser {
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
    final nestedData =
        asMapOrNull(json['data']) ?? asMapOrNull(json['Data']);
    data = UserLoginResponseModelData(
      status: asInt(json['status'] ??
          json['Status'] ??
          nestedData?['status'] ??
          nestedData?['Status']),
      user: userJson == null
          ? null
          : UserLoginResponseModelDataUser.fromJson(userJson),
    );
    if (nestedData != null && nestedData['error'] != null) {
      data!.error =
          asListOfMaps(nestedData['error']).map(DataError.fromJson).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final res = <String, dynamic>{};
    res['data'] = data!.toJson();
    return res;
  }
}
