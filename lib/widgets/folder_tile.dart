import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_catalog.dart';
import '../widgets/app_icon.dart';

const _shuffleIntervalMs = 2000;

/// All folders (regardless of app count) show a single icon that cycles
/// every 2s through the folder's apps, centered within the tile — matching
/// the simplified single-rotating-icon behavior of the RN `FolderTile`
/// (the earlier 2x2 rotating-grid look was intentionally dropped).
class FolderTileWidget extends StatefulWidget {
  final String name;
  final List<String> appIds;
  final double width;
  final double height;
  final bool showLabel;

  const FolderTileWidget({
    super.key,
    required this.name,
    required this.appIds,
    required this.width,
    required this.height,
    this.showLabel = true,
  });

  @override
  State<FolderTileWidget> createState() => _FolderTileWidgetState();
}

class _FolderTileWidgetState extends State<FolderTileWidget> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.appIds.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: _shuffleIntervalMs), (_) {
        if (mounted) setState(() => _index = (_index + 1) % widget.appIds.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minDim = widget.width < widget.height ? widget.width : widget.height;
    final tilePadding = minDim * 0.09 < 4 ? 4.0 : (minDim * 0.09 > 8 ? 8.0 : minDim * 0.09);
    final labelHeight = widget.showLabel ? 18.0 : 0.0;
    final gridWidth = (widget.width - tilePadding * 2).clamp(0.0, double.infinity);
    final gridHeight =
        (widget.height - tilePadding * 2 - labelHeight).clamp(0.0, double.infinity);
    final cellSize = (minDim * 0.8).clamp(0.0, gridWidth < gridHeight ? gridWidth : gridHeight);
    final miniIconSize = cellSize * 0.72;

    final currentAppId = widget.appIds.isNotEmpty
        ? widget.appIds[_index % widget.appIds.length]
        : null;
    final app = currentAppId != null ? findCatalogApp(currentAppId) : null;

    return Padding(
      padding: EdgeInsets.all(tilePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: app != null
                    ? SizedBox(
                        key: ValueKey(currentAppId),
                        width: cellSize,
                        height: cellSize,
                        child: Center(
                          child: AppIconWidget(app: app, size: miniIconSize),
                        ),
                      )
                    : SizedBox(key: const ValueKey("empty"), width: cellSize, height: cellSize),
              ),
            ),
          ),
          if (widget.showLabel)
            Text(
              widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
