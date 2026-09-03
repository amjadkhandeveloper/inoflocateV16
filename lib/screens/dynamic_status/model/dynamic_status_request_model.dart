/// POST body for [currDashVehicle] (dynamic status list).
///
/// [UserId] — logged-in user from [Global.savedUserAuthData].
/// [PNo] / [pSize] — pagination (see [pageSize], [defaultPageN0]).
/// [sSearch] — optional vehicle search text.
class DynamicStatusRequestModel {

  int? UserId;
  int? pSize;
  int? PNo;
  String? sSearch = '';

  DynamicStatusRequestModel({this.UserId, this.pSize, this.PNo, this.sSearch});
  DynamicStatusRequestModel.fromJson(Map<String, dynamic> json) {
    UserId = json['UserId']?.toInt();
    pSize = json['pSize']?.toInt();
    PNo = json['PNo']?.toInt();
    sSearch = json['sSearch'].toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['UserId'] = UserId;
    data['pSize'] = pSize;
    data['PNo'] = PNo;
    data['sSearch'] = sSearch;
    return data;
  }
}
