import 'client_model.dart';
import 'package:hive/hive.dart';

part 'user_login_response_model.g.dart';

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
    userid = json['userid']?.toInt();
    username = json['Username']?.toString();
    theme = json['Theme']?.toInt();
    language = json['Language']?.toString();
    clientid = json['ClientId']?.toInt();
    showAdvertise = json['IsAdvertise'] ?? false;
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
    status = json['status']?.toInt();
    user = (json['user'] != null) ? UserLoginResponseModelDataUser.fromJson(json['user']) : null;
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
    data = (json['data'] != null) ? UserLoginResponseModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final res = <String, dynamic>{};
    res['data'] = data!.toJson();
    return res;
  }
}
