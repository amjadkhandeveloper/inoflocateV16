# InfoLocate API reference

Single reference for every HTTP API the Flutter app calls after the Sequel / common-tenant split. Source of truth: `lib/utils/app_constants.dart` and `lib/screens/**/repository/`.

---

## How routing works after client login

1. User logs in as a **client** (tenant).
2. The app stores `clientName` and `clientUrl` in Hive.
3. `Global.isSequelClient` is **true** if `clientName` or `clientUrl` contains `"sequel"` (case-insensitive).
4. After **user login**:
   - Sequel → `SequelDashboardScreen` and Sequel APIs below.
   - Everyone else → `HomeScreen` and `{clientUrl}` tenant APIs.

Fresh **client login** is required if an old Hive session has no `clientName` field.

There is no Bearer token. Session is implied by `ClientId` / `userid` in request bodies.

---

## Base URLs (active)

| Purpose | Constant | URL |
|---------|----------|-----|
| Country / language / force-update | `clientGatewayBaseUrl` | `https://iftclientstaging.infotracktelematics.com:7009/fms/mapp/client` |
| Client login | `clientAuthBaseUrl` | `https://mappapi.infotracktelematics.com/InfoLocateClientAuth/api/service/` |
| Sequel APIs | `sequelApiBaseUrl` | `https://sequelmobapi.infotracktelematics.com/` |
| Other tenants (after client login) | `clientUrl` from login | Example: `https://iftuserstaging.infotracktelematics.com:7010/` |

`clientUrl` is concatenated with a relative path. If the server omits a trailing `/`, the app adds one.

Swagger (Sequel): `https://sequelmobapi.infotracktelematics.com/swagger/v1/swagger.json`

---

## Quick URL index

### Pre-login (fixed hosts)

| # | Purpose | Method | Full URL | Wired |
|---|---------|--------|----------|-------|
| 1 | Country list | `GET` | `https://iftclientstaging.infotracktelematics.com:7009/fms/mapp/client/cntList` | Yes |
| 2 | Language list | `POST` | `https://iftclientstaging.infotracktelematics.com:7009/fms/mapp/client/lngList` | Yes |
| 3 | Force update | `POST` | `https://iftclientstaging.infotracktelematics.com:7009/fms/mapp/client/forceUpdateClient` | Yes |
| 4 | Client login | `POST` | `https://mappapi.infotracktelematics.com/InfoLocateClientAuth/api/service/URLAuthorization` | Yes |

### Sequel (only when `isSequelClient`)

| # | Purpose | Method | Full URL | Wired |
|---|---------|--------|----------|-------|
| 5 | User login | `POST` | `https://sequelmobapi.infotracktelematics.com/api/Auth/UserLogin` | Yes |
| 6 | Dashboard | `POST` | `https://sequelmobapi.infotracktelematics.com/api/Vehicle/GetDashData` | Yes |
| 7 | History track | `POST` | `https://sequelmobapi.infotracktelematics.com/api/Vehicle/historyTrackVehicle` | Yes |

### Common tenants — `{clientUrl}` + path

Used for **non-Sequel** clients. Sequel still uses these for alerts, status list, pin, video, forgot password, and ads until those screens are switched.

| # | Purpose | Path | Example |
|---|---------|------|---------|
| 8 | User login | `auth/authUser` | `{clientUrl}auth/authUser` |
| 9 | Dashboard | `vehicle/dashCnt` | `{clientUrl}vehicle/dashCnt` |
| 10 | Alerts list | `vehicle/AlertwiseList` | `{clientUrl}vehicle/AlertwiseList` |
| 11 | Live / dynamic vehicles | `vehicle/currDashVehicle` | `{clientUrl}vehicle/currDashVehicle` |
| 12 | Status-wise list | `vehicle/vehicleStatusWiseList` | `{clientUrl}vehicle/vehicleStatusWiseList` |
| 13 | Pin / unpin | `vehicle/pinVehicleList` | `{clientUrl}vehicle/pinVehicleList` |
| 14 | Video vehicle list | `vehicle/vehiclesList` | `{clientUrl}vehicle/vehiclesList` |
| 15 | Video playback | `vehicle/vehicleVideoPlayback` | `{clientUrl}vehicle/vehicleVideoPlayback` |
| 16 | History track | `vehicle/historyTrackVehicle` | `{clientUrl}vehicle/historyTrackVehicle` |
| 17 | Forgot password | `auth/verifyUser` | `{clientUrl}auth/verifyUser` |
| 18 | Ads / carousel | `auth/getAdv` | `{clientUrl}auth/getAdv` |

