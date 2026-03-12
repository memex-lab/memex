import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/style/timeline_theme.dart';
import 'package:memex/ui/core/cards/ui/timeline_card_container.dart';
import 'package:memex/ui/core/cards/ui/timeline_common.dart';
import 'package:memex/ui/core/widgets/local_image.dart';
import 'package:memex/ui/core/widgets/local_audio_source.dart';
import 'package:memex/utils/user_storage.dart';

/// Classic Card Template
///
/// Standard layout for general content.
/// - Body: Text content
/// - Media: Optional image/video preview
/// - Footer: Tags, Date/Time
class ClassicCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const ClassicCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  State<ClassicCard> createState() => _ClassicCardState();
}

class _ClassicCardState extends State<ClassicCard> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _completeSubscription;

  String get content => (widget.data['content']) as String? ?? '';
  List<String> get tags =>
      (widget.data['tags'] as List<dynamic>?)?.cast<String>() ?? [];
  List<String> get imageUrls =>
      (widget.data['images'] as List<dynamic>?)?.cast<String>() ?? [];
  String? get audioUrl => widget.data['audioUrl'] as String?;
  String get status => widget.data['status'] as String? ?? 'completed';
  String? get transcript => widget.data['transcript'] as String?;
  String? get failureReason => widget.data['failure_reason'] as String?;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    _durationSubscription =
        _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _positionSubscription =
        _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _completeSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (audioUrl == null) return;

    try {
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(LocalAudioSource.createSource(audioUrl!));
      }
    } catch (e) {
      debugPrint('Audio playback error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play audio: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = status == 'processing';
    final isFailed = status == 'failed';
    final showStatusHeader = isProcessing || isFailed;

    return TimelineCard(
      variant: TimelineCardVariant.glass,
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          if (showStatusHeader) ...[
            _buildStatusHeader(),
            const SizedBox(height: 12),
          ],

          // Audio is primary content if present, but visual hierarchy often puts images first
          // preserving original order: Content -> Images -> Audio -> Tags

          // Content Body
          if (content.isNotEmpty) ...[
            Text(
              content,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: TimelineTheme.typography.body.copyWith(
                color: TimelineTheme.colors.textSecondary,
              ),
            ),
            if (imageUrls.isNotEmpty || audioUrl != null || tags.isNotEmpty)
              const SizedBox(height: 16),
          ],

          // Images
          if (imageUrls.isNotEmpty) ...[
            _buildImageGrid(),
            if (audioUrl != null || tags.isNotEmpty) const SizedBox(height: 16),
          ],

          // Audio Player
          if (audioUrl != null && audioUrl!.isNotEmpty) ...[
            _buildAudioPlayer(),
          ],

          // Tags
          if (tags.isNotEmpty) TimelineFooter(tags: tags),
          const SizedBox(width: double.infinity),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    final isProcessing = status == 'processing';

    if (isProcessing) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  UserStorage.l10n.processingStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Failed state
    return GestureDetector(
      onTap: () => _showFailureSheet(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.06),
                  const Color(0xFFEF4444).withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 2),
                Text(
                  UserStorage.l10n.failedStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right,
                    size: 14,
                    color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFailureSheet(BuildContext context) {
    final reason = failureReason ?? UserStorage.l10n.unknownError;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).viewPadding.bottom;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.55,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.92),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF94A3B8).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFEF4444).withValues(alpha: 0.15),
                                const Color(0xFFEF4444).withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                          ),
                          child: const Icon(Icons.warning_amber_rounded,
                              size: 20, color: Color(0xFFEF4444)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            UserStorage.l10n.failureReason,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF94A3B8)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded,
                                size: 16,
                                color: const Color(0xFF64748B)
                                    .withValues(alpha: 0.8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Error content
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A)
                                  .withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF94A3B8)
                                    .withValues(alpha: 0.12),
                                width: 0.5,
                              ),
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: SelectableText(
                                reason,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  height: 1.6,
                                  fontFamily: 'monospace',
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20 + bottomPadding),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioPlayer() {
    final isPlaying = _playerState == PlayerState.playing;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate-100 (Light Grey)
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Play Button (Large, Black)
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Waveform
              Expanded(
                child: SizedBox(
                  height: 48, // Taller waveform
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: AudioWaveformPainter(
                      progress: progress,
                      color: const Color(0xFFD8B4FE), // Purple-300
                      activeColor: const Color(0xFFA855F7), // Purple-500
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Duration Text
              Text(
                _formatDuration(_position),
                style: TimelineTheme.typography.data.copyWith(
                  fontSize: 15,
                  color: TimelineTheme.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Transcription Text (if present and audio-focused)
          if (transcript != null && transcript!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                transcript!,
                style: TimelineTheme.typography.body.copyWith(
                  fontStyle: FontStyle.italic,
                  color: TimelineTheme.colors.textSecondary,
                  fontFamily: 'Serif', // Elegant transcript style
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (int i = 0; i < imageUrls.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(16), // Adjusted to 16 for new design
            child: _buildImageItem(i, fit: BoxFit.fitWidth),
          ),
        ],
      ],
    );
  }

  Widget _buildImageItem(int index, {BoxFit fit = BoxFit.cover}) {
    final url = imageUrls[index];

    return Container(
      color: TimelineTheme.colors.background,
      width: double.infinity,
      child: LocalImage(
        url: url,
        fit: fit,
        errorBuilder: (_, __, ___) => SizedBox(
          height: 100,
          child: Center(
              child: Icon(Icons.broken_image,
                  color: TimelineTheme.colors.textTertiary.withOpacity(0.5))),
        ),
      ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;
  final Color activeColor;

  AudioWaveformPainter({
    required this.progress,
    required this.color,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0; // Thicker bars

    final count = 24; // Less bars for chunkier look
    final spacing = size.width / count;

    for (int i = 0; i < count; i++) {
      // Simulate waveform data
      double heightPercent =
          0.4 + (0.6 * (i % 3 == 0 ? 0.8 : (i % 2 == 0 ? 0.5 : 0.3)));
      // Bump center bars
      if (i > count * 0.3 && i < count * 0.7)
        heightPercent = heightPercent * 1.2;
      if (heightPercent > 1.0) heightPercent = 1.0;

      final barHeight = size.height * heightPercent;
      final x = i * spacing + spacing / 2;
      final yStart = (size.height - barHeight) / 2;
      final yEnd = yStart + barHeight;

      if (i / count < progress) {
        paint.color = activeColor;
      } else {
        paint.color = color;
      }

      canvas.drawLine(
        Offset(x, yStart),
        Offset(x, yEnd),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.activeColor != activeColor;
  }
}
