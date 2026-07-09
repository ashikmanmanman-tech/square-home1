import 'package:flutter/material.dart';

import '../data/app_catalog.dart';

/// Renders a single app's glyph, sized to fill its tile the way the RN
/// `AppIcon` component did (icon occupies the majority of the tile, no
/// background chip behind it — the tile color itself is the background).
class AppIconWidget extends StatelessWidget {
  final CatalogApp app;
  final double size;
  final Color color;

  const AppIconWidget({
    super.key,
    required this.app,
    required this.size,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(app.icon, size: size, color: color);
  }
}
