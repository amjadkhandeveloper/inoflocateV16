# InfoLocate — API Reference (by screen)

Living document for every HTTP API the app calls. Update this file whenever a URL, request body, or response shape changes.

**Source of truth in code**

| What | Where |
|------|--------|
| Base URLs & path constants | `lib/utils/app_constants.dart` |
| Per-screen calls | `lib/screens/**/repository/*.dart` (and `language_service.dart`) |
| Request / response models | `lib/screens/**/model/*.dart` |
| Sequel vs common routing | `Global.isSequelClient` in `lib/utils/app_globals.dart` |

**How URLs are built**

| Kind | Pattern |
|------|---------|
| Pre-login gateway | Full URL from `clientGatewayBaseUrl` |
| Client login | Full URL from `clientAuthBaseUrl` + `URLAuthorization` |
| Common (post-login) | `{Global.savedClientAuthData.clientUrl}` + relative path |
| Sequel | Full URL under `https://sequelmobapi.infotracktelematics.com/` |

Sequel is used when the saved client name or `clientUrl` contains `"sequel"` (case-insensitive).

**Current bases** (see `app_constants.dart` — switch staging/prod there)

| Constant | Value |
|----------|--------|
| `clientGatewayBaseUrl` | `https://iftclientstaging.infotracktelematics.com:7009/fms/mapp/client` |
| `clientAuthBaseUrl` | `https://mappapi.infotracktelematics.com/InfoLocateClientAuth/api/service/` |
| `sequelApiBaseUrl` | `https://sequelmobapi.infotracktelematics.com/` |

**Content-Type:** `application/json` for all POSTs unless noted.

**Success status:** parsers treat `status` / `Status` of `1` or `200` as success in several places; user login also requires a non-empty user.

---

## Changelog

| Date | Change |
|------|--------|
| 2026-10-08 | Initial API reference from current repos/models |

---

## 1. Splash — Force update

**Screen:** Splash  
**Repo:** `lib/screens/splash/repository/splash_repo.dart`  
**Models:** `force_update_request_model.dart`, `force_update_response_model.dart`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientGatewayBaseUrl}/forceUpdateClient` | `{sequelApiBaseUrl}api/Auth/ForceUpdateClient` |

**Request (common)**

```json
{
  "ClientId": 1,
  "Appversion": 13,
  "AppId": 1
}
```

**Request (Sequel)**

```json
{
  "clientId": 1,
  "appVersion": 13,
  "appId": 1
}
```

`Appversion` / `appVersion` uses `kAppVersion` from `app_constants.dart`.

**Response (parsed fields)**

```json
{
  "status": 200,
  "client": {
    "Forceupdate": 0,
    "CurrentVersion": 0
  },
  "error": [{ "message": "Force Update failed" }]
}
```

- `Forceupdate == 1` → mandatory update dialog  
- Optional update when server version is newer than local

---

## 2. Language — Countries

**Screen:** Select language  
**Repo:** `lib/screens/language/repository/language_service.dart`  
**Model:** `get_countries_response_model.dart`

| | |
|--|--|
| **Method** | GET |
| **URL** | `{clientGatewayBaseUrl}/cntList` |
| **Request** | none |

**Response**

```json
{
  "data": {
    "status": 200,
    "countryList": [
      { "id": 104, "CountryName": "India", "isActive": true }
    ]
  }
}
```

---

## 3. Language — Languages for country

**Screen:** Select language  
**Repo:** `language_service.dart`  
**Model:** `language_model.dart`

| | |
|--|--|
| **Method** | POST |
| **URL** | `{clientGatewayBaseUrl}/lngList` |

**Request**

```json
{ "CountryId": 104 }
```

**Response**

```json
{
  "data": {
    "status": 200,
    "langListData": [
      {
        "languageId": 252,
        "Country_Id": 104,
        "Language": "English",
        "Langconvert": "en",
        "isActive": true
      }
    ]
  }
}
```

---

## 4. Client login

**Screen:** Client login  
**Repo:** `lib/screens/login/repository/client_repo.dart`  
**Models:** `user_login_request_model.dart`, `client_model.dart`  
**Encryption:** `AppEncryption.encryptData` / `decryptData` (`lib/utils/app_encryption.dart`)

| | |
|--|--|
| **Method** | POST |
| **URL** | `{clientAuthBaseUrl}URLAuthorization` |

**Request** (fields AES-encrypted strings)

```json
{
  "ClientName": "<encrypted loginName>",
  "Password": "<encrypted loginPwd>"
}
```

**Response** (encrypted fields; app decrypts)

```json
{
  "status": "<encrypted success|failure>",
  "message": "<encrypted message>",
  "url": "<encrypted tenant base URL>"
}
```

On success the app stores `clientUrl` (ensures trailing `/`) in Hive as the base for common post-login APIs.

---

## 5. User login

**Screen:** User login  
**Repo:** `lib/screens/login/repository/user_repo.dart`  
**Models:** `user_login_request_model.dart`, `user_login_response_model.dart`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientUrl}auth/authUser` | `{sequelApiBaseUrl}api/Auth/UserLogin` |