---

## Conventions

| Item | Common tenant | Sequel |
|------|---------------|--------|
| Content-Type | `application/json` | `application/json` |
| HTTP | Almost all `POST`; countries is `GET` | `POST` |
| Body keys | PascalCase (`UserId`, `PNo`, `LoginName`) | camelCase (`userId`, `pNo`, `loginName`) |
| Success envelope | `{ "data": { "status": 200, ... } }` | Often **flat**: `{ "status": 1, ... }` (no `data` wrapper) |
| Success status | `200` | `1` or `200` |
| Pagination | `pSize` (default **10**), `PNo` (1-based) | `pSize` (default **10**), `pNo` (1-based) |
| User id field | `userid` in login, send as `UserId` | `userid` / `userId` / `UserId` accepted |

Error shape (common):

```json
{
  "data": {
    "status": 400,
    "error": [{ "message": "Authentication failed" }]
  }
}
```

Date formats:

| Use | Format | Example |
|-----|--------|---------|
| Alerts | `yyyy-MM-dd HH:mm:ss` | `2023-04-27 00:00:00` |
| History | `yyyy-MM-dd HH:mm:ss` | `2023-05-11 00:00:00` |
| Video request | `yyyy-MM-dd HH:mm:ss` | `2023-05-04 02:35:00` |
| Video response | `yyyyMMddHHmmss` | `20230504023500` |

Dashboard card types: `D1` status counts, `D2` alert counts, `D3` pinned vehicles.

---

# A. Pre-login APIs

## 1. Country list

| | |
|--|--|
| Method | `GET` |
| URL | `https://iftclientstaging.infotracktelematics.com:7009/fms/mapp/client/cntList` |
| Auth | None |
| Repo | `lib/screens/language/repository/language_service.dart` |

**Request:** none.

**Response:**

```json
{
  "data": {
    "status": 200,
    "countryList": [
      {
        "id": 104,
        "CountryName": "India",
        "isActive": true
      }
    ]
  }
}
```

---

## 2. Language list

| | |
|--|--|
| Method | `POST` |
| URL | `https://iftclientstaging.infotracktelematics.com:7009/fms/mapp/client/lngList` |
| Repo | `lib/screens/language/repository/language_service.dart` |

**Request:**

```json
{
  "CountryId": 104
}
```

**Response:**

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

Use `Langconvert` (`en`, `ja`, `es`, …) as the app locale.

---

## 3. Force update

| | |
|--|--|
| Method | `POST` |
| URL | `https://iftclientstaging.infotracktelematics.com:7009/fms/mapp/client/forceUpdateClient` |
| When | Splash, if a client session is already saved |
| Repo | `lib/screens/splash/repository/splash_repo.dart` |

**Request:**

```json
{
  "ClientId": 1,
  "Appversion": 0,
  "AppId": 1
}
```

| Field | Notes |
|-------|--------|
| `AppId` | `1` (platform id used by the app) |
| `Appversion` | Integer build / version code |

**Response** (parsed at root; some servers wrap in `data`):

```json
{
  "status": 200,
  "client": {
    "Forceupdate": 0,
    "CurrentVersion": 0
  }
}
```

| `Forceupdate` | Meaning |
|---------------|---------|
| `0` | No forced update |
| `1` | Show mandatory update dialog |

