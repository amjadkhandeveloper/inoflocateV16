import 'package:hive/hive.dart';

import '../../../utils/json_safe_parser.dart';

part 'client_model.g.dart';

class DataError with JsonSafeParser {
/*
{
  "message": "Authentication failed"
} 
*/

  String? message;

  DataError({
    this.message,
  });
  DataError.fromJson(Map<String, dynamic> json) {
    message = asString(json['message']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    return data;
  }
}

@HiveType(typeId: 1)
class ClientModelDataClient with JsonSafeParser {
/*
{
  "ClientId": 0,
  "clientUrl": null,
  "currentVersion": 0
} 
*/
  @HiveField(0)
  int? clientId;
  @HiveField(1)
  String? clientUrl;
  @HiveField(2)
  int? currentVersion;
  @HiveField(3)
  String? clientName;

  ClientModelDataClient({
    this.clientId,
    this.clientUrl,
    this.currentVersion,
    this.clientName,
  });
  ClientModelDataClient.fromJson(Map<String, dynamic> json) {
    clientId = asIntFrom(json, ['ClientId', 'clientId']);
    clientUrl = asString(json['clientUrl']);
    currentVersion = asInt(json['currentVersion']);
    clientName = asString(json['clientName']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ClientId'] = clientId;
    data['clientUrl'] = clientUrl;
    data['currentVersion'] = currentVersion;
    data['clientName'] = clientName;
    return data;
  }
}

class ClientModelData with JsonSafeParser {
/*
{
  "status": 200,
  "client": {
    "ClientId": 0,
    "clientUrl": null,
    "currentVersion": 0
  },
  "error": [
    {
      "message": "Authentication failed"
    }
  ]
} 
*/

  int? status;
  ClientModelDataClient? client;
  List<DataError?>? error;

  ClientModelData({
    this.status,
    this.client,
    this.error,
  });
  ClientModelData.fromJson(Map<String, dynamic> json) {
    status = asIntFrom(json, ['status', 'Status']);
    final clientMap = asMapOrNull(json['client']);
    client = clientMap != null
        ? ClientModelDataClient.fromJson(clientMap)
        : null;
    if (json['error'] != null) {
      error = asListOfMaps(json['error']).map(DataError.fromJson).toList();
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

class ClientModel with JsonSafeParser {
/*
{
  "data": {
    "status": 200,
    "client": {
      "ClientId": 0,
      "clientUrl": null,
      "currentVersion": 0
    },
    "error": [
      {
        "message": "Authentication failed"
      }
    ]
  }
} 
*/

  ClientModelData? data;

  ClientModel({
    this.data,
  });
  ClientModel.fromJson(Map<String, dynamic> json) {
    final dataMap = asMapOrNull(json['data']);
    data = dataMap != null ? ClientModelData.fromJson(dataMap) : null;
  }
  Map<String, dynamic> toJson() {
    final res = <String, dynamic>{};
    res['data'] = data!.toJson();
    return res;
  }
}
