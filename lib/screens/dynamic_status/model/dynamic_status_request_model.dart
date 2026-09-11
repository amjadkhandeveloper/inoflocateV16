import '../../../utils/json_safe_parser.dart';

/// POST body for [currDashVehicle] (dynamic status list).
///
/// Common tenant: `UserId`, `PNo`, `sSearch`.
/// Sequel swagger: `userId`, `pNo`, `search`.
class DynamicStatusRequestModel with JsonSafeParser {
  int? UserId;
  int? pSize;
  int? PNo;
  String? sSearch = '';

  DynamicStatusRequestModel({this.UserId, this.pSize, this.PNo, this.sSearch});
  DynamicStatusRequestModel.fromJson(Map<String, dynamic> json) {
    UserId = asIntFrom(json, ['UserId', 'userId']);
    pSize = asInt(json['pSize']);
    PNo = asIntFrom(json, ['PNo', 'pNo']);
    sSearch = asStringFrom(json, ['sSearch', 'search']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['UserId'] = UserId;
    data['pSize'] = pSize;
    data['PNo'] = PNo;
    data['sSearch'] = sSearch;
    return data;
  }

  Map<String, dynamic> toSequelJson() {
    return {
      'userId': UserId,
      'pSize': pSize,
      'pNo': PNo,
      'search': sSearch ?? '',
    };
  }
}