---

## 4. Client login (`URLAuthorization`)

| | |
|--|--|
| Method | `POST` |
| URL | `https://mappapi.infotracktelematics.com/InfoLocateClientAuth/api/service/URLAuthorization` |
| Repo | `lib/screens/login/repository/client_repo.dart` |

Plaintext credentials are **AES-encrypted** before send (`ClientName`, `Password`). Response fields (`status`, `message`, `url`) are also encrypted and decrypted in the app.

**Request (logical / before encryption):**

```json
{
  "ClientName": "<client login name>",
  "Password": "<client password>"
}
```

**Request (what goes on the wire):** AES ciphertext strings in those two fields.

**Success (after decrypt):** `url` is the tenant `clientUrl`. Production often does **not** return a real `ClientId`; the app stores `clientId: 0` and the typed client name.

Logical result stored in Hive:

```json
{
  "status": 200,
  "client": {
    "ClientId": 0,
    "clientUrl": "https://example-tenant.infotracktelematics.com/",
    "currentVersion": 0,
    "clientName": "sequel"
  }
}
```

If `clientName` or `clientUrl` contains `sequel`, later calls use Sequel APIs.

**Failure (after decrypt):** `status` = `failure` and a `message` (invalid credentials, etc.).

Staging client-auth host (switch `clientAuthBaseUrl` in code):

```
http://staging.infotracktelematics.com/InfoLocateClientAuthWebApi/api/service/URLAuthorization
```

---

# B. Sequel APIs (wired)

Base: `https://sequelmobapi.infotracktelematics.com/`

JSON is usually **flat**. The app also accepts a nested `data` wrapper where parsers allow it.

---

## 5. Sequel user login

| | |
|--|--|
| Method | `POST` |
| URL | `https://sequelmobapi.infotracktelematics.com/api/Auth/UserLogin` |
| When | After Sequel client login |
| Repo | `lib/screens/login/repository/user_repo.dart` |

**Request:**

```json
{
  "loginName": "user_name",
  "loginPwd": "password",
  "language": "en",
  "theme": 1
}
```

**Response (flat, typical):**

```json
{
  "status": 1,
  "message": "Success",
  "userid": 123,
  "userId": 123,
  "Username": "Fleet User",
  "Theme": 1,
  "Language": "en",
  "ClientId": 0,
  "IsAdvertise": false
}
```

**Response (wrapped, also accepted):**

```json
{
  "data": {
    "status": 200,
    "user": {
      "userid": 123,
      "Username": "Fleet User",
      "Theme": 1,
      "Language": "en",
      "ClientId": 0,
      "IsAdvertise": false
    }
  }
}
```

Parser also accepts `userId` / `UserId`, nested `user` / `data` / `result`, or a JSON **string** body.

Login is treated as success if `status` is `1` or `200`, or a user object with `userid` is present. Sequel (and `clientId` `0`/`null`) skip the client-id mismatch check used for other tenants.

---

## 6. Sequel dashboard (`GetDashData`)

| | |
|--|--|
| Method | `POST` |
| URL | `https://sequelmobapi.infotracktelematics.com/api/Vehicle/GetDashData` |
| Screen | `SequelDashboardScreen` |
| Repo | `lib/screens/dashboard/repository/sequel_dashboard_repo.dart` |

**Request:**

```json
{
  "userId": 123,
  "pSize": 10,
  "pNo": 1
}
```

**Response:**

