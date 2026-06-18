# Conversation Memory

- 2026-06-18: Implementierte Windows/Desktop-Unterstützung (isMobile-Checks hinzugefügt, Health/Pedometer Plugins für Desktop deaktiviert).
- 2026-06-18: Implementierte vollständige deutsche Lokalisierung. Neue Datei `app_de.arb` (per Script übersetzt) und `app_localizations_ext_de.dart` mit deutschen KI-Prompts (für Tante, Bestie, Mentor, Mondschein, Beraterin). UI in `settings_page.dart` angepasst.
- 2026-06-18: Mobile/Desktop Netzwerk-Fix für Ollama (Endpoint `/v1` und Host-IP `192.168.1.124` korrigiert).
- 2026-06-18: Windows/Web Crash-Fix für Kamera & Galerie im Input-Sheet (Fallback auf `image_picker` `pickMultiImage`).
- 2026-06-18: Fix für `save_timeline_card` Agent-Tool: Leere Titel werden nun akzeptiert, damit reine Bild-Karten von lokalen KIs ohne Absturz verarbeitet werden können. APK Build (globalDev) erfolgreich erstellt.
