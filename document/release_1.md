# InfoLocate — Release 1 Test Guide

**Product:** InfoLocate  
**App version:** 1.0.0  
**Release date:** 11 September 2026  
**Audience:** Testers / QA  
**Platforms:** Android / iOS (portrait)

Use this document to test each module. For every screen: **what to test**, then **validations the app already keeps**.

---

## How to use this guide

1. Follow the first-time flow once on a clean install.
2. Then test returning-user routing (kill and reopen the app).
3. For each module, run the **Feature to test** steps and confirm the **Validations kept**.
4. Tick the checklist at the end.

### First-time vs returning user

```
First install
  Splash → Language → Introduction → Client login → User login → Dashboard

Returning user (user session saved)
  Splash → Dashboard

Client logged in, user logged out
  Splash → User login

Language saved, no client
  Splash → Client login
```

**Logout** clears the **user** session only and returns to User Login. The client (tenant) stays saved.

**Drawer (after login):** Dashboard, Alerts, Dynamic Status, Live Vehicle, Track on Map, Video Playback, Settings, Logout.

---

## 1. Splash

### Feature to test

- Launch the app. Confirm branding, “Fleet tracking” subtitle, and about **5 seconds** of splash before navigation.
- Clean install (no saved session) → Language Selection.
- After Client Login only (no user) → kill app → User Login.
- After User Login → kill app → Dashboard (Sequel dashboard if the client is Sequel, otherwise Home).
- If a client session exists, a force-update dialog may appear (mandatory or optional).

### Validations kept

| Rule | Expected |
|------|----------|
| Dwell time | Splash waits ~5 seconds, then routes |
| User session exists | Opens Dashboard; splash is not shown again after that route |
| Client session only | Opens User Login |
| Language saved, no client | Opens Client Login |
| Nothing saved | Opens Language Selection |
| Force update (`forceupdate == 1`) | Mandatory update dialog; user must update |
| Force update optional | User can update or continue |

---

## 2. Introduction

### Feature to test

- After first language confirm, four slides appear: **Insights**, **Live video**, **Live tracking**, **Alerts**.
- Swipe between slides; page dots update.
- **Skip** on any slide → Client Login.
- Last slide **Get Started** → Client Login.
- From Settings, change language and confirm. Intro must **not** play again; user returns to Dashboard.

### Validations kept

| Rule | Expected |
|------|----------|
| Intro is first-run only | Shown after language when `inDrawer` is false |
| Skip / Get Started | Always go to Client Login |
| Settings language change | Goes to Dashboard, not Intro |

---

## 3. Language selection

### Feature to test

- Open country dropdown (flags), pick a country, wait for language list.
- Select a language, tap **Confirm**.
- First launch → Introduction.
- From Settings → Dashboard.
- Loading / error / empty country or language list: retry works.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| Confirm with no country | Toast: **Please select country** |
| Confirm with no language | Toast: **Please select language** |
| Country + language required | Confirm does nothing useful until both are set |
| Choice is saved | Next launch uses the saved language |

Supported languages: English, Arabic, Japanese, Spanish, Hindi, Kannada, Tamil, Telugu, Urdu, Bangla. Fallback is English.

---

## 4. Client login

### Feature to test

- Enter valid client username and password → User Login, with client name shown on the next screen.
- Toggle show / hide password.
- Wrong password / unknown client → stay on screen with error toast.
- Sequel client name or URL containing `"sequel"` → later screens use Sequel dashboard and Sequel APIs.
- Other tenants → Home dashboard and `{clientUrl}` APIs.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| Empty username | **Please enter username** |
| Username shorter than 3 or longer than 32 | **Please enter proper username** |
| Empty password | **Please enter password** |
| Password shorter than 3 or longer than 32 | **Please enter proper password** |
| Spaces | Typing a space is blocked (denied by input formatter) |
| Username length cap | Cannot type more than **48** characters |
| Password length cap | Cannot type more than **32** characters |
| Invalid credentials | Toast: **Incorrect Username or Password** (or API message) |
| Tenant URL empty or `NA` | Toast: **Couldn't login** |
| Form | Login is blocked until the form validates |

This step identifies the **tenant**. It is not the fleet operator login.

---

## 5. User login

### Feature to test