```json
{
  "status": 1,
  "message": "Success",
  "vehicleStatus": [
    {
      "cardType": "D1",
      "status": "Moving",
      "Value": 12,
      "StatusID": 1,
      "Cid": 1,
      "SequenceId": 1
    },
    {
      "cardType": "D1",
      "status": "Stopped",
      "Value": 4,
      "StatusID": 2
    },
    {
      "cardType": "D1",
      "status": "Idle",
      "Value": 3,
      "StatusID": 3
    },
    {
      "cardType": "D1",
      "status": "Inactive",
      "Value": 8,
      "StatusID": 4
    }
  ],
  "statusCount": [
    {
      "cardType": "D2",
      "id": 1,
      "AlertCount": 18,
      "AlertTypeID": 9,
      "cid": 2,
      "AlertType": "Over Speed"
    }
  ],
  "pinvehicle": [
    {
      "cardType": "D3",
      "id": 1,
      "VehicleId": 34,
      "VehicleNo": "72070",
      "DriverName": null,
      "TrackingTime": "2023-04-24 19:42:04",
      "Location": "Address",
      "speed": 0,
      "ignition": "On",
      "odometer": 1367.33,
      "Idleduration": 28675,
      "Status": "Idle",
      "DelayEnable": 90,
      "LiveUrl": "https://.../RealVideo.html?...",
      "Mapit": "33.2293,131.603",
      "Cid": 3
    }
  ]
}
```

`Mapit` is `"latitude,longitude"`. Keys `vehicleStatus` / `VehicleStatus`, `statusCount` / `StatusCount`, `pinvehicle` / `Pinvehicle` are all accepted.

UI uses:

- KPI totals from `vehicleStatus` (`Value`)
- Donut + legend from the same list
- Alerts chart from `statusCount` (`AlertCount`, `AlertType`)
- Vehicles list from `pinvehicle` (search + pagination via `pNo`)

---

## 7. Sequel history track

| | |
|--|--|
| Method | `POST` |
| URL | `https://sequelmobapi.infotracktelematics.com/api/Vehicle/historyTrackVehicle` |
| Screen | Track on map → Track history |
| Repo | `lib/screens/vehicle_statuswise_list/repository/vehicle_status_repo.dart` |

**Request:**

```json
{
  "userId": 123,
  "vehicleId": 34,
  "fromDatetime": "2023-05-11 00:00:00",
  "toDatetime": "2023-05-11 23:00:00"
}
```

**Response (flat or wrapped):**

```json
{
  "status": 1,
  "vehicleHistory": [
    {
      "vehicleId": 34,
      "vehicleNo": "72070",
      "tracktime": "05/10/2023 03:00:04",
      "lat": 33.229,
      "lon": 131.602,
      "location": "Address",
      "speed": 0,
      "odometer": 1367.33,
      "direction": 321
    }
  ]
}
```

Point parser also accepts `VehicleId`, `latitude`, `lng` / `longitude`, and list key `VehicleHistory`.

---

# C. Common tenant APIs (`{clientUrl}`)

Used for **non-Sequel** user login, dashboard, and history. Sequel still uses this host for the endpoints in this section that are not listed in **B**.

---

## 8. User login (`authUser`)

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}auth/authUser` |
| When | Non-Sequel only |
| Repo | `lib/screens/login/repository/user_repo.dart` |

**Request:**

```json
{
  "LoginName": "ars_logistics",
  "LoginPwd": "welcome@123"
}
```

**Response:**

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

`userid` is sent as `UserId` on later vehicle APIs. If `ClientId` on the user does not match the saved client (and client id is not `0`), login is rejected.

---

## 9. Dashboard (`dashCnt`)

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}vehicle/dashCnt` |
| Screen | `HomeScreen` (non-Sequel) |
| Repo | `lib/screens/dashboard/repository/dashboard_repo.dart` |

**Request:**

```json
{
  "UserId": 3,
  "pSize": 10,
  "PNo": 1
}
```

**Response** (inner payload; may be under `data` or at root):

```json
{
  "status": 200,
  "VehicleStatus": [
    {
      "cardType": "D1",
      "status": "Inactive",
      "Value": 8,
      "StatusID": 4,
      "Cid": 1,
      "SequenceId": 1
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
      "id": 1,
      "VehicleId": 34,
      "VehicleNo": "72070",
      "DriverName": null,
      "TrackingTime": "2023-04-24 19:42:04",
      "Location": "Address",
      "speed": 0,
      "ignition": "On",
      "odometer": 1367.33,
      "Idleduration": 28675,
      "Status": "Idle",
      "DelayEnable": 90,
      "LiveUrl": "https://.../RealVideo.html?...",
      "Mapit": "33.2293,131.603",
      "Cid": 3
    }
  ]
}
```

