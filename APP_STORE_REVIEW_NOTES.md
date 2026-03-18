# App Store Review Notes

Submission ID: 7fe53318-5fdb-4de9-9a82-109c3b23af45
Review date: 2026-03-17
Review device: iPad Air 11-inch (M3)
Version reviewed: 1.0

---

## Issue 1: Permission Purpose Strings — Guideline 5.1.1(ii)

**Status**: DONE

**Problem**: Camera, photo library, microphone, and location purpose strings in Info.plist do not sufficiently explain the use of protected resources. Must clearly describe usage and provide a specific example.

**Fix**: Updated `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSMicrophoneUsageDescription`, `NSLocationWhenInUseUsageDescription`, and `NSLocationAlwaysAndWhenInUseUsageDescription` in `ios/Runner/Info.plist` with detailed descriptions including specific usage examples.

**Files changed**: `ios/Runner/Info.plist`

---

## Issue 2: Account Deletion — Guideline 5.1.1(v)

**Status**: DONE

**Problem**: App supports account creation but does not include an option to initiate account deletion. Apple requires apps with account creation to also offer account deletion.

**Fix**: Added "Delete Account" option in Settings page. The flow:
1. User taps "Delete Account" in Settings
2. Confirmation dialog requires typing the username to confirm
3. On confirm: closes database, deletes workspace files, clears all SharedPreferences, navigates back to setup screen

**Files changed**: `lib/ui/settings/widgets/settings_page.dart`, `lib/utils/user_storage.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_zh.arb`

---

## Issue 3: Third-Party AI Data Sharing Disclosure — Guidelines 5.1.1(i) & 5.1.2(i)

**Status**: DONE

**Problem**: App shares user data with third-party AI services (LLM providers) but does not:
1. Clearly explain what data is sent
2. Identify who the data is sent to
3. Ask the user's permission before sharing

**Fix**: Added in-app consent dialog that appears when user first saves a valid LLM configuration (both in Settings and during onboarding). The dialog clearly states:
- What data is sent (text input, photo metadata/OCR, health summaries, card content)
- Who it is sent to (the specific provider being configured)
- That data goes directly from device to provider, not through Memex servers
- Requests explicit consent before proceeding

Consent state is stored in SharedPreferences (`llm_data_sharing_consent`). The dialog only appears once — subsequent config changes don't re-prompt.

**Files changed**: `lib/ui/settings/widgets/model_config_edit_page.dart`, `lib/ui/user_setup/widgets/setup_model_config_page.dart`, `lib/utils/user_storage.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_zh.arb`
