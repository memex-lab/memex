# Conversation Memory

- 2026-06-18: Implementierte Windows/Desktop-Unterstützung (isMobile-Checks hinzugefügt, Health/Pedometer Plugins für Desktop deaktiviert).
- 2026-06-18: Implementierte vollständige deutsche Lokalisierung. Neue Datei `app_de.arb` (per Script übersetzt) und `app_localizations_ext_de.dart` mit deutschen KI-Prompts (für Tante, Bestie, Mentor, Mondschein, Beraterin). UI in `settings_page.dart` angepasst. Pull Request wurde erfolgreich gemerged.
- 2026-06-18: User hat das Projekt in einen neuen Ordner `memex-1` gezogen und den Translation-PR gepulled. Die Windows-Hacks gingen dabei verloren. Windows-Hacks in `main.dart`, `health_service.dart` und `photo_suggestion_service.dart` erneut hinzugefügt, damit die Windows-App wieder baut und startet.