**Request (common)**

```json
{
  "LoginName": "infotrack",
  "LoginPwd": "********"
}
```

**Request (Sequel)**

```json
{
  "loginName": "infotrack",
  "loginPwd": "********",
  "language": "en",
  "theme": 1
}
```

**Response (success shape)**

```json
{
  "data": {
    "status": 200,
    "user": {
      "userid": 3,
      "Username": "Infotrack",
      "Theme": 1,
      "Language": "en",
      "ClientId": 1,
      "IsAdvertise": false
    }
  }
}
```

App success rule: not explicit fail (`status != 0`), status is `1` / `200` / null, and `userid > 0` with non-empty username.

---

## 6. Forgot password — Verify user

**Screen:** Forgot / reset password  
**Repo:** `lib/screens/forgot_password/repository/forgot_password_repo.dart`  
**Models:** `forgot_password_request_model.dart`, `forgot_password_response_model.dart`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientUrl}auth/verifyUser` | `{sequelApiBaseUrl}api/Auth/VerifyUser` |

**Request (common)**

```json
{ "LoginName": "infotrack" }
```

**Request (Sequel)**

```json
{
  "loginName": "infotrack",
  "loginPwd": ""
}
```

**Response**

```json
{
  "data": {
    "status": 200,
    "data": {
      "ResultID": 1,
      "ResultMessage": "User exsits",
      "Userid": 1,
      "Username": "Infotrack",
      "Authword": "infoadmin",
      "EmailId": "user@example.com"
    },
    "message": "Email sent successfully"
  }
}
```

---

## 7. Reset password

**Screen:** Reset password (after verify)  
**Repo:** `forgot_password_repo.dart` → `resetPasswordService`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientUrl}auth/verifyUser` | `{sequelApiBaseUrl}api/Auth/ResetPassword` |

**Request** (both use same body today)

```json
{
  "userid": 1,
  "newPassword": "********"
}
```

**Response:** same wrapper as forgot-password (`status`, `message`, nested `data`).

---

## 8. FCM token registration (Sequel only)

**Screen:** After Sequel user login / dashboard  
**Repo:** `lib/screens/fcm/repository/fcm_token_repo.dart`  
**Model:** `fcm_token_request_model.dart`  
**Caller:** `FcmTokenRegistrar` (`lib/screens/fcm/fcm_token_registrar.dart`)

| | |
|--|--|
| **Method** | POST |
| **URL** | `{sequelApiBaseUrl}api/FcmToken/RegisterToken` |
| **When** | Only if `Global.isSequelClient` |

**Request**

```json
{
  "clientId": 1,
  "userId": 3,
  "fcmToken": "<firebase token>",
  "deviceId": "<uuid stored in Hive>",
  "platform": "ios",
  "appVersion": "13"
}
```

`platform` is `"ios"` or `"android"`. `appVersion` is `kAppVersion` as string.

**Response:** logged; no strong typed model (any 2xx accepted).

---

## 9. Dashboard — Fleet summary (common)

**Screen:** Home / Dashboard  
**Repo:** `lib/screens/dashboard/repository/dashboard_repo.dart`  
**Models:** `dashboard_request_model.dart`, `dashboard_response_model.dart`

