# Google Play Store Review Notes

## Issue 1: Privacy Policy — Invalid Privacy Policy (Data Deletion)

**Status**: Fixed

Changes made:
- Added "Data Retention and Deletion" section to both PRIVACY_POLICY.md and PRIVACY_POLICY_CN.md
- Clearly states data retention policy (local-only, no server-side retention)
- Describes how to delete individual records (in-app deletion)
- Describes how to delete all data (uninstall or clear app data in system settings)
- Addresses third-party LLM provider data deletion
- Added contact email: support@memexlab.ai
- Updated date to 2026-03-17

Additional privacy policy improvements:
- Fixed contradictory "Data Collection" wording (was claiming no data leaves device, but LLM usage does send data)
- Added missing permission disclosures: Location, Calendar, Reminders, Notifications, Storage, Network, Activity Recognition
- Expanded Health/Fitness data types to list all specific types read (heart rate, blood pressure, blood oxygen, blood glucose, sleep, weight, etc.)
- Added Reminders (iOS) permission disclosure

Code changes:
- Removed unused `READ_CALENDAR` permission from AndroidManifest.xml (app only writes calendar events, never reads)
- Removed unused `PACKAGE_USAGE_STATS` permission from AndroidManifest.xml (declared but never used in code)

---

## Issue 2: Photo and Video Permissions — READ_MEDIA_IMAGES not directly related to core purpose

**Status**: Appealing with declaration

Declaration for Play Console permission request:

> Memex is an AI-native personal knowledge management app. Its core functionality is to automatically discover, analyze, and organize the user's daily records — including photos — into structured timeline cards using on-device AI.
>
> The app requires persistent access to the photo library (`READ_MEDIA_IMAGES`) because:
>
> 1. Memex continuously monitors the user's photo library to detect newly taken photos and automatically processes them using on-device OCR (Google ML Kit Text Recognition) and image labeling (Google ML Kit Image Labeling) to extract text content, scene labels, GPS coordinates, and timestamps.
>
> 2. These extracted features are used to intelligently cluster related photos and generate structured timeline cards (e.g., place visits, events, gallery collections) without requiring manual user input.
>
> 3. This automatic photo discovery and AI-powered organization is the primary input mechanism of the app — it is not a secondary or optional feature. Without persistent photo library access, the app's core value proposition of automatic life logging and knowledge extraction cannot function.
>
> 4. All photo processing happens entirely on-device. No photo data is uploaded to any external server.
>
> The Android Photo Picker is not a viable alternative because it requires explicit user action for each selection, which defeats the purpose of automatic, passive photo discovery that is central to the app's design.

Fallback plan if appeal is rejected: Remove `READ_MEDIA_IMAGES`, keep `READ_MEDIA_VISUAL_USER_SELECTED` for Android 14+ partial access mode, and disable auto photo suggestion on Android 13.

---

## Issue 3: Health Connect Permissions — Not a permitted/valid use case

**Status**: Appealing with updated declaration

**Approved use case category**: Fitness, wellness and coaching

Per Google's [Android Health Permissions: Guidance and FAQs](https://support.google.com/googleplay/android-developer/answer/12991134), the "Fitness, wellness and coaching" category covers apps that help users "track, monitor, analyze, manage, and improve their physical fitness, general wellbeing" including "aggregating data from various user sources (apps, wearables) for a holistic view and long-term trend analysis" and "analyzing sleep health and patterns."

Declaration for Play Console Health Connect permission request:

> **Approved Use Case: Fitness, Wellness and Coaching**
>
> Memex is a local-first personal knowledge management app with integrated health and wellness tracking. It reads Health Connect data to help users monitor, analyze, and gain insights into their physical fitness and general wellbeing over time.
>
> **How Health Connect data is used:**
>
> 1. **Daily health aggregation and trend tracking**: Memex periodically reads the user's health metrics from Health Connect — including steps, heart rate, resting heart rate, blood pressure, blood oxygen, blood glucose, sleep, active energy burned, weight, and workout records — and aggregates them into structured daily health summaries displayed on the user's personal timeline.
>
> 2. **Long-term trend analysis and pattern recognition**: The aggregated health data is analyzed by the app's AI engine to identify patterns and trends across days and weeks. For example, the app can detect correlations between sleep quality and activity levels, or surface changes in resting heart rate over time.
>
> 3. **Cross-dimensional wellness insights**: Health data is correlated with the user's other life records (activity logs, schedules, notes) to generate holistic wellness insights — such as identifying that a specific project deadline consistently disrupts sleep patterns, or that exercise frequency correlates with productivity.
>
> 4. **Personalized timeline cards**: Health metrics are transformed into structured, visual timeline cards (e.g., daily health summary cards, workout cards, sleep analysis cards) that users can browse, search, and reflect on.
>
> **Data handling and privacy:**
>
> - All health data is stored locally on the user's device in an encrypted SQLite database. No health data is uploaded to any server operated by us.
> - Health data may be sent to a third-party LLM provider (e.g., Google Gemini, OpenAI) only when the user explicitly configures an API key and only for the purpose of generating health insights and timeline cards. Users are informed of this in the app's privacy policy.
> - Users can delete any health-related record at any time within the app. Uninstalling the app permanently removes all locally stored health data.
> - The app provides a comprehensive privacy policy that details all data collection, usage, storage, and deletion practices.
>
> **Permissions requested and justification:**
>
> | Permission | Justification |
> |---|---|
> | `READ_STEPS` | Track daily step counts and display on timeline; analyze activity trends |
> | `READ_HEART_RATE` | Monitor heart rate during activities; detect long-term cardiovascular trends |
> | `READ_RESTING_HEART_RATE` | Track baseline resting heart rate for wellness trend analysis |
> | `READ_BLOOD_PRESSURE` | Record blood pressure readings on timeline; identify hypertension patterns |
> | `READ_OXYGEN_SATURATION` | Track blood oxygen levels; correlate with sleep and activity data |
> | `READ_BLOOD_GLUCOSE` | Log glucose readings on timeline for users managing metabolic health |
> | `READ_SLEEP` | Analyze sleep duration and quality; correlate with daily activities |
> | `READ_ACTIVE_CALORIES_BURNED` | Track energy expenditure; combine with activity data for fitness insights |
> | `READ_WEIGHT` | Monitor weight changes over time on the personal timeline |
> | `READ_EXERCISE` | Record workout sessions; analyze exercise frequency and intensity trends |
>
> Each permission is directly tied to a user-facing health tracking and insight feature. No permission is requested beyond what is needed for the health timeline and wellness insight functionality.

Fallback plan if appeal is rejected: Remove all Health Connect permissions from AndroidManifest.xml and disable health features on Android. Keep health features on iOS via HealthKit (which has separate review rules). Specific changes needed:
- Remove all `android.permission.health.READ_*` entries from AndroidManifest.xml
- Remove the Health Connect intent filter (`android.intent.action.VIEW_PERMISSION_USAGE` + `HEALTH_PERMISSIONS`)
- Remove the `<package android:name="com.google.android.apps.healthdata"/>` query
- Add platform check in `HealthService` to skip Health Connect on Android
- Keep `ACTIVITY_RECOGNITION` + pedometer for basic step counting on Android

---

## Issue 4: Broken Functionality — Unresponsive UI elements

**Status**: Fixed

Root cause: When no AI model is configured (fresh install), the main sparkle button (bottom center) only showed a brief toast message "Please configure an AI model before publishing" with no further action. Google reviewers interpreted this as an unresponsive button.

Fix: Changed the sparkle button behavior to show a dialog with a clear "Model Config" button that navigates directly to the model configuration page. This ensures the reviewer can immediately understand the button works and find the setup flow.

Code change: `lib/main.dart` — `_handleAICoreButtonTap()` now shows an AlertDialog instead of a toast when model is not configured.

Additional improvement: Added configuration status indicator to each item in the Model Configuration list page (`lib/ui/settings/widgets/model_config_list_page.dart`). Each config now shows a green "Configured" or orange "API Key not set — tap to configure" hint, making it immediately clear which configs need attention.

New l10n keys added: `configured`, `apiKeyNotSet` (in both `app_en.arb` and `app_zh.arb`).

Additionally, for Play Console submission, provide testing instructions:
> This app requires a user-provided AI API key to function. After installing, tap the "Configure Now" banner or the center sparkle button, then go to Model Config to add an API key (e.g., Google Gemini API key from https://aistudio.google.com/apikey). Once configured, all features become functional.
