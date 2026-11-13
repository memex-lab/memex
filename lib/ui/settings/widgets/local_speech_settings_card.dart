import 'package:flutter/material.dart';
import 'package:memex/domain/models/local_speech.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/user_storage.dart';

class LocalSpeechSettingsCard extends StatelessWidget {
  const LocalSpeechSettingsCard({
    super.key,
    required this.useLocal,
    required this.engine,
    required this.language,
    required this.onEngineChanged,
    required this.onLanguageChanged,
  });

  final bool useLocal;
  final String engine;
  final String language;
  final ValueChanged<String> onEngineChanged;
  final ValueChanged<String> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    if (!useLocal) return const SizedBox.shrink();

    final l10n = UserStorage.l10n;
    final plan = planLocalSpeech(engine: engine, language: language);
    final selectedEngine = LocalSpeechEngines.normalize(engine);
    final selectedLanguage = LocalSpeechLanguages.normalize(language);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.localSpeechModelTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              key: const Key('local-speech-engine'),
              isExpanded: true,
              value: selectedEngine,
              items: [
                DropdownMenuItem(
                  value: LocalSpeechEngines.senseVoice,
                  child: Text(l10n.localSpeechModelSenseVoice),
                ),
                DropdownMenuItem(
                  value: LocalSpeechEngines.whisperTiny,
                  child: Text(l10n.localSpeechModelWhisper),
                ),
              ],
              onChanged: (value) {
                if (value != null) onEngineChanged(value);
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.localSpeechLanguageTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              key: const Key('local-speech-language'),
              isExpanded: true,
              value: selectedLanguage,
              items: [
                for (final option in localSpeechLanguageOptions)
                  DropdownMenuItem(
                    value: option.code,
                    child: Text(
                      option.code == localSpeechLanguageAuto
                          ? l10n.localSpeechLanguageAuto
                          : option.endonym,
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onLanguageChanged(value);
              },
            ),
            if (!plan.supported) ...[
              const SizedBox(height: 12),
              Text(
                l10n.localSpeechLanguageUnsupported,
                key: const Key('local-speech-language-hint'),
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
