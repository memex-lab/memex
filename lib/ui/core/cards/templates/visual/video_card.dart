import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const VideoCard({super.key, required this.data, this.onTap});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final String? videoUrl = widget.data['video_url'];
    if (videoUrl == null || videoUrl.isEmpty) {
      if (mounted) setState(() => _isError = true);
      return;
    }

    try {
      if (videoUrl.startsWith('http')) {
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        _videoPlayerController = VideoPlayerController.file(File(videoUrl));
      }

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Video init error: $e");
      if (mounted) setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.data['title'] ?? 'Video';
    final String duration = widget.data['duration'] ?? '';

    return GlassCard(
      onTap: widget.onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: _videoPlayerController.value.isInitialized
                ? _videoPlayerController.value.aspectRatio
                : 16 / 9,
            child: _isError
                ? Container(
                    color: Colors.black,
                    child: const Center(
                        child:
                            Icon(Icons.error, color: Colors.white, size: 40)))
                : _chewieController != null &&
                        _chewieController!
                            .videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (duration.isNotEmpty)
                  Text(duration,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