---

## 10. Alerts list (`AlertwiseList`)

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}vehicle/AlertwiseList` |
| Repo | `lib/screens/alerts/respositroy/alert_repo.dart` |

**Request:**

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

| Field | Notes |
|-------|--------|
| `AlertTypeId` | From dashboard `AlertTypeID` |
| `vno` | Vehicle number filter; `""` = all |

**Response:**

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
        "DriverID": null,
        "Alertdatetime": "2023-05-15 14:42:17",
        "Lat": 33.699,
        "Lon": 135.41,
        "Location": "Address",
        "ignition": 0,
        "speed": 0,
        "direction": 0,
        "VehicleNo": "o6e2oohgkg",
        "Videofilepath": "1|base64path,2|base64path",
        "VFC": 4,
        "Status": "Alert",
        "Unitid": 6,
        "UnitNo": "62055",
        "drivername": "",
        "devicetype": "MDVR"
      }
    ],
    "alertcnt": [{ "TotRec": 21 }],
    "alerttypes": [
      { "AlertTypeID": 9, "AlertType": "Over Speed" }
    ]
  }
}
```

`Videofilepath` is comma-separated `channel|encodedPath` pairs.

---

## 11. Dynamic / current dashboard vehicles (`currDashVehicle`)

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}vehicle/currDashVehicle` |
| Repo | `lib/screens/dynamic_status/respository/dyanmic_status_repo.dart` |

**Request:**

```json
{
  "UserId": 3,
  "pSize": 100,
  "PNo": 1,
  "sSearch": ""
}
```

**Response:**

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
        "Location": "4479-4301 Mason St, South Gate, CA 90280",
        "speed": 0,
        "ignition": "On",
        "odometer": 19534.49,
        "Status": "Idle",
        "DelayEnable": 90,
        "LiveUrl": "https://.../RealVideo.html?...",
        "Mapit": "33.9536,-118.192",
        "Idleduration": 0,
        "devicetype": "MDVR"
      }
    ],
    "vehicleCnt": [{ "reccount": 10 }]
  }
}
```

---

## 12. Vehicle status-wise list

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}vehicle/vehicleStatusWiseList` |
| Repo | `lib/screens/vehicle_statuswise_list/repository/vehicle_status_repo.dart` |

**Request:**

```json
{
  "UserId": 3,
  "StatusId": 4,
  "pSize": 10,
  "PNo": 1,
  "sSearch": ""
}
```

`StatusId` comes from dashboard `StatusID` (idle / moving / stopped / inactive).

**Response:**

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
        "Lat": 12.991,
        "lon": 77.588,
        "location": "Address",
        "ignition": 0,
        "speed": 0,
        "odometer": 1575.94,
        "direction": 357,
        "idleduration": 91,
        "stopduration": 0,
        "alertind": 0,
        "EngineOffdelay": 0,
        "Directions": 0,
        "Status": "Inactive",
        "LiveUrl": "https://.../RealVideo.html?...",
        "vstatus": "All Vehicles",
        "IsPinVehicle": 0,
        "devicetype": "MDVR"
      }
    ],
    "vehicleCount": [{ "recCnt": 44 }]
  }
}
```

---

