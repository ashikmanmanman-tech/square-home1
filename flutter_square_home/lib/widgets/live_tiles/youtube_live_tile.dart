import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Looped sample video with a "Now playing" caption, mirroring the RN
/// `YouTubeLiveTile` (expo-video backed, plays a sample clip rather than
/// real YouTube playback — actual YouTube integration would require the
/// YouTube Data API / IFrame Player and OAuth, out of scope for a launcher
/// tile).
class YouTubeLiveTile extends StatefulWidget {
  final double width;
  final double height;
  final bool animated;

  const YouTubeLiveTile({
    super.key,
    required this.width,
    required this.height,
    this.animated = true,
  });

  @override
  State<YouTubeLiveTile> createState() => _YouTubeLiveTileState();
}

class _YouTubeLiveTileState extends State<YouTubeLiveTile> {
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      ),
    )..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        if (widget.animated) {
          _controller
            ..setLooping(true)
            ..setVolume(0)
            ..play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const ColoredBox(color: Colors.black26),
          Positioned(
            left: 6,
            bottom: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  "Now playing",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
