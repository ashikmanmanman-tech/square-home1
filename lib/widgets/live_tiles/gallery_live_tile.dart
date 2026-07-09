import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// Cycles through the latest photos from the device's real photo library
/// via photo_manager, mirroring the RN `GalleryLiveTile` (expo-media-library
/// backed). No stock/mocked images.
class GalleryLiveTile extends StatefulWidget {
  final double width;
  final double height;
  final bool animated;

  const GalleryLiveTile({
    super.key,
    required this.width,
    required this.height,
    this.animated = true,
  });

  @override
  State<GalleryLiveTile> createState() => _GalleryLiveTileState();
}

class _GalleryLiveTileState extends State<GalleryLiveTile> {
  List<Uint8List> _thumbnails = [];
  int _currentIndex = 0;
  bool _permissionDenied = false;
  Timer? _cycleTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      if (mounted) setState(() => _permissionDenied = true);
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    if (albums.isEmpty) return;

    final assets = await albums.first.getAssetListPaged(page: 0, size: 24);
    final thumbs = <Uint8List>[];
    for (final asset in assets) {
      final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(300, 300));
      if (thumb != null) thumbs.add(thumb);
    }

    if (mounted) {
      setState(() => _thumbnails = thumbs);
      if (thumbs.isNotEmpty && widget.animated) {
        _cycleTimer = Timer.periodic(const Duration(seconds: 3), (_) {
          if (mounted) {
            setState(() => _currentIndex = (_currentIndex + 1) % _thumbnails.length);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final minDim = widget.width < widget.height ? widget.width : widget.height;

    if (_permissionDenied || _thumbnails.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Icon(Icons.photo_library_outlined, size: minDim * 0.5, color: Colors.white70),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Image.memory(
          _thumbnails[_currentIndex],
          key: ValueKey(_currentIndex),
          fit: BoxFit.cover,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}
