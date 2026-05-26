# Dart Tips

Random Dart-specific gotchas worth keeping.

<!-- fact_id: fact_pkm_dart_001 -->
- `Future.wait` collects errors — wrap each future in try/catch if you need partial success.
- Records (3.0+) are great for return types but can't be const-constructed inline.
- `dart:io` is unavailable on web — abstract platform IO behind an interface for cross-platform packages.
