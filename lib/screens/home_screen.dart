import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_catalog.dart';
import '../models/home_item.dart';
import '../state/launcher_provider.dart';
import '../utils/grid_packer.dart';
import '../widgets/app_drawer_sheet.dart';
import '../widgets/app_tile.dart';
import '../widgets/folder_picker_sheet.dart';
import 'settings_screen.dart';

const _gapPx = 6.0;

Color _colorFromHex(String hex) {
  final cleaned = hex.replaceFirst("#", "");
  return Color(int.parse("FF$cleaned", radix: 16));
}

/// The Start screen: horizontally-swipeable pages of tiles, each packed into
/// a base-unit grid (see grid_packer.dart), matching the RN `HomeGrid`'s
/// Metro tile flow. Long-press toggles jiggle/edit mode with a remove ("x")
/// affordance and a folder-plus button to move app tiles into folders.
/// Swipe up (or tap the drawer arrow) opens the app drawer.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _editMode = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, anim, __) => FadeTransition(
          opacity: anim,
          child: const AppDrawerSheet(),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _handleTap(LauncherProvider launcher, HomeItem item) {
    if (_editMode) return;
    if (launcher.settings.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    if (item is HomeApp && item.appId == "settings") {
      _openSettings();
    }
    // Other apps are placeholders in this generic launcher — real device
    // apps (Phone, Messages, etc.) aren't launchable from a third-party
    // Flutter app without OS-level intents that vary per platform.
  }

  @override
  Widget build(BuildContext context) {
    final launcher = context.watch<LauncherProvider>();

    if (!launcher.loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0D10),
        body: Center(child: CircularProgressIndicator(color: Colors.white54)),
      );
    }

    final pageCount = launcher.pages.length;
    if (_currentPage >= pageCount) _currentPage = pageCount - 1;
    final wallpaper = launcher.wallpaper;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: wallpaper.colors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Colors.white),
                      onPressed: _openSettings,
                    ),
                    Row(
                      children: [
                        if (_editMode)
                          IconButton(
                            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                            tooltip: "Add page",
                            onPressed: () {
                              launcher.addPage();
                              Future.delayed(const Duration(milliseconds: 50), () {
                                if (_pageController.hasClients) {
                                  _pageController.animateToPage(
                                    launcher.pages.length - 1,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  );
                                }
                              });
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            _editMode ? Icons.check : Icons.apps,
                            color: Colors.white,
                          ),
                          onPressed: () => setState(() => _editMode = !_editMode),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: _openDrawer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (launcher.settings.swipeUpDrawer &&
                        (details.primaryVelocity ?? 0) < -300) {
                      _openDrawer();
                    }
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pageCount,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, pageIndex) {
                      return _buildPage(launcher, pageIndex);
                    },
                  ),
                ),
              ),
              if (pageCount > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pageCount, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(LauncherProvider launcher, int pageIndex) {
    final page = launcher.pages[pageIndex].where((item) => !item.hidden).toList();
    final columns = launcher.settings.columns;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth - 16;
        final unit = (totalWidth - _gapPx * (columns - 1)) / columns;
        final packed = packTiles(page, columns);
        final rowCount = packedGridRowCount(packed);
        final gridHeight = rowCount * unit + (rowCount - 1) * _gapPx;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SizedBox(
            width: totalWidth,
            height: gridHeight < 0 ? 0 : gridHeight,
            child: Stack(
              children: packed.map((tile) {
                final left = tile.col * (unit + _gapPx);
                final top = tile.row * (unit + _gapPx);
                final w = tile.cols * unit + (tile.cols - 1) * _gapPx;
                final h = tile.rows * unit + (tile.rows - 1) * _gapPx;

                return Positioned(
                  left: left,
                  top: top,
                  width: w,
                  height: h,
                  child: _buildTile(launcher, tile.item, w, h, pageIndex),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile(
    LauncherProvider launcher,
    HomeItem item,
    double w,
    double h,
    int pageIndex,
  ) {
    Widget tile;
    if (item is HomeFolder) {
      final firstApp = item.appIds.isNotEmpty ? findCatalogApp(item.appIds.first) : null;
      final resolvedColor = item.color != null
          ? _colorFromHex(item.color!)
          : (firstApp?.color ?? const Color(0xFF2C2C2C));
      final bg = item.transparent ? resolvedColor.withOpacity(0.0) : resolvedColor;
      tile = FolderTileContainer(
        name: item.name,
        appIds: item.appIds,
        width: w,
        height: h,
        backgroundColor: bg,
        showLabels: launcher.settings.showLabels,
        onTap: () => _handleTap(launcher, item),
        onLongPress: () => setState(() => _editMode = true),
      );
    } else {
      final app = item as HomeApp;
      final catalogApp = findCatalogApp(app.appId);
      final resolvedColor =
          app.color != null ? _colorFromHex(app.color!) : (catalogApp?.color ?? Colors.grey);
      final bg = app.transparent ? resolvedColor.withOpacity(0.0) : resolvedColor;
      tile = AppTileWidget(
        appId: app.appId,
        width: w,
        height: h,
        backgroundColor: bg,
        showLabels: launcher.settings.showLabels,
        tileAnimations: launcher.settings.tileAnimations,
        clock24Hour: launcher.settings.clock24Hour,
        useFahrenheit: launcher.settings.useFahrenheit,
        onTap: () => _handleTap(launcher, item),
        onLongPress: () => setState(() => _editMode = true),
      );
    }

    final withOverlays = !_editMode
        ? tile
        : Stack(
            clipBehavior: Clip.none,
            children: [
              tile,
              Positioned(
                right: -6,
                top: -6,
                child: GestureDetector(
                  onTap: () => launcher.removeItem(pageIndex, item.uid),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                left: -6,
                top: -6,
                child: GestureDetector(
                  onTap: () => launcher.setTileTransparent(item.uid, !item.transparent),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: item.transparent ? Colors.white : Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.transparent ? Icons.blur_off : Icons.blur_on,
                      size: 14,
                      color: item.transparent ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );

    if (!_editMode) return withOverlays;

    // Edit mode: show a folder-plus button on app tiles (not folders).
    // Tapping it opens a bottom sheet to move the app into a new or existing folder.
    if (item is! HomeApp) return withOverlays;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        withOverlays,
        Positioned(
          right: -6,
          top: (h - 22) / 2,
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => FolderPickerSheet(
                  item: item,
                  pageIndex: pageIndex,
                ),
              );
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.create_new_folder, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
