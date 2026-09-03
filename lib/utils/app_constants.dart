/// Central constants for the InfoLocate app.
///
/// **API URL layout**
/// - Pre-login: countries/languages/force-update use [clientGatewayBaseUrl];
///   client login uses [clientAuthBaseUrl] (`URLAuthorization`).
/// - Post-login calls use `Global.savedClientAuthData.clientUrl` + relative paths
///   such as [dashboardUrl], [currDashVehicle], etc.
///
/// **Persistence**
/// - Hive box name: [myBox]
/// - Session keys: [clientAuthBoxKey], [userAuthBoxKey], [languageCodeKey], …
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/language/model/language_model.dart';

//* Google API Key
const String kGoogleApiKey = "AIzaSyDtbl-09rh6wg_0p2AaxO8eMso1Z7acn5w";

//* Default lat long
const LatLng kGooglePlex = LatLng(36.204824, 138.252924);

//* Hive boxes
const String myBox = 'myBox';

//* Hive keys
const String primaryColorKey = 'themeColorKey';
const String userAuthBoxKey = 'userAuthBoxKey';
const String userAdvertisement = 'userAdvertisement';
const String clientAuthBoxKey = 'clientAuthBoxKey';
const String countryCodeKey = 'countryCodeKey';
const String languageCodeKey = 'languageCodeKey';
const String vehicleMarkerIconKey = 'vehicleMarkerIconKey';
// const String lengthOfPinVehicles = 'lengthOfPinVehicles';
const String vehicleStatusCardTypeIdKey = 'vehicleStatusCardTypeIdKey';
const String alertStatusCardTypeIdKey = 'alertStatusCardTypeIdKey';
const String locationPermission = 'locationPermission';
// const String cardTypeSettingKey = 'cardTypeSettingKey';

//* langauge
final Language japaneseLangCode = Language(langCode: 'ja');
final Language englishLangCode = Language(langCode: 'en');
final Language spanishCode = Language(langCode: 'es');

//* font family
const String montserrat = "Montserrat";
const String meiryo = "Meiryo";

//* alert Video Decode Url
const String kVideDecodeUrl =
// "https://earthsupportlivevideo.infotracktelematics.com:9965/vss/apiPage/ReplayAlarmServerVideo.html";
    "https://infosmart.infotracktelematics.com:9965/vss/apiPage/ReplayAlarmServerVideo.html";

// "https://uyenotestlivevideo.infotracktelematics.com:9965/vss/apiPage/ReplayAlarmServerVideo.html";

//* alert Video Decode token
const String kToken = "f02cfa1cd21138ac89f7f1a32f8339be";

//* API base URLs
//* Client gateway — splash force-update, country list, language list.
//* Switch to staging if prod is unreachable on your network.
const String clientGatewayBaseUrl =
    "https://iftclientstaging.infotracktelematics.com:7009/fms/mapp/client";
// const String clientGatewayBaseUrl =
//     "https://iftclientprod.infotracktelematics.com:7009/fms/mapp/client";

//* Client login (`URLAuthorization`) — same hosts as the Android InfoLocate app.
const String clientAuthStagingUrl =
    "http://staging.infotracktelematics.com/InfoLocateClientAuthWebApi/api/service/";
const String clientAuthProductionUrl =
    "https://mappapi.infotracktelematics.com/InfoLocateClientAuth/api/service/";

/// Active client-login base. Switch to [clientAuthStagingUrl] to test staging.
const String clientAuthBaseUrl = clientAuthProductionUrl;

//* Pre-login / client-gateway endpoints
const String authClient = "${clientAuthBaseUrl}URLAuthorization";
const String forceUpdateUrl = "$clientGatewayBaseUrl/forceUpdateClient";
const String getCountryListUrl = "$clientGatewayBaseUrl/cntList"; // language screen — country dropdown
const String getLanguageListUrl = "$clientGatewayBaseUrl/lngList"; // language screen — language list

//* Post-login endpoints (full URL = saved clientUrl + path below)
const String authUser = "auth/authUser";
const String dashboardUrl = "vehicle/dashCnt"; // fleet counts / dashboard charts
const String alertwiseList = "vehicle/AlertwiseList"; // alert list screen
const String currDashVehicle = "vehicle/currDashVehicle"; // dynamic status live list
const String vehicleStatus = "vehicle/vehicleStatusWiseList"; // status-wise vehicles + map
const String pinVehicle = "vehicle/pinVehicleList"; // pin / unpin on dashboard
const String videoVehicleList = "vehicle/vehiclesList"; // video playback vehicle dropdown
const String vehicleVideoPlayback = "vehicle/vehicleVideoPlayback"; // playback URLs
const String historyTrackVehicle = "vehicle/historyTrackVehicle"; // track history on map
const String forgotPassword = "auth/verifyUser"; // password reset email
const String adsUrl = "auth/getAdv"; // dashboard banner ads
const String getCountry = "client/cntList"; // legacy path (prefer [getCountryListUrl])

/// Sample JSON only — not used at runtime (see grep). Kept for API contract reference.
const Map<String, dynamic> pinVehicleListJson = {
  "cardType": "D3",
  "pinVehicleList": [
    {
      "vehicleNo": "KA012345",
      "location": "xyz address for the current location",
      "tracktime": "22:12:2023 13:22:29",
      "driverName": "xyz",
      "driverMobileNo": "0000000000",
      "vehcileFeature": [
        {"key": "ignition", "value": "0/1"},
        {"key": "ac", "value": "0/1"},
        {"key": "temperature", "value": "32 C"},
        {"key": "speed", "value": "100 km/hr"}
      ]
    }
  ]
};

//constant string

const String clearFilter = 'Clear Filter';
// const String allValue = 'All';
// String trackHistory = LocaliazationKey.track_history.tr();
const String defaultFromTime = '00:00:00';
const String defaultToTime = '23:59:59';
const String timeFormat = 'hh:mm:ss';

const String idle = 'idle';
const String moving = 'moving';
const String stopped = 'stopped';
const String inactive = 'inactive';
// const String select = "--Select--";
// const String inactive = 'inactive';

//constant numbers
const int pageSize = 10;
const int maxPageSize = 100;
const int defaultPageN0 = 1;
const Locale enLocale = Locale('en', 'US');

const Map<String, dynamic> kLangaugeCode = {
  "English": "en",
  "English (United States)": "en",
  "Hindi": "hi",
  "Kannada": "kn",
  "Tamil": "ta",
  "Telugu": "te",
  "Urdu": "ur",
  "Japanese": "ja",
  "Spanish": "es",
  "Bangla": "bn",
};
