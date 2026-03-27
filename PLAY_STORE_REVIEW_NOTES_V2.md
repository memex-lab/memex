# Google Play Store Review Notes — V2

## Issue 5: App Access — Missing Demo / Guest Account Details

**Status**: Fixed

Google Play rejected because reviewers couldn't access app functionality without login credentials.

**Resolution**: Added App Access instruction in Play Console.

- Selected: "All or some functionality in my app is restricted"
- Instruction name: `AI Feature Access - OpenRouter API Key`
- Provided an OpenRouter API key with step-by-step setup instructions for reviewers
- Model: `anthropic/claude-opus-4.6`

Instruction text:

> No login required. To enable AI features:
>
> 1. Open app → tap "Get Started"
> 2. Select "OpenRouter" as Provider
> 3. Enter API Key: {openrouter_apikey}
> 4. Select Model: anthropic/claude-opus-4.6
> 5. Keep default base URL → tap Save
>
> You can now use all features:
> - Center sparkle button: create records (text/photo/voice)
> - Timeline: view AI-generated cards
> - Insight: cross-record analysis
> - Chat: AI assistant
>
> All data stored locally on-device.

---

## Issue 6: All Files Access Permission — Not a Core Feature

**Status**: Appealing with updated declaration

Google rejected MANAGE_EXTERNAL_STORAGE claiming the dependent feature is not core functionality.

**Resolution**: Updated Permission Declaration Form and store listing.

### Permission Declaration Form

All files access:

> File management — Memex is a local-first knowledge management app with no cloud storage. All data (cards, knowledge base, media, database) is stored on-device only. Users choose a custom workspace folder in Settings to persist data outside the app sandbox, so data survives uninstall/reinstall. This is the only data recovery mechanism — without it, all data is permanently lost on uninstall. The app manages structured files (YAML, HTML, Markdown, media) in the user-chosen directory.

Usage: Core functionality

Technical reason:

> Users choose a custom workspace folder in Settings > Data Storage. The app creates subdirectories (Cards, PKM, Facts, assets, ChatSessions) and reads/writes YAML, HTML, Markdown, and media files. MANAGE_EXTERNAL_STORAGE is needed on Android 11+ because user-chosen paths may be outside scoped storage. SAF content URIs are incompatible with the SQLite database engine which requires direct file access. Permission is only requested when the user explicitly selects a custom location.

### Store Listing Update

Added "Storage & Backup" section to Play Store full description:

> 📂 Storage & Backup
> • Choose where your data lives: iCloud Drive (iOS), custom folder, or app storage
> • Custom folder keeps your data safe across app reinstalls — no cloud required
> • One-tap full backup and restore

Fallback plan if appeal is rejected: Remove MANAGE_EXTERNAL_STORAGE, keep only app-sandbox storage on Android, and rely on in-app backup/restore (export zip) as the data recovery mechanism.

---

## Issue 7: Health Connect Permissions — Not a Permitted Use Case

**Status**: Fixed (removed Health Connect on Android)

Google rejected Health Connect permissions stating the app's use case does not fall within approved use cases. Memex is primarily a PKM app, not a health/fitness app, so the appeal was unlikely to succeed.

**Resolution**: Removed all Health Connect permissions and dependencies on Android. Step counting is preserved via `ACTIVITY_RECOGNITION` + `pedometer` package (sensor-based, no Health Connect needed). iOS HealthKit remains fully functional.

### AndroidManifest.xml changes

Removed:
- All 10 `android.permission.health.READ_*` permissions (STEPS, HEART_RATE, RESTING_HEART_RATE, BLOOD_PRESSURE, OXYGEN_SATURATION, BLOOD_GLUCOSE, SLEEP, ACTIVE_CALORIES_BURNED, WEIGHT, EXERCISE)
- Health Connect intent filter (`android.intent.action.VIEW_PERMISSION_USAGE` + `HEALTH_PERMISSIONS`)
- Health Connect package query (`com.google.android.apps.healthdata`)

Kept:
- `android.permission.ACTIVITY_RECOGNITION` (for pedometer-based step counting)

### Code changes

- `lib/data/services/health_service.dart`:
  - `_registerStrategies()`: Android registers only STEPS with `PedometerFetcher` as primary. iOS registers all health types with `HealthKitFetcher`.
  - `requestAllPermissions()`: Android skips Health Connect authorization, only requests pedometer permission. iOS unchanged.
  - Added `registeredTypes` getter to expose platform-specific type list.

- `lib/main.dart`:
  - `_checkAndReportHealthData()`: Uses `healthService.registeredTypes` instead of hardcoded list of all types.

- `lib/data/services/health_strategies.dart`:
  - Removed Android-specific sleep types from `HealthKitFetcher` (no longer used on Android).

### Impact

- Android: Only step count data is collected (via device motion sensor). No Health Connect dependency.
- iOS: Full HealthKit support unchanged (steps, heart rate, blood pressure, sleep, workouts, etc.).