- Subtitle shows the client name from client login.
- Valid user → Dashboard.
- **Forgot password** opens the forgot-password screen.
- **Switch to client login** returns to Client Login (when not loading).
- Wrong user/password stays on the screen.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| Empty / invalid username | Same as client login: **Please enter username** / **Please enter proper username** (3–32 chars) |
| Empty / invalid password | **Please enter password** / **Please enter proper password** (3–32 chars) |
| Spaces | Blocked in both fields |
| Username / password caps | 48 / 32 characters |
| User does not belong to this client (non-Sequel, clientId mismatch) | Toast: **The user does not exist for this client** |
| API / network failure | Red error toast with the failure message |
| Sequel | Client-id mismatch check is skipped |

---

## 6. Forgot / reset password

### Feature to test

- From User Login, open Forgot password, enter username, Confirm.
- From Settings (when logged in), open Reset password.
- Success moves to the next confirmation / result screen.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| Empty / invalid username | **Please enter username** / **Please enter proper username** |
| Logged-in reset: username not equal to saved user | Toast: **Incorrect username** (request is not sent) |

---

## 7. Dashboard

### Feature to test

- After login, confirm the correct dashboard:
  - Sequel tenant → Fleet Dashboard (KPI grid, donut, alerts card, pin list, ~30s refresh).
  - Other tenant → Home (status cards, pie chart, alert cards, pins, ~10s refresh; ads if enabled).
- Tap **Total Vehicles** → All Vehicles list.
- Tap **Idle / Moving / Stopped / Inactive** (or any status tile) → list titled with that status.
- Confirm pager **loaded / dashboard total**. Example: Idle count **12** and page size **10** → first page **10 / 12**. Load more → **12 / 12**.
- Tap an alert type on the dashboard → Alerts already filtered to that type.
- Tap a pin / vehicle with location → map. Pull to refresh (Sequel) or wait for auto refresh.

### Validations kept

| Rule | Expected |
|------|----------|
| KPI total is the list denominator | Right-hand number is the dashboard count, **not** overwritten by the API page count (`recCnt`) |
| Loaded count is local | Left-hand number is how many rows are on screen; it grows after Load more |
| Page size | **10** vehicles per page |
| Load more | Shown while loaded count is still below the dashboard total and the last page returned rows |
| Search on the list | Pager hidden while searching; clear search reloads from page 1 with the same dashboard total |
| Alert tile | Opens Alerts with that `alertTypeId` |
| Logout from drawer | Back to User Login; client kept |

---

## 8. Dynamic status

### Feature to test

- Drawer → Dynamic Status.
- Cards show vehicle, status, location, time, speed, ignition, odometer, idle duration.
- Search by vehicle; empty search restores the list.
- Load more; page count **loaded / total**.
- Map It (needs location permission).
- Live video on a card that has a URL; card without video.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| Page size | **10**; search may request up to **100** |
| End of list (scroll) | Toast: **No more data** |
| No rows / no search match | **No Matching Records Found** |
| Live video missing | Toast: **Video Unavailable** |
| Map It without location | OS permission prompt; map opens only if granted |
| Background refresh | Every **10 seconds**, paused while the search box has text |

---

## 9. Alerts

### Feature to test

- Drawer → Alerts, or open from a dashboard alert tile.
- Default range is **today 00:00–23:59**.
- Filter by alert type (including **All**).
- Date filter: pick date, optionally from/to time, apply.
- Clear filter returns to the default day.
- Search by vehicle.
- Load more; empty and no-match states.
- Alert video affordance when the card has playback.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| From time missing (when time is enabled) | Toast: **Please select From time** |
| To time missing | Toast: **Please select To time** |
| From time after To time | Toast: **From Time should be less To Time** |
| From date-time in the future | Toast: **Selected From time should not be greater than current time** |
| To date-time in the future | Toast: **Selected To time should not be greater than current time** |
| End of list | Toast: **No more data** |
| No rows / no search match | **No Matching Records Found** |
| Page size | **10** |
| Dashboard deep link | List opens filtered by the tapped alert type, not always All |

---

## 10. Live vehicle

### Feature to test

- Drawer → Live Vehicle.
- Switch filter **Moving** / **Idle**.
- Search, load more, page count.
- Live video when the status allows it.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| End of list | Toast: **No more data** |
| Empty / no match | **No Matching Records Found** |
| Page size | **10** |
| Background refresh | Every **10 seconds**, paused while searching |
| Dashboard KPI total | Not applied here; live list uses API total |

---

## 11. Track on map

### Feature to test

