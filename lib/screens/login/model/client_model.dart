import 'package:hive/hive.dart';
part 'client_model.g.dart';

class DataError {
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
    message = json['message']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    return data;
  }
}

@HiveType(typeId: 1)
class ClientModelDataClient {
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
    clientId = json['ClientId']?.toInt();
    clientUrl = json['clientUrl']?.toString();
    currentVersion = json['currentVersion']?.toInt();
    clientName = json['clientName']?.toString();
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

class ClientModelData {
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
    status = json['status']?.toInt();
    client = (json['client'] != null)
        ? ClientModelDataClient.fromJson(json['client'])
        : null;
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

class ClientModel {
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
    data =
        (json['data'] != null) ? ClientModelData.fromJson(json['data']) : null;
  }
  Map<String, dynamic> toJson() {
    final res = <String, dynamic>{};
    res['data'] = data!.toJson();
    return res;
  }
}