| | |
|--|--|
| **Method** | POST |
| **URL** | `{clientUrl}vehicle/dashCnt` |

**Request**

```json
{
  "UserId": 3,
  "pSize": 10,
  "PNo": 1
}
```

**Response**

```json
{
  "data": {
    "status": 200,
    "VehicleStatus": [
      {
        "cardType": "D1",
        "status": "Inactive",
        "Value": 8,
        "StatusID": 4,
        "Cid": 1
      }
    ],
    "StatusCount": [
      {
        "cardType": "D2",
        "id": 1,
        "AlertCount": 18,
        "AlertTypeID": 9,
        "cid": 2,
        "AlertType": "Over Speed"
      }
    ],
    "Pinvehicle": [
      {
        "cardType": "D3",
        "VehicleNo": "KA012345",
        "location": "...",
        "tracktime": "...",
        "LiveUrl": "https://..."
      }
    ]
  }
}
```

---

## 10. Dashboard — Fleet summary (Sequel)

**Screen:** Sequel dashboard  
**Repo:** `lib/screens/dashboard/repository/sequel_dashboard_repo.dart`  
**Model:** `sequel_dashboard_response_model.dart` (maps into common dashboard fields)

| | |
|--|--|
| **Method** | POST |
| **URL** | `{sequelApiBaseUrl}api/Vehicle/GetDashData` |

**Request**

```json
{
  "userId": 3,
  "pSize": 10,
  "pNo": 1
}
```

**Response** (flat; no `data` wrapper)

```json
{
  "status": 1,
  "message": "Success",
  "vehicleStatus": [ { "status": "Moving", "Value": 2, "StatusID": 1 } ],
  "statusCount": [ { "AlertCount": 5, "AlertTypeID": 9, "AlertType": "Over Speed" } ],
  "pinvehicle": [ { "VehicleNo": "...", "location": "...", "LiveUrl": "..." } ]
}
```

---

## 11. Dashboard — Ads (common only)

**Screen:** Dashboard carousel (when `IsAdvertise` is true)  
**Repo:** `lib/screens/dashboard/repository/ads_repo.dart`  
**Model:** `ads_response_model.dart`

| | |
|--|--|
| **Method** | POST |
| **URL** | `{clientUrl}auth/getAdv` |

**Request**

```json
{ "clientId": 1 }
```

**Response**

```json
{
  "data": {
    "status": 200,
    "advertise": [
      {
        "ClientAdvertiseID": 13,
        "ClientID": 1,
        "ClientAdvertiseUrl": "https://.../image.png"
      }
    ]
  }
}
```

---

## 12. Pin / unpin vehicle

**Screen:** Dashboard pin actions  
**Repo:** `lib/screens/pin_vehicles/repository/pin_vehicle_repo.dart`  
**Models:** `pin_vehicle_request_model.dart`, `pin_vehicle_response_model.dart`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientUrl}vehicle/pinVehicleList` | `{sequelApiBaseUrl}api/Vehicle/pinVehicleList` |

**Request (common)**

```json
{
  "ClientId": 1,
  "UserId": 3,
  "Vehicleid": 38,
  "InsertMode": 0
}
```

**Request (Sequel)**

```json
{
  "userId": 3,
  "clientId": 1,
  "vehicleId": 38,
  "insertMode": 0
}
```

`InsertMode` / `insertMode`: **0 = pin**, **1 = unpin**.

**Response**

```json
{
  "data": {
    "status": 200,
    "pinvehicle": [
      { "Resultid": "1", "Remark": "Vehicle added Sucessfully" }
    ]
  }
}
```

---

## 13. Alerts list

**Screen:** Alerts  
**Repo:** `lib/screens/alerts/respositroy/alert_repo.dart`  
**Models:** `alert_list_request_model.dart`, `alert_list_response_model.dart`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientUrl}vehicle/AlertwiseList` | `{sequelApiBaseUrl}api/Vehicle/AlertwiseList` |

**Request (common)**

```json
{
  "UserId": 3,
  "AlertTypeId": 10,
  "pSize": 100,
  "PNo": 1,
  "fromdt": "2023-04-27 00:00:00",
  "todt": "2023-04-27 23:59:59",
  "vno": ""
}
```

