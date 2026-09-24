class FcmTokenRequestModel {
  FcmTokenRequestModel({
    required this.clientId,
    required this.userId,
    required this.fcmToken,
    required this.deviceId,
    required this.platform,
    required this.appVersion,
  });

  final int clientId;
  final int userId;
  final String fcmToken;
  final String deviceId;
  final String platform;
  final String appVersion;

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'userId': userId,
        'fcmToken': fcmToken,
        'deviceId': deviceId,
        'platform': platform,
        'appVersion': appVersion,
      };
}
