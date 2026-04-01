# Privacy Policy

Last updated: 2026-03-18

## Overview

Memex ("the App") is a local-first AI-powered personal life recording application. We are committed to protecting your privacy. This policy explains how the App handles your data.

## Data Collection

Memex is designed as a local-first application. All data you create in the App — including text, photos, voice recordings, and AI-generated content — is stored on your device by default.

Memex does not operate its own servers and does not collect or store your personal data on any server controlled by us. The only circumstance in which your data leaves your device is when you explicitly configure and use a third-party LLM provider (see "Third-Party Services" below).

## Third-Party Services

Memex connects to third-party LLM (Large Language Model) providers only when you explicitly configure an API key. These providers may include:

- Google Gemini — [Privacy Policy](https://policies.google.com/privacy)
- OpenAI — [Privacy Policy](https://openai.com/privacy)
- Anthropic Claude — [Privacy Policy](https://www.anthropic.com/privacy)
- AWS Bedrock — [Privacy Policy](https://aws.amazon.com/privacy/)
- Kimi (Moonshot) — [Privacy Policy](https://www.kimi.com/user/agreement/userPrivacy)
- Aliyun Qwen — [Privacy Policy](https://terms.aliyun.com/legal-agreement/terms/suit_bu1_ali_cloud/suit_bu1_ali_cloud202107091605_49213.html)
- Volcengine (Doubao/Seed) — [Privacy Policy](https://www.volcengine.com/docs/6256/64902?lang=zh)
- Zhipu GLM — [Privacy Policy](https://docs.bigmodel.cn/cn/terms/privacy-policy)
- MiniMax — [Privacy Policy](https://platform.minimaxi.com/protocol/privacy-policy)
- Xiaomi MIMO — [Privacy Policy](https://platform.xiaomimimo.com/#/docs/terms/privacy-policy)
- OpenRouter, Ollama, and other aggregator/local inference platforms

When you use any of these services, the following types of data may be sent directly from your device to the provider you selected:

- Text you enter (records, voice transcriptions)
- Photo metadata and text extracted by on-device OCR
- Health and fitness summaries (if you have enabled health data collection)
- Timeline card content used for AI analysis and insight generation

This data is sent directly from your device to the provider. Memex does not relay, store, or process your data through any intermediary server. This is the only scenario in which data leaves your device. Please refer to each provider's own privacy policy (linked above) for details on how they handle your data.

## Device Permissions

Memex may request the following device permissions. All data obtained through these permissions is processed and stored locally on your device and is never uploaded to our servers.

- **Camera** — Used to take photos for your records.
- **Microphone** — Used for voice recording.
- **Photo Library / Media** — Used to select existing photos from your device for your records.
- **Location** — Used to read GPS metadata embedded in photos for place-based records, and to allow you to pick a location on the map when editing a record. Memex does not track your location in the background. Location data is stored locally and is not transmitted externally.
- **Calendar** — Used to write calendar events to your device's system calendar when the AI agent identifies scheduling intent from your input. Memex does not read from your system calendar.
- **Reminders (iOS)** — Used to create reminders on your device when the AI agent identifies reminder intent from your input. Memex does not read your existing reminders.
- **Health / Fitness (Health Connect on Android, HealthKit on iOS)** — Used to read health and fitness data when you enable this feature. The specific data types include: steps, heart rate, resting heart rate, blood pressure (systolic and diastolic), blood oxygen, blood glucose, sleep, active energy burned, weight, and workout/exercise records. All health data is stored locally and is not transmitted externally.
- **Activity Recognition** — Used for step counting via the device pedometer as a fallback when Health Connect / HealthKit data is unavailable.
- **Biometrics (Face ID / Touch ID / Fingerprint)** — Used for App Lock authentication. Biometric data is handled entirely by the operating system; Memex does not access or store your biometric data.
- **Notifications** — Used to deliver local reminders and background task status updates. No push notification service or external server is involved.
- **Storage / Files** — Used to store your local database, media files, and exported data on your device. On Android 11+, if you choose a custom workspace folder in Settings > Data Storage, the App requests All Files Access (MANAGE_EXTERNAL_STORAGE) to read and write your workspace files (timeline cards, knowledge base, media assets) in the folder you selected. This permission is only requested when you explicitly choose a custom storage location. If you use the default app storage, this permission is not required.
- **Internet / Network** — Used solely to communicate with the third-party LLM provider you configure. No data is sent to any server operated by us.

## On-Device Processing

The following features run entirely on your device and do not send data externally:

- OCR text recognition (Google ML Kit, on-device)
- Image labeling and scene detection (Google ML Kit, on-device)
- EXIF metadata extraction from photos (including GPS location)
- Local database storage (SQLite via Drift)
- Step counting via device pedometer

## Analytics & Tracking

Memex does not include any analytics, tracking, or advertising SDKs.

## Data Retention and Deletion

All your data is stored locally on your device. Memex does not retain any data on external servers.

- **Retention**: Your data remains on your device for as long as you keep the App installed and choose to retain it. There is no server-side retention period because no data is transmitted to or stored on our servers.
- **Deleting individual records**: You can delete any record (text, photo, voice recording, card, knowledge entry, etc.) directly within the App at any time. Deleted records are permanently removed from the local database and cannot be recovered.
- **Deleting all data**: You can delete all your data by using the "Delete Account" option in Settings, which permanently erases the local database, workspace files, and all preferences, and resets the app to its initial state. Alternatively, you can uninstall Memex or clear the app's data through your device's system settings.
- **Third-party LLM providers**: Any data previously sent to a third-party LLM provider during AI interactions is subject to that provider's own data retention and deletion policies. Please refer to the provider's privacy policy (linked above) for instructions on how to request deletion of data they may have processed.

## Children's Privacy

Memex does not knowingly collect any information from children under the age of 13.

## Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be posted in this document with an updated date.

## Contact

If you have questions about this Privacy Policy, please contact us at:

- Email: support@memexlab.ai
- GitHub: https://github.com/memex-lab/memex/issues
