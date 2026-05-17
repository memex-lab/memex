import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/ui/core/widgets/local_image.dart';
import 'package:memex/ui/core/widgets/local_audio_source.dart';

/// Asset header gallery that supports:
/// 1. Swipeable image gallery
/// 2. Audio playback
/// 3. Pull-to-expand visualization (handled by parent SliverAppBar, this widget fits cover)
class AssetHeaderGallery extends StatefulWidget {
  final List<AssetData> assets;
  final VoidCallback? onTap;
  final bool isExpanded;
  final ValueChanged<bool>? onInteractionStateChanged;
  final ValueChanged<int>? onPageChanged;

  const AssetHeaderGallery({
    super.key,
    required this.assets,
    this.onTap,
    this.isExpanded = false,
    this.onInteractionStateChanged,
    this.onPageChanged,
  });

  @override
  State<AssetHeaderGallery> createState() => _AssetHeaderGalleryState();
}

class _AssetHeaderGalleryState extends State<AssetHeaderGallery> {
  late PageController _pageController;
  late TransformationController _transformationController;

  // Interaction States
  int _pointerCount = 0;
  bool _isZoomed = false;
  bool _isInteractingWithViewer = false;

  bool get _shouldBlockScroll =>
      _isZoomed || _pointerCount > 1 || _isInteractingWithViewer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _transformationController = TransformationController();

    _transformationController.addListener(() {
      // Check if we are zoomed in (scale > 1.0 with a small epsilon for float precision)
      final scale = _transformationController.value.getMaxScaleOnAxis();
      final isZoomed = scale > 1.01;

      if (_isZoomed != isZoomed) {
        setState(() {
          _isZoomed = isZoomed;
        });
        _checkInteractionState();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _checkInteractionState() {
    // Notify parent about scroll blocking requirement
    widget.onInteractionStateChanged?.call(_shouldBlockScroll);
  }

  void _handlePointerDown(_) {
    setState(() => _pointerCount++);
    _checkInteractionState();
  }

  void _handlePointerUp(_) {
    setState(() => _pointerCount--);
    _checkInteractionState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF475569), Color(0xFF0F172A)],
          ),
        ),
      );
    }

    // Determine physics locally for PageView
    // Always allow PageView to scroll horizontally, but disable when zoomed or multi-touch
    final ScrollPhysics pageViewPhysics = _shouldBlockScroll
        ? const NeverScrollableScrollPhysics()
        : const PageScrollPhysics(); // Use PageScrollPhysics for better swipe sensitivity

    return Stack(
      children: [
        // Main Gallery
        Listener(
          onPointerDown: _handlePointerDown,
          onPointerUp: _handlePointerUp,
          onPointerCancel: _handlePointerUp, // Treat cancel same as up
          child: PageView.builder(
            physics: pageViewPhysics,
            controller: _pageController,
            itemCount: widget.assets.length,
            onPageChanged: (index) {
              setState(() {
                // Reset zoom when page changes
                _isZoomed = false;
                _isInteractingWithViewer = false;
                _transformationController.value = Matrix4.identity();
              });
              widget.onPageChanged?.call(index);
            },
            itemBuilder: (context, index) {
              final asset = widget.assets[index];
              if (asset.isImage) {
                // When not expanded, use a simpler widget to avoid gesture conflicts
                if (!widget.isExpanded) {
                  return GestureDetector(
                    onTap: widget.onTap,
                    child: LocalImage(
                      url: asset.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[900]);
                      },
                    ),
                  );
                }

                // When expanded, use InteractiveViewer for zoom/pan
                return GestureDetector(
                  onTap: widget.onTap,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 1.0,
                    maxScale: 4.0,
                    onInteractionStart: (details) {
                      // Only block scroll if we're actually zooming/panning
                      // For quick swipes, we want PageView to handle it
                      if (details.pointerCount > 1 ||
                          _transformationController.value.getMaxScaleOnAxis() >
                              1.01) {
                        setState(() {
                          _isInteractingWithViewer = true;
                        });
                        _checkInteractionState();
                      }
                    },
                    onInteractionEnd: (details) {
                      // Check if we're still zoomed after interaction ends
                      final scale =
                          _transformationController.value.getMaxScaleOnAxis();
                      setState(() {
                        _isInteractingWithViewer = scale > 1.01;
                      });
                      _checkInteractionState();
                    },
                    onInteractionUpdate: (details) {
                      // Update interaction state during gesture
                      final scale =
                          _transformationController.value.getMaxScaleOnAxis();
                      if (_isInteractingWithViewer != (scale > 1.01)) {
                        setState(() {
                          _isInteractingWithViewer = scale > 1.01;
                        });
                        _checkInteractionState();
                      }
                    },
                    child: LocalImage(
                      url: asset.url,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[900]);
                      },
                    ),
                  ),
                );
              } else if (asset.isAudio) {
                return Container(
                  color:
                      const Color(0xFF1E293B), // Slate 800 background for audio
                  child: Center(
                    child: AudioPlayerWidget(url: asset.url),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String url;

  const AudioPlayerWidget({
    super.key,
    required this.url,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool get _isPlaying => _playerState == PlayerState.playing;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);

    // Listen to state changes
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    // Listen to duration changes
    _player.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    // Listen to position changes
    _player.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    // Set source immediately to get duration metadata
    _player.setSource(LocalAudioSource.createSource(widget.url));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(LocalAudioSource.createSource(widget.url));
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
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        // Glassmorphism effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          const Icon(
            Icons.music_note_rounded,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 24),

          // Progress Bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.1),
            ),
            child: Slider(
              value: _position.inMilliseconds.toDouble(),
              max: _duration.inMilliseconds.toDouble() > 0
                  ? _duration.inMilliseconds.toDouble()
                  : 1.0,
              onChanged: (value) async {
                final position = Duration(milliseconds: value.toInt());
                await _player.seek(position);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 56,
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: Colors.white,
                ),
                onPressed: _togglePlay,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