**Request (Sequel)**

```json
{
  "userId": 3,
  "alertTypeId": 10,
  "pSize": 100,
  "pNo": 1,
  "fromdt": "2023-04-27 00:00:00",
  "todt": "2023-04-27 23:59:59",
  "vno": ""
}
```

**Response**

```json
{
  "data": {
    "status": 200,
    "alertdetails": [
      {
        "Id": 11,
        "AlertTypeID": 28,
        "AlertType": "yaccel end",
        "VehicleID": 190,
        "Alertdatetime": "2023-05-15 14:42:17",
        "Lat": 33.69,
        "Lon": 135.41,
        "Location": "...",
        "ignition": 0,
        "speed": 0,
        "VehicleNo": "...",
        "Videofilepath": "...",
        "UnitNo": "62055",
        "Status": "Alert"
      }
    ],
    "alertcnt": [{ "TotRec": 21 }],
    "alerttypes": []
  }
}
```

---

## 14. Dynamic status (live vehicles)

**Screen:** Dynamic status  
**Repo:** `lib/screens/dynamic_status/respository/dyanmic_status_repo.dart`  
**Models:** `dynamic_status_request_model.dart`, `dynamic_status_response_model.dart`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientUrl}vehicle/currDashVehicle` | `{sequelApiBaseUrl}api/Vehicle/currDashVehicle` |

**Request (common)**

```json
{
  "UserId": 3,
  "pSize": 10,
  "PNo": 1,
  "sSearch": ""
}
```

**Request (Sequel)**

```json
{
  "userId": 3,
  "pSize": 10,
  "pNo": 1,
  "search": ""
}
```

**Response**

```json
{
  "data": {
    "status": 200,
    "vehicledetails": [
      {
        "id": 1,
        "VehicleId": 188,
        "VehicleNo": "Truck 2",
        "TrackingTime": "Jul 31 2023  6:02AM",
        "Location": "...",
        "speed": 0,
        "ignition": "On",
        "odometer": 19534.49,
        "Status": "Idle",
        "LiveUrl": "https://.../RealVideo.html?...",
        "Mapit": "33.9536,-118.192"
      }
    ],
    "vehicleCnt": [{ "reccount": 10 }]
  }
}
```

---

## 15. Vehicle status-wise list / live vehicles / map

**Screen:** Live vehicles, status list, track on map  
**Repo:** `lib/screens/vehicle_statuswise_list/repository/vehicle_status_repo.dart` → `getVehicleList`  
**Models:** `vehicle_status_request_model.dart`, `vehicle_status_response_model.dart`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientUrl}vehicle/vehicleStatusWiseList` | `{sequelApiBaseUrl}api/Vehicle/vehicleStatusWiseList` |

**Request (common)**

```json
{
  "UserId": 3,
  "StatusId": 0,
  "pSize": 10,
  "PNo": 1,
  "sSearch": ""
}
```

**Request (Sequel)**

```json
{
  "userId": 3,
  "statusId": 0,
  "pSize": 10,
  "pNo": 1,
  "search": ""
}
```

**Response**

```json
{
  "data": {
    "status": 200,
    "vehicleStatusdetails": [
      {
        "id": 1,
        "Vehicleid": 38,
        "Clientid": 20,
        "VehicleNo": "91004",
        "unitno": "91004",
        "tracktime": "2022-12-27T18:22:00.000Z",
        "lat": 12.99,
        "lon": 77.58,
        "location": "...",
        "ignition": 0,
        "speed": 0,
        "odometer": 1575.94,
        "Status": "Inactive",
        "LiveUrl": "https://.../RealVideo.html?...",
        "vstatus": "All Vehicles",
        "IsPinVehicle": 0
      }
    ]
  }
}
```

---

## 16. Track history

