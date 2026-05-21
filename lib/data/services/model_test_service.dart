import 'dart:async';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/logger.dart';

final _log = getLogger('ModelTestService');

/// The type of model test to perform.
enum ModelTestType {
  /// Basic text connectivity test.
  text,

  /// Vision/multimodal test — sends a small image and asks the model to describe it.
  vision,
}

/// Result of a model connectivity test.
class ModelTestResult {
  final bool success;
  final ModelTestType testType;
  final Duration responseTime;
  final String? responseText;
  final String? error;
  final String? model;

  const ModelTestResult({
    required this.success,
    required this.testType,
    required this.responseTime,
    this.responseText,
    this.error,
    this.model,
  });
}

/// Service for testing LLM model connectivity and functionality.
class ModelTestService {
  /// A minimal 64x64 PNG image: red circle on white background.
  /// Used as the test image for vision capability verification.
  /// 64x64 is safely above any provider's minimum size threshold while
  /// keeping the base64 payload tiny (~400 chars). The red circle is
  /// simple enough for any vision model to describe correctly.
  static const _testImageBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAA90lEQVR4nO3aOxKDUAxDU'
      'fa/6SRdJkVA8k+Phzy02PcMLcfr5nOoA7JjgHoMUI8B6ukHHL0nqrd/cpGn8GDRGqy7QZ'
      'JeEU4vYiReLklPM6KA8vqoIQRoqg8ZeEBrPW8gAQP1pIEBjNUzBhgwXA8bMICkHjM8AS'
      'CsBwzbA+T1VwYDlgbIuwGDAQYYsC1AXowZNv4CBhhggD46C1jHcBJowOKAFQzndQ8AaA'
      '2Xac8AqAxIFwqYN4BRBGDSgBdxgBkDlUMDug1sSwTQZwiEBAEdhlhFHFDIyNzPApKM/OX'
      '8it99Q93fg4W7/ly41/9C42OAegxQjwHqeQNx8d3ytD3rzgAAAABJRU5ErkJggg==';

  /// Test an LLM configuration by sending a minimal request.
  ///
  /// [testType] controls whether to test basic text or vision capability.
  /// Uses [UserStorage.buildLLMResources] to construct the client — same path
  /// as production agent calls — so the test validates real-world behavior.
  static Future<ModelTestResult> testConfig(
    LLMConfig config, {
    ModelTestType testType = ModelTestType.text,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      if (!config.isValid) {
        stopwatch.stop();
        return ModelTestResult(
          success: false,
          testType: testType,
          responseTime: stopwatch.elapsed,
          error: UserStorage.l10n.invalidConfigurationWarning,
        );
      }

      final resources = await UserStorage.buildLLMResources(config);
      final messages = _buildTestMessages(testType);

      final response = await resources.client
          .generate(messages, modelConfig: resources.modelConfig)
          .timeout(const Duration(seconds: 30));

      stopwatch.stop();

      final text = response.textOutput?.trim() ?? '';
      if (text.isEmpty) {
        return ModelTestResult(
          success: false,
          testType: testType,
          responseTime: stopwatch.elapsed,
          error: 'Empty response from model',
          model: response.model,
        );
      }

      _log.info(
        'Model test ($testType) success: ${config.type}/${config.modelId} '
        'in ${stopwatch.elapsedMilliseconds}ms',
      );

      return ModelTestResult(
        success: true,
        testType: testType,
        responseTime: stopwatch.elapsed,
        responseText: text.length > 150 ? '${text.substring(0, 150)}...' : text,
        model: response.model,
      );
    } on TimeoutException {
      stopwatch.stop();
      return ModelTestResult(
        success: false,
        testType: testType,
        responseTime: stopwatch.elapsed,
        error: 'Request timed out (30s)',
      );
    } catch (e) {
      stopwatch.stop();
      _log.warning(
          'Model test ($testType) failed: ${config.type}/${config.modelId}: $e');

      String errorMsg = e.toString();
      errorMsg = errorMsg
          .replaceFirst('Exception: ', '')
          .replaceFirst('FormatException: ', '');
      if (errorMsg.length > 200) {
        errorMsg = '${errorMsg.substring(0, 200)}...';
      }

      return ModelTestResult(
        success: false,
        testType: testType,
        responseTime: stopwatch.elapsed,
        error: errorMsg,
      );
    }
  }

  /// Build the message list for the given test type.
  static List<LLMMessage> _buildTestMessages(ModelTestType testType) {
    switch (testType) {
      case ModelTestType.text:
        return [
          SystemMessage(
              'You are a helpful assistant. Follow instructions precisely.'),
          UserMessage([TextPart('Reply with "ok" only.')]),
        ];
      case ModelTestType.vision:
        return [
          SystemMessage(
              'You are a vision assistant. Describe images concisely.'),
          UserMessage([
            TextPart(
                'Describe this image in one short sentence (10 words max).'),
            ImagePart(_testImageBase64, 'image/png'),
          ]),
        ];
    }
  }
}
