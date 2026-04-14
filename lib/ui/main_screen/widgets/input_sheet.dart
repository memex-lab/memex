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
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/photo_suggestion_service.dart';
import 'package:memex/data/services/whisper_service.dart';
import 'package:memex/data/services/streaming_transcriber.dart';
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
  final Function(InputData data) onSubmit;
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

class _InputSheetState extends State<InputSheet> with TickerProviderStateMixin {
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

  StreamingTranscriber? _streamingTranscriber;
  StreamSubscription<Uint8List>? _audioStreamSub;
  // Accumulated PCM data for saving as WAV after recording stops
  final List<int> _pcmBuffer = [];
  // Text in the text field before recording started (to preserve user-typed text)
  String _preRecordingText = '';

  List<XFile> _selectedImages = [];
  final Map<String, String> _originalFilenames = {};
  String? _audioPath;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  List<String> _detectedTags = [];

  List<List<EnhancedPhoto>>? _autoClusters;
  bool _isLoadingAuto = false;
  final Map<String, AssetEntity> _assetsMap = {}; // path -> AssetEntity
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.isOpen) {
      _controller.forward();
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textController.addListener(_onTextChanged);

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void didUpdateWidget(InputSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _logger.info('Opening InputSheet');
        _controller.forward();
        _resetForm();
        _applyInitialData(widget.initialData);
        _fetchAutoClusters();
      } else {
        _controller.reverse();
      }
    } else if (widget.isOpen &&
        widget.initialData != null &&
        widget.initialData != oldWidget.initialData) {
      // Sheet already open but new share arrived: reload with shared data
      _logger.info('InputSheet already open, reloading with new shared data');
      _applyInitialData(widget.initialData);
    }
  }

  void _applyInitialData(InputData? data) {
    if (data == null) return;

    final text = data.text ?? '';
    _textController.text = text;
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
      _detectedTags = tags;
      _autoClusters = null;
      _isLoadingAuto = false;
    });
  }

  void _resetForm() {
    _textController.clear();
    _audioPlayer.stop();
    setState(() {
      _selectedImages = [];
      _originalFilenames.clear();
      _audioPath = null;
      _isRecording = false;
      _isPlaying = false;
      _recordingDuration = Duration.zero;
      _detectedTags = [];
      _autoClusters = null;
      _isLoadingAuto = false;
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
    final regex = RegExp(r'#([^\s#]+)');
    final matches = regex.allMatches(text);
    final tags = matches.map((match) => match.group(1)!).toSet().toList();
    if (tags.join(',') != _detectedTags.join(',')) {
      setState(() {
        _detectedTags = tags;
      });
    }
  }

  @override
  void dispose() {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      // Check if speech model is downloaded before recording
      if (!await WhisperService.instance.isModelDownloaded()) {
        if (!mounted) return;
        await _showModelDownloadDialog();
        if (!await WhisperService.instance.isModelDownloaded() || !mounted)
          return;
      }

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

      // Initialize streaming transcriber
      _preRecordingText = _textController.text;

      _streamingTranscriber = StreamingTranscriber(
        onTextChanged: (fullText) {
          if (mounted) {
            final separator =
                _preRecordingText.isNotEmpty && fullText.isNotEmpty ? ' ' : '';
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

      // Start streaming recording (PCM 16-bit, 16kHz, mono)
      _pcmBuffer.clear();
      final audioStream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      int _chunkCount = 0;
      _audioStreamSub = audioStream.listen((chunk) {
        _chunkCount++;
        if (_chunkCount % 50 == 1) {
          _logger.info(
              'Audio stream chunk #$_chunkCount, size=${chunk.length} bytes');
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
          _recordingDuration =
              Duration(seconds: _recordingDuration.inSeconds + 1);
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

      // Save PCM buffer as WAV for final calibration
      if (_pcmBuffer.isNotEmpty) {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final wavPath = '${directory.path}/audio_$timestamp.wav';
        await _savePcmAsWav(wavPath, Uint8List.fromList(_pcmBuffer));
        _pcmBuffer.clear();

        // Show loading on mic button during calibration
        setState(() => _isTranscribing = true);
        await _calibrateFromFile(wavPath);
        if (mounted) setState(() => _isTranscribing = false);

        // Clean up temp WAV — no longer needed for submission
        try {
          File(wavPath).deleteSync();
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  /// Save raw PCM 16-bit data as a WAV file (16kHz, mono).
  Future<void> _savePcmAsWav(String path, Uint8List pcmData) async {
    final file = File(path);
    final sink = file.openWrite();

    final dataSize = pcmData.length;
    final fileSize = 36 + dataSize;

    // WAV header
    final header = ByteData(44);
    // RIFF
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    // WAVE
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    // fmt
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // (space)
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little); // PCM format
    header.setUint16(22, 1, Endian.little); // mono
    header.setUint32(24, 16000, Endian.little); // sample rate
    header.setUint32(28, 32000, Endian.little); // byte rate (16000 * 2)
    header.setUint16(32, 2, Endian.little); // block align
    header.setUint16(34, 16, Endian.little); // bits per sample
    // data
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    sink.add(header.buffer.asUint8List());
    sink.add(pcmData);
    await sink.close();
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
      final text = await WhisperService.instance.transcribeSamples(samples);
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

  /// Long press mic button: pick an audio file and transcribe it.
  Future<void> _pickAudioFile() async {
    bool showedLoading = false;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['m4a', 'mp3', 'wav', 'ogg', 'aac', 'flac'],
      );

      // Force rebuild after native picker returns
      if (mounted) setState(() {});

      if (result == null || result.files.isEmpty || !mounted) return;
      final filePath = result.files.single.path;
      if (filePath == null) return;

      // Check if model is downloaded
      if (!await WhisperService.instance.isModelDownloaded()) {
        if (!mounted) return;
        await _showModelDownloadDialog();
        if (!await WhisperService.instance.isModelDownloaded() || !mounted)
          return;
      }

      // Show loading dialog
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
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  UserStorage.l10n.speechTranscribing,
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

      final text = await WhisperService.instance
          .transcribe(filePath, skipLengthCheck: true);

      if (mounted) Navigator.of(context).pop(); // Dismiss loading dialog
      showedLoading = false;

      if (text != null && text.trim().isNotEmpty && mounted) {
        final current = _textController.text;
        final separator = current.isNotEmpty ? '\n' : '';
        setState(() {
          _textController.text = '$current$separator${text.trim()}';
          _textController.selection = TextSelection.collapsed(
            offset: _textController.text.length,
          );
        });
        _scrollTextToBottom();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserStorage.l10n.speechNoResult)),
        );
      }
    } catch (e) {
      _logger.severe('Pick audio file failed: $e');
      if (showedLoading && mounted) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process audio: $e')),
        );
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

  /// Transcribe audio and show result in a bottom sheet.
  Future<void> _previewTranscription() async {
    if (_audioPath == null) return;
    final whisper = WhisperService.instance;

    if (!await whisper.isModelDownloaded()) {
      if (!mounted) return;
      await _showModelDownloadDialog();
      if (!await whisper.isModelDownloaded() || !mounted) return;
    }

    final l10n = UserStorage.l10n;
    String? resultText;
    bool isLoading = true;

    setState(() => _isTranscribing = true);

    // Show bottom sheet immediately with loading state
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          // Kick off transcription on first build
          if (isLoading && resultText == null) {
            whisper.transcribe(_audioPath!).then((text) {
              resultText = text;
              isLoading = false;
              if (ctx.mounted) setSheetState(() {});
              if (mounted) setState(() => _isTranscribing = false);
            }).catchError((_) {
              isLoading = false;
              if (ctx.mounted) setSheetState(() {});
              if (mounted) setState(() => _isTranscribing = false);
            });
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.speechTranscriptionTitle,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(minHeight: 60),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.speechTranscribing,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        )
                      : SelectableText(
                          resultText?.trim().isNotEmpty == true
                              ? resultText!
                              : l10n.speechNoResult,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: resultText?.trim().isNotEmpty == true
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            height: 1.5,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
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

  void _removeAudio() {
    _audioPlayer.stop();
    setState(() {
      _audioPath = null;
      _isPlaying = false;
    });
  }

  Future<void> _toggleAudioPlayback() async {
    if (_audioPath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
      setState(() => _isPlaying = true);
    }
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

  void _handleSubmit() async {
    final trimmedText = _textController.text.trim().isEmpty
        ? null
        : _textController.text.trim();

    // Generate hashes in background to prevent UI jank
    String? textHash;
    List<String>? imageHashes;

    if (trimmedText != null && trimmedText.isNotEmpty) {
      textHash = md5.convert(utf8.encode(trimmedText)).toString();
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
          imageHashes.add(md5.convert(utf8.encode(rawHashStr)).toString());
        } catch (e) {
          imageHashes.add(md5
              .convert(utf8.encode(
                  'photo_${xFile.path}_${DateTime.now().millisecondsSinceEpoch}'))
              .toString());
        }
      }
    }

    final inputData = InputData(
      text: trimmedText,
      images: _selectedImages,
      textHash: textHash,
      imageHashes: imageHashes,
    );

    if (inputData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserStorage.l10n.enterContentOrMediaHint)),
      );
      return;
    }

    widget.onSubmit(inputData);
    _resetForm();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
            onTap: widget.onClose,
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
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
                          maxHeight:
                              cardMaxHeight.clamp(160.0, screenHeight * 0.7),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset:
                                  const Offset(0, 10), // Shadow below for float
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12), // Removed handle
                              Flexible(
                                child: SingleChildScrollView(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                                                    right: 8),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            _showImagePreview(
                                                                index),
                                                        child: _assetsMap.containsKey(
                                                                _selectedImages[
                                                                        index]
                                                                    .path)
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
                                                                        200),
                                                                thumbnailFormat:
                                                                    ThumbnailFormat
                                                                        .jpeg,
                                                              )
                                                            : Image.file(
                                                                File(_selectedImages[
                                                                        index]
                                                                    .path),
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
                                                                  .all(4),
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
                                        // Audio file exists but hidden — no playback bar needed
                                        // Text was already transcribed into the text field
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
                                                            0.0),
                                                        _buildRipple(
                                                            _pulseController
                                                                .value,
                                                            0.33),
                                                        _buildRipple(
                                                            _pulseController
                                                                .value,
                                                            0.66),
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
                                                                              0.08)
                                                                  : const Color(
                                                                      0xFFF7F8FA),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(24),
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
                                                  SizedBox(width: 8),
                                                  Icon(
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
              color: Colors.black.withOpacity(0.04),
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