**Screen:** Track history map  
**Repo:** `vehicle_status_repo.dart` → `vehicleHistoryTrackApi`  
**Models:** `history_track_request_model.dart`, `history_track_response_model.dart`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientUrl}vehicle/historyTrackVehicle` | `{sequelApiBaseUrl}api/Vehicle/historyTrackVehicle` |

**Request (common)**

```json
{
  "UserId": 3,
  "VehicleID": 34,
  "FromDatetime": "2023-05-11 00:00:00",
  "ToDatetime": "2023-05-11 23:00:00"
}
```

**Request (Sequel)**

```json
{
  "userId": 3,
  "vehicleId": 34,
  "fromDatetime": "2023-05-11 00:00:00",
  "toDatetime": "2023-05-11 23:00:00"
}
```

**Response**

```json
{
  "data": {
    "status": 200,
    "VehicleHistory": [
      {
        "VehicleId": 34,
        "ClientID": 1,
        "VehicleNo": "72070",
        "Unitno": "72070",
        "tracktime": "05/10/2023 03:00:04",
        "lat": 33.22,
        "lon": 131.60,
        "location": "...",
        "speed": 0,
        "odometer": 1367.33,
        "direction": 321
      }
    ]
  }
}
```

---

## 17. Video playback — Vehicle dropdown

**Screen:** Video playback  
**Repo:** `lib/screens/video_playback/repository/video_playback_repo.dart` → `getVehicleList`  
**Model:** `video_vehicle_list_response_model.dart`

| | |
|--|--|
| **Method** | POST |
| **URL** | `{clientUrl}vehicle/vehiclesList` |
| **Note** | Common path only (no Sequel alternate in code) |

**Request**

```json
{ "UserId": 3 }
```

**Response**

```json
{
  "data": {
    "status": 200,
    "vehicles": [
      { "VehicleId": 50, "VehicleNo": "27", "DelayEnable": 90 }
    ]
  }
}
```

---

## 18. Video playback — Generate playback URL

**Screen:** Video playback  
**Repo:** `video_playback_repo.dart` → `generateVideoPlayback`  
**Models:** `video_playback_request_model.dart`, `video_playback_response_model.dart`

| | Common | Sequel |
|--|--------|--------|
| **Method** | POST | POST |
| **URL** | `{clientUrl}vehicle/vehicleVideoPlayback` | `{sequelApiBaseUrl}api/Vehicle/vehicleVideoPlayback` |

**Request (common)**

```json
{
  "UserId": 3,
  "VehicleID": 14,
  "StartDate": "20230504023500",
  "EndDate": "20230504024000"
}
```

**Request (Sequel)**

```json
{
  "userId": 3,
  "vehicleId": 14,
  "fromDatetime": "20230504023500",
  "toDatetime": "20230504024000"
}
```

**Response**

```json
{
  "data": {
    "status": 200,
    "playbackvideo": [
      {
        "vehicleid": 14,
        "Purl": "https://.../ReplayVideo.html?...",
        "startdate": "20230504023500",
        "enddate": "20230504024000"
      }
    ]
  }
}
```

---

## Quick index (path → screen)

| Path / endpoint | Screen |
|-----------------|--------|
| `.../forceUpdateClient` / `ForceUpdateClient` | Splash |
| `.../cntList` | Language |
| `.../lngList` | Language |
| `.../URLAuthorization` | Client login |
| `auth/authUser` / `UserLogin` | User login |
| `auth/verifyUser` / `VerifyUser` / `ResetPassword` | Forgot / reset password |
| `FcmToken/RegisterToken` | Push (Sequel) |
| `vehicle/dashCnt` / `GetDashData` | Dashboard |
| `auth/getAdv` | Dashboard ads |
| `vehicle/pinVehicleList` | Pin vehicle |
| `vehicle/AlertwiseList` | Alerts |
| `vehicle/currDashVehicle` | Dynamic status |
| `vehicle/vehicleStatusWiseList` | Live / status / map |
| `vehicle/historyTrackVehicle` | Track history |
| `vehicle/vehiclesList` | Video vehicle list |
| `vehicle/vehicleVideoPlayback` | Video playback |

---

## How to update this file

1. Change the API in the matching `*_repo.dart` / `*_service.dart`.
2. Update the request/response model if the JSON shape changed.
3. Edit the matching section above (URL, Request, Response).
4. Add a row under **Changelog**.
5. If you add a new screen API, add a new numbered section and a row in **Quick index**.
