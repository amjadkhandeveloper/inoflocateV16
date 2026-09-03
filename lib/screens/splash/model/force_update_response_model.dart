class ForceUpdateModelDataError {
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
    message = json['message']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    return data;
  }
}

class ForceUpdateModelDataClient {
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
    forceupdate = json['Forceupdate']?.toInt();
    currentVersion = json['CurrentVersion']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Forceupdate'] = forceupdate;
    data['CurrentVersion'] = currentVersion;
    return data;
  }
}

class ForceUpdateModelData {
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
    status = json['status']?.toInt();
    client = (json['client'] != null)
        ? ForceUpdateModelDataClient.fromJson(json['client'])
        : null;
    if (json['error'] != null) {
      final v = json['error'];
      final arr0 = <ForceUpdateModelDataError>[];
      v.forEach((v) {
        arr0.add(ForceUpdateModelDataError.fromJson(v));
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

class ForceUpdateModel {
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
    data = (json['data'] != null)
        ? ForceUpdateModelData.fromJson(json['data'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final res = <String, dynamic>{};
    res['data'] = data!.toJson();
    return res;
  }
}
