# Conversation Memory

- 2026-06-18: Implementierte Windows/Desktop-Unterstützung (isMobile-Checks hinzugefügt, Health/Pedometer Plugins für Desktop deaktiviert).
- 2026-06-18: Implementierte vollständige deutsche Lokalisierung. Neue Datei `app_de.arb` (per Script übersetzt) und `app_localizations_ext_de.dart` mit deutschen KI-Prompts (für Tante, Bestie, Mentor, Mondschein, Beraterin). UI in `settings_page.dart` angepasst.
- 2026-06-18: Mobile/Desktop Netzwerk-Fix für Ollama (Endpoint `/v1` und Host-IP `192.168.1.124` korrigiert).
- 2026-06-18: Windows/Web Crash-Fix für Kamera & Galerie im Input-Sheet (Fallback auf `image_picker` `pickMultiImage`).
- 2026-06-18: Fix für `save_timeline_card` Agent-Tool: Leere Titel werden nun akzeptiert, damit reine Bild-Karten von lokalen KIs ohne Absturz verarbeitet werden können. APK Build (globalDev) erfolgreich erstellt.
- 2026-06-19: UI Lokalisierung und dynamische KI-Sprache. Problem behoben, dass die App nach einem Sprachwechsel in den Einstellungen teilweise auf Englisch verblieb. `UserStorage.localeNotifier` (als `ValueNotifier<Locale>`) hinzugefügt, der bei `setLocale` aktualisiert wird. `MemexApp` nutzt nun einen `ValueListenableBuilder`, um die komplette App sofort bei Sprachwechsel neu zu rendern. Dadurch zieht nun auch dynamisch das korrekte `UserStorage.l10n.chatLanguageInstruction`, was der KI bei deutschen Nutzern anweist, auf Deutsch zu antworten.