## 13. Pin / unpin vehicle

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}vehicle/pinVehicleList` |
| Repo | `lib/screens/pin_vehicles/repository/pin_vehicle_repo.dart` |

**Request:**

```json
{
  "ClientId": 1,
  "UserId": 3,
  "Vehicleid": 34,
  "InsertMode": 0
}
```

| `InsertMode` | Action |
|--------------|--------|
| `0` | Pin |
| `1` | Unpin |

**Response:**

```json
{
  "data": {
    "status": 200,
    "pinvehicle": [
      {
        "Resultid": "1",
        "Remark": "Vehicle added Sucessfully"
      }
    ]
  }
}
```

---

## 14. Video — vehicle list

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}vehicle/vehiclesList` |
| Repo | `lib/screens/video_playback/repository/video_playback_repo.dart` |

**Request:**

```json
{
  "UserId": 3
}
```

**Response:**

```json
{
  "data": {
    "status": 200,
    "vehicles": [
      {
        "VehicleId": 50,
        "VehicleNo": "27",
        "DelayEnable": 90,
        "devicetype": "MDVR"
      }
    ]
  }
}
```

---

## 15. Video — playback URL

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}vehicle/vehicleVideoPlayback` |
| Repo | `lib/screens/video_playback/repository/video_playback_repo.dart` |

**Request:**

```json
{
  "UserId": 3,
  "VehicleID": 14,
  "StartDate": "2023-05-04 02:35:00",
  "EndDate": "2023-05-04 02:40:00"
}
```

**Response:**

```json
{
  "data": {
    "status": 200,
    "playbackvideo": [
      {
        "vehicleid": 14,
        "Purl": "https://.../ReplayVideo.html?token=...&deviceId=62071&chs=1_2_3_4&st=20230504023500&et=20230504024000",
        "startdate": "20230504023500",
        "enddate": "20230504024000"
      }
    ]
  }
}
```

Open `Purl` in a WebView. Live video uses `LiveUrl` from dashboard / vehicle rows (`RealVideo.html`).

---

## 16. History track (common tenant)

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}vehicle/historyTrackVehicle` |
| When | Non-Sequel |
| Repo | `lib/screens/vehicle_statuswise_list/repository/vehicle_status_repo.dart` |

**Request:**

```json
{
  "UserId": 3,
  "VehicleID": 34,
  "FromDatetime": "2023-05-11 00:00:00",
  "ToDatetime": "2023-05-11 23:00:00"
}
```

**Response:**

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
        "lat": 33.229,
        "lon": 131.602,
        "location": "Address",
        "speed": 0,
        "odometer": 1367.33,
        "direction": 321,
        "idleduration": 75080,
        "stopduration": 0,
        "AlertInd": 0,
        "Directions": 315,
        "VehicleType": "4 Wheeler"
      }
    ]
  }
}
```

---

## 17. Forgot password (`verifyUser`)

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}auth/verifyUser` |
| Repo | `lib/screens/forgot_password/repository/forgot_password_repo.dart` |

**Request:**

```json
{
  "LoginName": "ars_logistics"
}
```

**Response:**

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

## 18. Advertisements (`getAdv`)

| | |
|--|--|
| Method | `POST` |
| URL | `{clientUrl}auth/getAdv` |
| Repo | `lib/screens/dashboard/repository/ads_repo.dart` |

**Request:**

```json
{
  "clientId": 1
}
```

**Response:**

```json
{
  "data": {
    "status": 200,
    "advertise": [
      {
        "ClientAdvertiseID": 13,
        "ClientID": 1,
        "ClientAdvertiseUrl": "https://example.com/images/banner.png",
        "CreateDate": "2023-06-08T18:02:00.000Z",
        "ValidDate": "2023-06-17T15:00:00.000Z"
      }
    ]
  }
}
```

Loaded when user login returns `IsAdvertise: true`.

---

# D. Sequel swagger — not wired in the app yet

These exist on `https://sequelmobapi.infotracktelematics.com/` (see swagger). The app still hits `{clientUrl}` for the same features.

