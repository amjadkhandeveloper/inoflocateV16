import '../../../utils/json_safe_parser.dart';

class ForceUpdateModelDataError with JsonSafeParser {
/*
{
  "message": "Force Update failed"
} 
*/

  String? message;

  ForceUpdateModelDataError({
    this.message,
  });
  ForceUpdateModelDataError.fromJson(Map<String, dynamic> json) {
    message = asString(json['message']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    return data;
  }
}

class ForceUpdateModelDataClient with JsonSafeParser {
/*
{
  "Forceupdate": 0,
  "CurrentVersion": 0
} 
*/

  int? forceupdate;
  int? currentVersion;

  ForceUpdateModelDataClient({
    this.forceupdate,
    this.currentVersion,
  });
  ForceUpdateModelDataClient.fromJson(Map<String, dynamic> json) {
    forceupdate = asIntFrom(json, ['Forceupdate', 'forceUpdate']);
    currentVersion = asIntFrom(json, ['CurrentVersion', 'currentVersion']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Forceupdate'] = forceupdate;
    data['CurrentVersion'] = currentVersion;
    return data;
  }
}

class ForceUpdateModelData with JsonSafeParser {
/*
{
  "status": 400,
  "client": {
    "Forceupdate": 0,
    "CurrentVersion": 0
  },
  "error": [
    {
      "message": "Force Update failed"
    }
  ]
} 
*/

  int? status;
  ForceUpdateModelDataClient? client;
  List<ForceUpdateModelDataError?>? error;

  ForceUpdateModelData({
    this.status,
    this.client,
    this.error,
  });
  ForceUpdateModelData.fromJson(Map<String, dynamic> json) {
    status = asIntFrom(json, ['status', 'Status']);
    final clientMap = asMapOrNull(json['client']);
    client = clientMap != null
        ? ForceUpdateModelDataClient.fromJson(clientMap)
        : null;
    if (json['error'] != null) {
      error = asListOfMaps(json['error'])
          .map(ForceUpdateModelDataError.fromJson)
          .toList();
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    if (client != null) {
      data['client'] = client!.toJson();
    }
    if (error != null) {
      final v = error;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['error'] = arr0;
    }
    return data;
  }
}

class ForceUpdateModel with JsonSafeParser {
/*
{
  "data": {
    "status": 400,
    "client": {
      "Forceupdate": 0,
      "CurrentVersion": 0
    },
    "error": [
      {
        "message": "Force Update failed"
      }
    ]
  }
} 
*/

  ForceUpdateModelData? data;

  ForceUpdateModel({
    this.data,
  });
  ForceUpdateModel.fromJson(Map<String, dynamic> json) {
    final dataMap = asMapOrNull(json['data']);
    data = dataMap != null ? ForceUpdateModelData.fromJson(dataMap) : null;
  }
  Map<String, dynamic> toJson() {
    final res = <String, dynamic>{};
    res['data'] = data!.toJson();
    return res;
  }
}
