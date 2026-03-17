import 'dart:io';
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

class _InputSheetState extends State<InputSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Logger _logger = getLogger('InputSheet');

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

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/audio_$timestamp.m4a';

      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
        });

        _updateRecordingDuration();
      }
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
        _updateRecordingDuration();
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _audioPath = path;
          _isRecording = false;
        });
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
    String? audioHash;

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

    if (_audioPath != null) {
      try {
        final file = File(_audioPath!);
        final stat = await file.lastModified();
        final length = await file.length();
        final rawHashStr =
            'audio_${file.path}_${stat.millisecondsSinceEpoch ~/ 1000}_$length';
        _logger.info('Generating hash for audio: $rawHashStr');
        audioHash = md5.convert(utf8.encode(rawHashStr)).toString();
      } catch (e) {
        audioHash = md5
            .convert(utf8.encode(
                'audio_${_audioPath}_${DateTime.now().millisecondsSinceEpoch}'))
            .toString();
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
                                        autofocus: false,
                                        maxLines: 5,
                                        decoration: InputDecoration(
                                          hintText: UserStorage
                                              .l10n.tellAiWhatHappened,
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 18,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF1E293B),
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
                                                color: const Color(0xFFEEF2FF),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFFC7D2FE),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    '#',
                                                    style: TextStyle(
                                                      color: Color(0xFF6366F1),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    tag,
                                                    style: const TextStyle(
                                                      color: Color(0xFF6366F1),
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
                                      if (_audioPath != null ||
                                          _isRecording) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: GestureDetector(
                                            onTap: _toggleAudioPlayback,
                                            behavior: HitTestBehavior.opaque,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  _isPlaying
                                                      ? Icons
                                                          .pause_circle_filled
                                                      : Icons
                                                          .play_circle_filled,
                                                  color:
                                                      const Color(0xFF6366F1),
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _isRecording
                                                        ? UserStorage.l10n
                                                            .recordingWithDuration(
                                                                _formatDuration(
                                                                    _recordingDuration))
                                                        : (_isPlaying
                                                            ? UserStorage
                                                                .l10n.playing
                                                            : UserStorage.l10n
                                                                .recordedAudio),
                                                    style: TextStyle(
                                                      color: _isPlaying
                                                          ? const Color(
                                                              0xFF6366F1)
                                                          : const Color(
                                                              0xFF64748B),
                                                      fontSize: 14,
                                                      fontWeight: _isPlaying
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                                if (!_isRecording)
                                                  GestureDetector(
                                                    onTap: _removeAudio,
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 20,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _isRecording
                                                ? _stopRecording
                                                : _startRecording,
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: _isRecording
                                                    ? const Color(0xFFEF4444)
                                                    : const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Icon(
                                                _isRecording
                                                    ? Icons.stop
                                                    : Icons.mic,
                                                size: 22,
                                                color: _isRecording
                                                    ? Colors.white
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: _showImageSourceDialog,
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: const Icon(
                                                Icons.image,
                                                size: 22,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          GestureDetector(
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
                  const Color(0xFF6366F1).withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              UserStorage.l10n.smartSuggesting,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
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
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
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
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              isAllSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 20,
              color: isAllSelected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
