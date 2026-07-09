import 'package:flutter/material.dart';

import '../data/app_catalog.dart';
import 'app_icon.dart';
import 'folder_tile.dart';
import 'live_tiles/battery_live_tile.dart';
import 'live_tiles/calendar_live_tile.dart';
import 'live_tiles/clock_live_tile.dart';
import 'live_tiles/contacts_live_tile.dart';
import 'live_tiles/gallery_live_tile.dart';
import 'live_tiles/maps_live_tile.dart';
import 'live_tiles/weather_live_tile.dart';
import 'live_tiles/youtube_live_tile.dart';

const _liveTileAppIds = {
  "contacts",
  "weather",
  "calendar",
  "gallery",
  "clock",
  "youtube",
  "maps",
  "battery",
};

/// Renders a single app tile: either one of the real-data "Live Tiles"
/// (Contacts/Weather/Calendar/Gallery/Clock/YouTube/Maps) or a generic
/// icon + label tile. Live tiles never show the redundant app-name label,
/// matching the RN `AppTile`'s `isLiveTile` suppression (their own content
/// already fills the tile, including the bottom edge).
class AppTileWidget extends StatelessWidget {
  final String appId;
  final double width;
  final double height;
  final bool showLabels;
  final bool tileAnimations;
  final Color backgroundColor;
  final bool clock24Hour;
  final bool useFahrenheit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AppTileWidget({
    super.key,
    required this.appId,
    required this.width,
    required this.height,
    required this.backgroundColor,
    this.showLabels = true,
    this.tileAnimations = true,
    this.clock24Hour = false,
    this.useFahrenheit = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final app = findCatalogApp(appId);
    final isLiveTile = _liveTileAppIds.contains(appId);
    final minDim = width < height ? width : height;
    final tilePadding = (minDim * 0.09).clamp(4.0, 8.0);
    final iconSize = minDim * 0.62;
    final contentWidth = (width - tilePadding * 2).clamp(0.0, double.infinity);
    final contentHeight = (height - tilePadding * 2).clamp(0.0, double.infinity);

    Widget content;
    switch (appId) {
      case "contacts":
        content = ContactsLiveTile(
          width: contentWidth,
          height: contentHeight,
          animated: tileAnimations,
        );
        break;
      case "weather":
        content = WeatherLiveTile(
          width: contentWidth,
          height: contentHeight,
          useFahrenheit: useFahrenheit,
        );
        break;
      case "calendar":
        content = CalendarLiveTile(width: contentWidth, height: contentHeight);
        break;
      case "gallery":
        content = GalleryLiveTile(
          width: contentWidth,
          height: contentHeight,
          animated: tileAnimations,
        );
        break;
      case "clock":
        content = ClockLiveTile(
          width: contentWidth,
          height: contentHeight,
          use24Hour: clock24Hour,
        );
        break;
      case "youtube":
        content = YouTubeLiveTile(
          width: contentWidth,
          height: contentHeight,
          animated: tileAnimations,
        );
        break;
      case "maps":
        content = MapsLiveTile(width: contentWidth, height: contentHeight);
        break;
      case "battery":
        content = BatteryLiveTile(width: contentWidth, height: contentHeight);
        break;
      default:
        content = app != null
            ? AppIconWidget(app: app, size: iconSize)
            : const Icon(Icons.apps, color: Colors.white);
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(tilePadding),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(2)),
        child: isLiveTile
            ? content
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Center(child: content)),
                  if (showLabels && app != null)
                    Text(
                      app.name,
                      maxLines: height < 70 ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Wraps [FolderTileWidget] with the same tile chrome (background, padding,
/// tap handlers) used by app tiles.
class FolderTileContainer extends StatelessWidget {
  final String name;
  final List<String> appIds;
  final double width;
  final double height;
  final Color backgroundColor;
  final bool showLabels;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FolderTileContainer({
    super.key,
    required this.name,
    required this.appIds,
    required this.width,
    required this.height,
    required this.backgroundColor,
    this.showLabels = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(2)),
        child: FolderTileWidget(
          name: name,
          appIds: appIds,
          width: width,
          height: height,
          showLabel: showLabels,
        ),
      ),
    );
  }
}