- Drawer → Track on Map.
- First time: consent dialog **Grant Permission**, then OS location permission.
- Grant → fleet Google Map with markers.
- Deny → stay off the map.
- Filter **All** and other statuses.
- Tap a marker → vehicle location / details.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| No saved location consent | Dialog: Grant Permission before the OS prompt |
| Location denied | Map is not opened |
| Location granted | `Global.locationPermission` is stored; later opens go straight to the map |

---

## 12. Status-wise vehicle list (from dashboard)

### Feature to test

- From dashboard, tap Total / Idle / etc.
- Title matches the status.
- Pin / unpin, Map It, live video where enabled.
- Search and Load more.
- Pager **10 / 12** style as in Dashboard.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| Dashboard total | Right-hand pager number stays the KPI count |
| Loaded count | Left-hand number = rows currently in the list |
| End of list | Toast: **No more data** |
| Empty / no match | **No Matching Records Found** |
| Page size | **10** |

---

## 13. Track history

### Feature to test

- Track on Map → Track History (or history from a vehicle).
- Select vehicle, from date-time, to date-time, submit.
- Valid range → path replay on the map.
- Try invalid ranges below and confirm toasts.

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| Vehicle still “Select” | Toast: **Please select Vehicle Number** |
| From not chosen | Toast: **Please select From date and time** |
| To not chosen | Toast: **Please select To date and time** |
| From in the future | Toast: **Selected From time should not be greater than current time** |
| To in the future | Toast: **Selected To time should not be greater than current time** |
| From after To | Toast: **Please select proper date time** |
| Window 24 hours or more | Toast: **Time difference should not be greater than 24 hours** |
| Date picker range | From/To cannot be earlier than **94 days** back |
| API returns no points | Toast: **History data not available for selected period** |

---

## 14. Video playback

### Feature to test

- Drawer → Video Playback.
- Vehicle dropdown loads vehicle numbers.
- Pick vehicle, from, and to (last 7 days, **1 minute or less**), tap Generate.
- Success → in-app WebView plays `Purl` (not an external browser).
- Vehicle with no recording → toast, form stays (no stuck full-screen spinner).

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| No vehicle | Toast: **Please select Vehicle Number** |
| From not chosen | Toast: **Please select From date and time** |
| To not chosen | Toast: **Please select To date and time** |
| From in the future | Toast: **Selected From time should not be greater than current time** |
| To in the future | Toast: **Selected To time should not be greater than current time** |
| From after To | Toast: **Please select proper date time** |
| Window greater than 1 minute | Toast: **Time difference should not be greater than 1 minute** |
| Date picker range | From/To limited to the last **7 days** |
| Empty playback list or empty `Purl` | Toast: **No video available for the playback**; generate screen remains |
| Generate in progress | Button loading on the form; not a blocking full-screen loader |

---

## 15. Settings (supporting)

### Feature to test

- Dark mode on/off across login, dashboard, lists, alerts, video, map chrome.
- Language from Settings → dashboard, not intro.
- Card types: pick vehicle-status and alert-status layouts, Apply.
- Reset password (see section 6).

### Validations kept

| Condition | Message / behaviour |
|-----------|---------------------|
| Apply card types | Toast: **Card settings updated**, then pop |

---

## 16. Module test checklist

- [ ] Splash (clean install) → Language
- [ ] Splash (client only) → User login
- [ ] Splash (user session) → Dashboard
- [ ] Language: no country / no language toasts
- [ ] Intro: Skip and Get Started → Client login
- [ ] Settings language does not replay Intro
- [ ] Client login: empty fields, short username/password, spaces blocked, wrong password
- [ ] User login: same field rules; wrong tenant user (non-Sequel)
- [ ] Forgot password: incorrect username when logged in
- [ ] Sequel client → Sequel dashboard; other client → Home
- [ ] Dashboard Total / Idle open list with **loaded / dashboard total** (example 10/12)
- [ ] Load more increases loaded count; total stays the dashboard number
- [ ] Dashboard alert tile opens filtered Alerts
- [ ] Dynamic status: search, load more, **No more data**, **Video Unavailable**
- [ ] Alerts: today default, type filter, from/to time rules, future time blocked
- [ ] Live vehicle: Moving/Idle, load more
- [ ] Track on Map: grant vs deny location
- [ ] Track history: vehicle/dates required, 24-hour max, empty-history toast
- [ ] Video playback: 1-minute max, 7-day picker, empty playback toast, WebView opens
- [ ] Dark mode on the modules above
- [ ] Logout → User login; client name still shown

---

*End of release_1.md — 11 September 2026*
