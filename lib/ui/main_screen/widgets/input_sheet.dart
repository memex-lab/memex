import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/photo_suggestion_service.dart';
import 'package:memex/data/services/whisper_service.dart';
import 'package:memex/data/services/streaming_transcriber.dart';
import 'package:memex/data/services/speech_transcription_service.dart';
import 'package:memex/data/services/input_draft_service.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/data/services/demo_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

/// Input data model for submission
class InputData {
  final String? text;
  final List<XFile> images;
  final String? audioPath;
  final Map<String, String> imageCaptions; // path -> caption
  final List<String>? imageHashes;
  final String? audioHash;
  final String? textHash;

  InputData({
    this.text,
    this.images = const [],
    this.audioPath,
    this.imageCaptions = const {},
    this.imageHashes,
    this.audioHash,
    this.textHash,
  });

  bool get isEmpty =>
      (text == null || text!.trim().isEmpty) &&
      images.isEmpty &&
      audioPath == null;
}

/// Input sheet for creating new entries
class InputSheet extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Future<bool> Function(InputData data) onSubmit;
  final InputData? initialData;
  const InputSheet({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onSubmit,
    this.initialData,
  });

  @override
  State<InputSheet> createState() => _InputSheetState();
}

class _InputSheetState extends State<InputSheet>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _pulseController;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _textScrollController = ScrollController();

  void _scrollTextToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_textScrollController.hasClients) {
        _textScrollController.jumpTo(
          _textScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Logger _logger = getLogger('InputSheet');
  final InputDraftService _draftService = InputDraftService.instance;

  StreamingTranscriber? _streamingTranscriber;
  StreamSubscription<Uint8List>? _audioStreamSub;
  Timer? _draftSaveDebounce;
  // Accumulated PCM data for saving as WAV after recording stops
  final List<int> _pcmBuffer = [];
  // Text in the text field before recording started (to preserve user-typed text)
  String _preRecordingText = '';

  List<XFile> _selectedImages = [];
  final Map<String, String> _originalFilenames = {};
  String? _audioPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordingDuration = Duration.zero;
  Duration _audioDuration = Duration.zero;
  List<String> _detectedTags = [];

  List<List<EnhancedPhoto>>? _autoClusters;
  bool _isLoadingAuto = false;
  bool _isApplyingDraft = false;
  bool _isRestoredDraft = false;
  bool _isSubmitting = false;
  final Map<String, AssetEntity> _assetsMap = {}; // path -> AssetEntity

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isOpen) {
      _controller.forward();
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textController.addListener(_onTextChanged);

    _audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
      });
    });

    if (widget.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isOpen) {
          _prepareForOpen();
        }
      });
    }
  }

  @override
  void didUpdateWidget(InputSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _logger.info('Opening InputSheet');
        _controller.forward();
        _prepareForOpen();
      } else {
        _controller.reverse();
      }
    } else if (widget.isOpen &&
        widget.initialData != null &&
        widget.initialData != oldWidget.initialData) {
      // Sheet already open but new share arrived: reload with shared data
      _logger.info('InputSheet already open, reloading with new shared data');
      _applyInitialData(widget.initialData);
      _scheduleDraftSave();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _flushDraft();
    }
  }

  Future<void> _prepareForOpen() async {
    if (widget.initialData != null && !widget.initialData!.isEmpty) {
      _resetForm();
      _applyInitialData(widget.initialData);
      _scheduleDraftSave();
    } else {
      await _restoreDraft();
    }
    if (!mounted || !widget.isOpen) return;
    _fetchAutoClusters();
  }

  Future<void> _restoreDraft() async {
    _resetForm();
    final draft = await _draftService.loadActiveDraft();
    if (!mounted || !widget.isOpen) return;

    if (draft == null) {
      _setRestoredDraft(false);
      return;
    }

    _isApplyingDraft = true;
    _textController.text = draft.text;
    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );
    _isApplyingDraft = false;
    _updateDetectedTags(draft.text);
    _setRestoredDraft(true);
    _scrollTextToBottom();
  }

  void _applyInitialData(InputData? data) {
    if (data == null) return;

    final text = data.text ?? '';
    _isApplyingDraft = true;
    _textController.text = text;
    _textController.selection = TextSelection.collapsed(offset: text.length);
    _isApplyingDraft = false;
    _audioPlayer.stop();

    final regex = RegExp(r'#([^\s#]+)');
    final tags =
        regex.allMatches(text).map((m) => m.group(1)!).toSet().toList();

    setState(() {
      _selectedImages = List<XFile>.from(data.images);
      _originalFilenames.clear();
      _audioPath = data.audioPath;
      _isRecording = false;
      _isPlaying = false;
      _recordingDuration = Duration.zero;
      _audioDuration = Duration.zero;
      _detectedTags = tags;
      _autoClusters = null;
      _isLoadingAuto = false;
    });
    _setRestoredDraft(false);

    _loadAudioDuration();
  }

  void _resetForm() {
    _draftSaveDebounce?.cancel();
    _isApplyingDraft = true;
    _textController.clear();
    _isApplyingDraft = false;
    _audioPlayer.stop();
    setState(() {
      _selectedImages = [];
      _originalFilenames.clear();
      _audioPath = null;
      _isRecording = false;
      _isPlaying = false;
      _recordingDuration = Duration.zero;
      _audioDuration = Duration.zero;
      _detectedTags = [];
      _autoClusters = null;
      _isLoadingAuto = false;
      _isRestoredDraft = false;
      _isSubmitting = false;
    });
  }

  Future<void> _fetchAutoClusters() async {
    setState(() {
      _isLoadingAuto = true;
      _autoClusters = null;
    });
    try {
      final clusters =
          await PhotoSuggestionService.fetchAndClusterRecentPhotos();
      if (mounted) {
        setState(() {
          _autoClusters = clusters;
          _isLoadingAuto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAuto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load suggestions: $e')),
        );
      }
    }
  }

  void _addClusterToSelection(List<EnhancedPhoto> cluster) {
    setState(() {
      // Check if all items in this cluster are already selected
      bool allSelected = true;
      for (final photo in cluster) {
        if (!_selectedImages.any((x) => x.path == photo.xFile.path)) {
          allSelected = false;
          break;
        }
      }

      if (allSelected) {
        // If all are selected, deselect them all
        for (final photo in cluster) {
          _selectedImages.removeWhere((x) => x.path == photo.xFile.path);
          _originalFilenames.remove(photo.xFile.path);
        }
      } else {
        // Otherwise, select the ones that aren't selected yet
        for (final photo in cluster) {
          if (!_selectedImages.any((x) => x.path == photo.xFile.path)) {
            _selectedImages.add(photo.xFile);
            _originalFilenames[photo.xFile.path] = photo.xFile.name;
            _assetsMap[photo.xFile.path] = photo.entity;
          }
        }
      }
    });
  }

  void _onTextChanged() {
    final text = _textController.text;
    _updateDetectedTags(text);
    if (!_isApplyingDraft) {
      _scheduleDraftSave();
    }
  }

  void _updateDetectedTags(String text) {
    final regex = RegExp(r'#([^\s#]+)');
    final matches = regex.allMatches(text);
    final tags = matches.map((match) => match.group(1)!).toSet().toList();
    if (tags.join(',') != _detectedTags.join(',')) {
      setState(() {
        _detectedTags = tags;
      });
    }
  }

  void _setRestoredDraft(bool isRestoredDraft) {
    if (_isRestoredDraft == isRestoredDraft) return;
    if (mounted) {
      setState(() => _isRestoredDraft = isRestoredDraft);
    } else {
      _isRestoredDraft = isRestoredDraft;
    }
  }

  void _scheduleDraftSave() {
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_draftService.saveTextDraft(_textController.text));
    });
  }

  Future<void> _flushDraft() async {
    _draftSaveDebounce?.cancel();
    if (!widget.isOpen && _textController.text.trim().isEmpty) return;
    await _draftService.saveTextDraft(_textController.text);
  }

  Future<void> _handleClose() async {
    await _flushDraft();
    widget.onClose();
  }

  String get _draftLabel {
    final count = _textController.text.trim().runes.length;
    return UserStorage.l10n.inputDraftLabel(count);
  }

  Future<void> _handleDiscardDraft() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(UserStorage.l10n.discardDraftTitle),
        content: Text(UserStorage.l10n.discardDraftMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              UserStorage.l10n.discardButton,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    _draftSaveDebounce?.cancel();
    await _draftService.clearActiveDraft();
    if (!mounted) return;
    _resetForm();
    _setRestoredDraft(false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draftSaveDebounce?.cancel();
    if (widget.isOpen || _textController.text.trim().isNotEmpty) {
      unawaited(_draftService.saveTextDraft(_textController.text));
    }
    _audioStreamSub?.cancel();
    _streamingTranscriber?.dispose();
    _pcmBuffer.clear();
    _pulseController.dispose();
    _textScrollController.dispose();
    _controller.dispose();
    _textController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(UserStorage.l10n.selectFromAlbum),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(UserStorage.l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            _selectedImages.add(image);
          });
        }
      } else {
        // Gallery
        if (!mounted) return;
        final List<AssetEntity>? result = await AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: 9,
            requestType: RequestType.image,
            filterOptions: FilterOptionGroup(
              containsPathModified: true,
              createTimeCond: DateTimeCond.def().copyWith(ignore: true),
              updateTimeCond: DateTimeCond.def().copyWith(ignore: true),
              videoOption: const FilterOption(
                durationConstraint: DurationConstraint(
                  min: Duration.zero,
                  max: Duration.zero,
                ),
              ),
            ),
          ),
        );
        if (result != null) {
          for (final asset in result) {
            final xFile = await PhotoSuggestionService.assetToXFile(asset);
            if (xFile != null) {
              final originalName = await asset.titleAsync;
              _originalFilenames[xFile.path] = originalName;
              _assetsMap[xFile.path] = asset;
              setState(() {
                _selectedImages.add(xFile);
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      final speechService = SpeechTranscriptionService.instance;

      if (!await _ensureLocalModelReady()) return;

      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
      }

      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
        return;
      }

      _preRecordingText = _textController.text;

      if (await speechService.supportsStreamingTranscription()) {
        _streamingTranscriber = StreamingTranscriber(
          onTextChanged: (fullText) {
            if (mounted) {
              final separator =
                  _preRecordingText.isNotEmpty && fullText.isNotEmpty
                      ? ' '
                      : '';
              setState(() {
                _textController.text = '$_preRecordingText$separator$fullText';
                _textController.selection = TextSelection.collapsed(
                  offset: _textController.text.length,
                );
              });
              _scrollTextToBottom();
            }
          },
        );
        await _streamingTranscriber!.init();
      }

      _pcmBuffer.clear();
      final audioStream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      int chunkCount = 0;
      _audioStreamSub = audioStream.listen((chunk) {
        chunkCount++;
        if (chunkCount % 50 == 1) {
          _logger.info(
            'Audio stream chunk #$chunkCount, size=${chunk.length} bytes',
          );
        }
        _pcmBuffer.addAll(chunk);
        _streamingTranscriber?.addAudioChunk(chunk);
      });

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      _pulseController.repeat(reverse: true);

      _updateRecordingDuration();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  void _updateRecordingDuration() {
    if (!_isRecording) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration = Duration(
            seconds: _recordingDuration.inSeconds + 1,
          );
        });
        // Auto-stop at 60 seconds
        if (_recordingDuration.inSeconds >= 60) {
          _stopRecording();
          return;
        }
        _updateRecordingDuration();
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      final useLocal =
          await SpeechTranscriptionService.instance.isUsingLocalModel();

      await _audioStreamSub?.cancel();
      _audioStreamSub = null;
      await _audioRecorder.stop();

      // Stop streaming — final calibration from _pcmBuffer handles accuracy
      _streamingTranscriber?.dispose();
      _streamingTranscriber = null;

      setState(() {
        _isRecording = false;
      });
      _pulseController.stop();
      _pulseController.reset();

      if (_pcmBuffer.isNotEmpty) {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final wavPath = '${directory.path}/audio_$timestamp.wav';
        await SpeechTranscriptionService.instance.savePcmAsWav(
          wavPath,
          Uint8List.fromList(_pcmBuffer),
        );
        _pcmBuffer.clear();

        if (!useLocal) {
          setState(() {
            _audioPath = wavPath;
            _isPlaying = false;
            _audioDuration = _recordingDuration;
          });
        } else {
          setState(() => _isTranscribing = true);
          await _calibrateFromFile(wavPath);
          if (mounted) setState(() => _isTranscribing = false);
          try {
            File(wavPath).deleteSync();
          } catch (_) {}
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
      }
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  /// Final calibration from saved WAV file after recording stops.
  /// Uses background Isolate to avoid blocking UI.
  Future<void> _calibrateFromFile(String wavPath) async {
    _logger.info('Final calibration from file: $wavPath');
    // Read WAV and send samples to background isolate
    try {
      final file = File(wavPath);
      if (!file.existsSync()) return;
      final bytes = await file.readAsBytes();
      // Skip 44-byte WAV header, convert PCM16 to Float32
      if (bytes.length <= 44) return;
      final pcmBytes = bytes.sublist(44);
      final int16Data = Int16List.view(Uint8List.fromList(pcmBytes).buffer);
      final samples = Float32List(int16Data.length);
      for (int i = 0; i < int16Data.length; i++) {
        samples[i] = int16Data[i] / 32768.0;
      }
      final text = await SpeechTranscriptionService.instance.transcribeSamples(
        samples,
      );
      if (text != null && text.isNotEmpty && mounted) {
        final separator = _preRecordingText.isNotEmpty ? ' ' : '';
        setState(() {
          _textController.text = '$_preRecordingText$separator$text';
          _textController.selection = TextSelection.collapsed(
            offset: _textController.text.length,
          );
        });
        _scrollTextToBottom();
      }
    } catch (e) {
      _logger.severe('Final calibration failed: $e');
    }
  }

  bool _isTranscribing = false;

  /// Long press mic button: pick an audio file.
  Future<void> _pickAudioFile() async {
    bool showedLoading = false;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['m4a', 'mp3', 'wav', 'ogg', 'aac', 'flac'],
      );

      if (mounted) setState(() {});

      if (result == null || result.files.isEmpty || !mounted) return;
      final filePath = result.files.single.path;
      if (filePath == null) return;

      final speechService = SpeechTranscriptionService.instance;
      final useLocal = await speechService.isUsingLocalModel();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final l10n = UserStorage.l10n;

      if (!useLocal) {
        setState(() {
          _audioPath = filePath;
          _isPlaying = false;
          _audioDuration = Duration.zero;
        });
        await _loadAudioDuration();
        return;
      }

      if (!await _ensureLocalModelReady()) return;

      if (!mounted) return;
      final navigator = Navigator.of(context);

      showedLoading = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (_) => Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.speechTranscribing,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final text = await speechService.transcribeFile(
        filePath,
        skipLengthCheck: true,
      );

      if (!mounted) return;
      navigator.pop();
      showedLoading = false;

      if (text != null && text.trim().isNotEmpty) {
        final current = _textController.text;
        final separator = current.isNotEmpty ? '\n' : '';
        setState(() {
          _textController.text = '$current$separator${text.trim()}';
          _textController.selection = TextSelection.collapsed(
            offset: _textController.text.length,
          );
        });
        _scrollTextToBottom();
      } else {
        messenger.showSnackBar(SnackBar(content: Text(l10n.speechNoResult)));
      }
    } catch (e) {
      _logger.severe('Pick audio file failed: $e');
      if (showedLoading && mounted) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to process audio: $e')));
      }
    }
  }

  Widget _buildRipple(double animValue, double offset) {
    final t = (animValue + offset) % 1.0;
    final size = 48.0 + 24.0 * t;
    return Positioned(
      left: (64 - size) / 2,
      top: (64 - size) / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4 * (1 - t)),
            width: 2,
          ),
        ),
      ),
    );
  }

  /// Check if local model download is needed, prompt user if so.
  /// Returns true if ready to proceed, false if user declined or not mounted.
  Future<bool> _ensureLocalModelReady() async {
    final speechService = SpeechTranscriptionService.instance;
    if (!await speechService.requiresLocalModelDownload()) return true;
    if (!mounted) return false;
    await _showModelDownloadDialog();
    if (!mounted) return false;
    return !await speechService.requiresLocalModelDownload();
  }

  Future<bool?> _showModelDownloadDialog() {
    final l10n = UserStorage.l10n;
    final sizeMB = WhisperService.modelSizeMB.toInt();

    // CN flavor: single download button, no source choice
    if (AppFlavor.isCN) {
      return showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(l10n.speechModelDownloadTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.speechModelDownloadDesc(sizeMB)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _downloadWhisperModel(useChineseMirror: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(l10n.speechModelStartDownload),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      );
    }

    // Global flavor: two source options
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(l10n.speechModelDownloadTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.speechModelDownloadDesc(sizeMB)),
            const SizedBox(height: 20),
            Text(
              l10n.speechModelChooseSource,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadWhisperModel(useChineseMirror: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(l10n.speechModelChinaMirror),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadWhisperModel(useChineseMirror: false);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(l10n.speechModelGithub),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadWhisperModel({required bool useChineseMirror}) async {
    final l10n = UserStorage.l10n;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          _downloadDialogSetState = setDialogState;
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(l10n.speechModelDownloading),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                  backgroundColor: AppColors.background,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  _downloadProgress > 0
                      ? '${(_downloadProgress * 100).toInt()}%'
                      : l10n.speechModelConnecting,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    _downloadProgress = 0;

    try {
      await WhisperService.instance.downloadModel(
        useChineseMirror: useChineseMirror,
        onProgress: (p) {
          _downloadDialogSetState?.call(() {
            _downloadProgress = p;
          });
        },
      );
    } catch (e) {
      _logger.severe('Model download failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.speechModelDownloadFailed(e.toString()))),
        );
      }
    } finally {
      _downloadProgress = 0;
      if (mounted) Navigator.of(context).pop();
    }
  }

  StateSetter? _downloadDialogSetState;
  double _downloadProgress = 0;

  void _removeImage(int index) {
    setState(() {
      final xFile = _selectedImages[index];
      _originalFilenames.remove(xFile.path);
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _loadAudioDuration() async {
    final audioPath = _audioPath;
    if (audioPath == null) return;

    try {
      await _audioPlayer.setSourceDeviceFile(audioPath);
      final duration = await _audioPlayer.getDuration();
      if (!mounted || _audioPath != audioPath) return;
      setState(() {
        _audioDuration = duration ?? Duration.zero;
      });
    } catch (_) {}
  }

  Future<void> _toggleAudioPlayback() async {
    final audioPath = _audioPath;
    if (audioPath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
      if (!mounted) return;
      setState(() => _isPlaying = false);
      return;
    }

    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(audioPath));
    if (!mounted) return;
    setState(() => _isPlaying = true);
  }

  Future<void> _removeAudio() async {
    await _audioPlayer.stop();
    if (!mounted) return;
    setState(() {
      _audioPath = null;
      _isPlaying = false;
      _audioDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showImagePreview(int index) {
    if (index < 0 || index >= _selectedImages.length) return;

    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Container(
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: _assetsMap.containsKey(_selectedImages[index].path)
                    ? AssetEntityImage(
                        _assetsMap[_selectedImages[index].path]!,
                        isOriginal: true,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        File(_selectedImages[index].path),
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!mounted || _isSubmitting) return;
    final trimmedText = _textController.text.trim().isEmpty
        ? null
        : _textController.text.trim();

    // Generate hashes in background to prevent UI jank
    String? textHash;
    List<String>? imageHashes;
    String? audioHash;

    if (trimmedText != null && trimmedText.isNotEmpty) {
      textHash = crypto.md5.convert(utf8.encode(trimmedText)).toString();
    }

    if (_audioPath != null) {
      final audioFile = File(_audioPath!);
      if (await audioFile.exists()) {
        final length = await audioFile.length();
        final fileName = _audioPath!.split(Platform.pathSeparator).last;
        audioHash = crypto.md5
            .convert(utf8.encode('audio_${fileName}_$length'))
            .toString();
      }
    }

    if (_selectedImages.isNotEmpty) {
      imageHashes = [];
      for (final xFile in _selectedImages) {
        try {
          final length = await xFile.length();
          final effectiveName = _originalFilenames[xFile.path] ?? xFile.name;
          final rawHashStr = 'photo_${effectiveName}_$length';

          _logger.info('Generating hash for image: $rawHashStr');
          await Future.delayed(Duration.zero);
          imageHashes.add(
            crypto.md5.convert(utf8.encode(rawHashStr)).toString(),
          );
        } catch (e) {
          imageHashes.add(
            crypto.md5
                .convert(
                  utf8.encode(
                    'photo_${xFile.path}_${DateTime.now().millisecondsSinceEpoch}',
                  ),
                )
                .toString(),
          );
        }
      }
    }

    final inputData = InputData(
      text: trimmedText,
      images: _selectedImages,
      audioPath: _audioPath,
      textHash: textHash,
      imageHashes: imageHashes,
      audioHash: audioHash,
    );

    if (inputData.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserStorage.l10n.enterContentOrMediaHint)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await _flushDraft();
    final submitted = await widget.onSubmit(inputData);
    if (!mounted) return;

    if (submitted) {
      await _draftService.clearActiveDraft();
      if (!mounted) return;
      _resetForm();
      _setRestoredDraft(false);
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildDraftHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _draftLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: UserStorage.l10n.discardDraftTooltip,
            onPressed: _handleDiscardDraft,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.textTertiary,
            iconSize: 20,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate available height excluding keyboard
    final availableHeight = screenHeight - viewInsets.bottom;
    // Account for AutoRow (~84px) and card margins
    final cardMaxHeight = availableHeight - 110;

    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _handleClose,
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
        ),
        SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: availableHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AUTO row above input area, single row
                  _buildAutoRow(),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        constraints: BoxConstraints(
                          maxHeight: cardMaxHeight.clamp(
                            160.0,
                            screenHeight * 0.7,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(
                                0,
                                10,
                              ), // Shadow below for float
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8), // Removed handle
                              if (_isRestoredDraft &&
                                  _textController.text.trim().isNotEmpty)
                                _buildDraftHeader(),
                              Flexible(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    0,
                                    24,
                                    24,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: _textController,
                                        scrollController: _textScrollController,
                                        autofocus: false,
                                        maxLines: 5,
                                        decoration: InputDecoration(
                                          hintText: UserStorage
                                              .l10n.tellAiWhatHappened,
                                          hintStyle: const TextStyle(
                                            color: AppColors.textTertiary,
                                            fontSize: 18,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                          height: 1.5,
                                        ),
                                      ),
                                      if (_detectedTags.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _detectedTags.map((tag) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.iconBgLight,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    '#',
                                                    style: TextStyle(
                                                      color: AppColors.primary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    tag,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                      if (_selectedImages.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _selectedImages.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        12,
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            _showImagePreview(
                                                          index,
                                                        ),
                                                        child: _assetsMap
                                                                .containsKey(
                                                          _selectedImages[index]
                                                              .path,
                                                        )
                                                            ? AssetEntityImage(
                                                                _assetsMap[
                                                                    _selectedImages[
                                                                            index]
                                                                        .path]!,
                                                                width: 100,
                                                                height: 100,
                                                                fit: BoxFit
                                                                    .cover,
                                                                isOriginal:
                                                                    false,
                                                                thumbnailSize:
                                                                    const ThumbnailSize
                                                                        .square(
                                                                  200,
                                                                ),
                                                                thumbnailFormat:
                                                                    ThumbnailFormat
                                                                        .jpeg,
                                                              )
                                                            : Image.file(
                                                                File(
                                                                  _selectedImages[
                                                                          index]
                                                                      .path,
                                                                ),
                                                                width: 100,
                                                                height: 100,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 4,
                                                      right: 4,
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            _removeImage(index),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(
                                                            4,
                                                          ),
                                                          decoration:
                                                              const BoxDecoration(
                                                            color:
                                                                Colors.black54,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Icon(
                                                            Icons.close,
                                                            size: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                      if (_audioPath != null &&
                                          !_isRecording) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: _toggleAudioPlayback,
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      18,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    _isPlaying
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    size: 20,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      UserStorage
                                                          .l10n.recordedAudio,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _isPlaying
                                                          ? UserStorage
                                                              .l10n.playing
                                                          : _formatDuration(
                                                              _audioDuration,
                                                            ),
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: _removeAudio,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 16,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _isTranscribing
                                                ? null
                                                : (_isRecording
                                                    ? _stopRecording
                                                    : _startRecording),
                                            onLongPress: (_isRecording ||
                                                    _isTranscribing)
                                                ? null
                                                : _pickAudioFile,
                                            child: AnimatedBuilder(
                                              animation: _pulseController,
                                              builder: (context, child) {
                                                return SizedBox(
                                                  width: 64,
                                                  height: 64,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      if (_isRecording) ...[
                                                        _buildRipple(
                                                          _pulseController
                                                              .value,
                                                          0.0,
                                                        ),
                                                        _buildRipple(
                                                          _pulseController
                                                              .value,
                                                          0.33,
                                                        ),
                                                        _buildRipple(
                                                          _pulseController
                                                              .value,
                                                          0.66,
                                                        ),
                                                      ],
                                                      Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: _isRecording
                                                              ? AppColors
                                                                  .primary
                                                              : _isTranscribing
                                                                  ? AppColors
                                                                      .primary
                                                                      .withValues(
                                                                      alpha:
                                                                          0.08,
                                                                    )
                                                                  : const Color(
                                                                      0xFFF7F8FA,
                                                                    ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            24,
                                                          ),
                                                        ),
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.mic,
                                                              size: 22,
                                                              color: _isRecording
                                                                  ? Colors.white
                                                                  : _isTranscribing
                                                                      ? AppColors.primary
                                                                      : AppColors.textSecondary,
                                                            ),
                                                            if (_isTranscribing)
                                                              const SizedBox(
                                                                width: 36,
                                                                height: 36,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: AppColors
                                                                      .primary,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: _showImageSourceDialog,
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF7F8FA),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: const Icon(
                                                Icons.image,
                                                size: 22,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                            key: DemoService.instance.isActive
                                                ? DemoService
                                                    .instance.sendButtonKey
                                                : null,
                                            onTap: _handleSubmit,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    UserStorage
                                                        .l10n.recordLabel,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.arrow_upward,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// AUTO area: above input area, single row, horizontally scrollable
  Widget _buildAutoRow() {
    if (_isLoadingAuto) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        color: Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              UserStorage.l10n.smartSuggesting,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    if (_autoClusters == null || _autoClusters!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: SizedBox(
        height: 72, // Increased height for larger thumbnails
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _autoClusters!.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cluster = _autoClusters![index];
            return Center(child: _buildClusterChip(cluster));
          },
        ),
      ),
    );
  }

  /// Floating pill: images in a row, no text, width by count, larger thumbnails
  Widget _buildClusterChip(List<EnhancedPhoto> cluster) {
    if (cluster.isEmpty) return const SizedBox.shrink();

    final selectedCount = cluster
        .where((p) => _selectedImages.any((x) => x.path == p.xFile.path))
        .length;
    final isAllSelected = selectedCount == cluster.length;

    return GestureDetector(
      onTap: () => _addClusterToSelection(cluster),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF7F8FA), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // same-category images in a row
            ...cluster.take(5).map<Widget>((photo) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: AssetEntityImage(
                      photo.entity,
                      fit: BoxFit.cover,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize.square(120),
                      thumbnailFormat: ThumbnailFormat.jpeg,
                    ),
                  ),
                ),
              );
            }),
            if (cluster.length > 5)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  '+${cluster.length - 5}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              isAllSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 20,
              color:
                  isAllSelected ? AppColors.primary : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
