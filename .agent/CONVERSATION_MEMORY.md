# Conversation Memory

- 2026-06-18: Implementierte Windows/Desktop-Unterstützung (isMobile-Checks hinzugefügt, Health/Pedometer Plugins für Desktop deaktiviert).
- 2026-06-18: Implementierte vollständige deutsche Lokalisierung. Neue Datei `app_de.arb` (per Script übersetzt) und `app_localizations_ext_de.dart` mit deutschen KI-Prompts (für Tante, Bestie, Mentor, Mondschein, Beraterin). UI in `settings_page.dart` angepasst.
- 2026-06-18: Mobile/Desktop Netzwerk-Fix für Ollama (Endpoint `/v1` und Host-IP `192.168.1.124` korrigiert).
- 2026-06-18: Windows/Web Crash-Fix für Kamera & Galerie im Input-Sheet (Fallback auf `image_picker` `pickMultiImage`).
- 2026-06-18: Fix für `save_timeline_card` Agent-Tool: Leere Titel werden nun akzeptiert, damit reine Bild-Karten von lokalen KIs ohne Absturz verarbeitet werden können. APK Build (globalDev) erfolgreich erstellt.
- 2026-06-19: UI Lokalisierung und dynamische KI-Sprache. Problem behoben, dass die App nach einem Sprachwechsel in den Einstellungen teilweise auf Englisch verblieb. `UserStorage.localeNotifier` (als `ValueNotifier<Locale>`) hinzugefügt, der bei `setLocale` aktualisiert wird. `MemexApp` nutzt nun einen `ValueListenableBuilder`, um die komplette App sofort bei Sprachwechsel neu zu rendern. Dadurch zieht nun auch dynamisch das korrekte `UserStorage.l10n.chatLanguageInstruction`, was der KI bei deutschen Nutzern anweist, auf Deutsch zu antworten.

- **[2026-06-19] Log Viewer Export**: Added a 'Share' button (share_plus) to the LogViewerPage to allow exporting/downloading log files directly from the app on mobile devices.

- **[2026-06-19] Log Viewer Export Fix**: Updated LogViewerPage to copy the log file to getTemporaryDirectory() before sharing, resolving an issue where Android devices failed to share files directly from the app's internal documents directory.

- **[2026-06-19] Log Viewer UI Update**: Moved the 'Share' button from the top AppBar to the bottom right FloatingActionButton stack, as requested by the user for better accessibility.
- **[2026-06-19] Log Viewer FAB Layout Fix**: Fixed a rendering issue where the Share FloatingActionButton was hidden on Android. Added `mainAxisSize: MainAxisSize.min` to the FAB Column to prevent layout boundary truncation.