| Path | Typical purpose |
|------|-----------------|
| `/api/Auth/ClientLogin` | Sequel client login (app uses production `URLAuthorization` instead) |
| `/api/Auth/VerifyUser` | Password reset |
| `/api/Auth/ResetPassword` | Reset password |
| `/api/Auth/EmailSendVerifyUser` | Email verify |
| `/api/Auth/getAdv` | Ads |
| `/api/Auth/lngList` | Languages |
| `/api/Auth/cntList` | Countries |
| `/api/Auth/ForceUpdateClient` | Force update |
| `/api/FcmToken/RegisterToken` | Push token |
| `/api/Vehicle/currDashVehicle` | Live vehicle list |
| `/api/Vehicle/vehicleStatusWiseList` | Status-wise list |
| `/api/Vehicle/AlertwiseList` | Alerts |
| `/api/Vehicle/vehiclesList` | Video vehicle dropdown |
| `/api/Vehicle/vehicleVideoPlayback` | Playback URLs |
| `/api/Vehicle/pinVehicleList` | Pin / unpin |

When switching a screen to Sequel, send **camelCase** bodies (`userId`, `pNo`, `pSize`) and parse **flat** `status: 1` responses.

---

# E. External (not tenant REST)

| Purpose | Notes |
|---------|--------|
| Google Maps | Key in `kGoogleApiKey` (`lib/utils/app_constants.dart`). `Mapit` is `"lat,lon"`. |
| Alert video replay page | `kVideDecodeUrl` — `ReplayAlarmServerVideo.html` with token, `deviceId`, channel, and file path |
| Live video | `LiveUrl` from vehicle payloads (`RealVideo.html`) |

Alert video URL pattern:

```
{kVideDecodeUrl}?token={kToken}&deviceId={UnitNo}&chs={channel}&fpath={encodedPath}
```

---

# F. Call sequence

```
GET  cntList
POST lngList { CountryId }
POST URLAuthorization { ClientName, Password }   → clientUrl, clientName
     └─ if sequel:
POST /api/Auth/UserLogin { loginName, loginPwd, language, theme }
POST /api/Vehicle/GetDashData { userId, pSize, pNo }
POST /api/Vehicle/historyTrackVehicle { userId, vehicleId, fromDatetime, toDatetime }
     other Sequel screens still use {clientUrl}...
     └─ else:
POST {clientUrl}auth/authUser { LoginName, LoginPwd }
POST {clientUrl}vehicle/dashCnt { UserId, pSize, PNo }
     then alerts / status / pin / video / history as needed
```

Optional on launch (saved client): `POST forceUpdateClient`.

---

# G. Source files

| Area | Path |
|------|------|
| URL constants | `lib/utils/app_constants.dart` |
| Sequel flag / routes | `lib/utils/app_globals.dart`, `lib/utils/app_routes.dart` |
| Client login | `lib/screens/login/repository/client_repo.dart` |
| User login | `lib/screens/login/repository/user_repo.dart` |
| Common dashboard | `lib/screens/dashboard/repository/dashboard_repo.dart` |
| Sequel dashboard | `lib/screens/dashboard/repository/sequel_dashboard_repo.dart` |
| Alerts | `lib/screens/alerts/respositroy/alert_repo.dart` |
| Dynamic status | `lib/screens/dynamic_status/respository/dyanmic_status_repo.dart` |
| Vehicle list / history | `lib/screens/vehicle_statuswise_list/repository/vehicle_status_repo.dart` |
| Pin | `lib/screens/pin_vehicles/repository/pin_vehicle_repo.dart` |
| Video | `lib/screens/video_playback/repository/video_playback_repo.dart` |
| Countries / languages | `lib/screens/language/repository/language_service.dart` |
| Force update | `lib/screens/splash/repository/splash_repo.dart` |
| Ads | `lib/screens/dashboard/repository/ads_repo.dart` |
| Forgot password | `lib/screens/forgot_password/repository/forgot_password_repo.dart` |
| Dio request/response logs | `lib/utils/app_helper.dart` (passwords redacted) |

---

# H. Run the app

```bash
flutter pub get
flutter run
```

Requires Flutter SDK `>=3.3.3` (see `pubspec.yaml`).
