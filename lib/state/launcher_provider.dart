import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/app_catalog.dart';
import '../models/home_item.dart';
import '../models/tile_size.dart';

class AccentOption {
  final String id;
  final String label;
  final Color color;
  const AccentOption(this.id, this.label, this.color);
}

class WallpaperOption {
  final String id;
  final String label;
  final List<Color> colors;
  const WallpaperOption(this.id, this.label, this.colors);
}

const List<AccentOption> accentOptions = [
  AccentOption("amber", "Amber", Color(0xFFFF7A3D)),
  AccentOption("coral", "Coral", Color(0xFFFF5470)),
  AccentOption("mint", "Mint", Color(0xFF2DD4A7)),
  AccentOption("sky", "Sky", Color(0xFF3FA9FF)),
  AccentOption("violet", "Violet", Color(0xFFA06BFF)),
  AccentOption("lime", "Lime", Color(0xFFB3D130)),
];

const List<String> tileColorPalette = [
  "#ff7a3d",
  "#ff5470",
  "#e91e8c",
  "#a06bff",
  "#5b6bff",
  "#3fa9ff",
  "#2dd4a7",
  "#4caf50",
  "#b3d130",
  "#ffc542",
  "#8d6e63",
  "#607d8b",
];

const List<WallpaperOption> wallpaperOptions = [
  WallpaperOption("midnight", "Midnight", [Color(0xFF0C0D10), Color(0xFF1A1C22)]),
  WallpaperOption("dusk", "Dusk", [Color(0xFF1A0F1F), Color(0xFF0C0D10)]),
  WallpaperOption("forest", "Forest", [Color(0xFF0C1712), Color(0xFF0C0D10)]),
  WallpaperOption("ocean", "Ocean", [Color(0xFF081420), Color(0xFF0C0D10)]),
  WallpaperOption("ember", "Ember", [Color(0xFF201007), Color(0xFF0C0D10)]),
  WallpaperOption("slate", "Slate", [Color(0xFF111318), Color(0xFF0C0D10)]),
];

/// Base column density options for the Start screen ("more tiles" toggle).
const List<int> gridColumnOptions = [4, 6];

const _uuid = Uuid();
const _storageKey = "square_home_v1";

HomeApp _starterItem(String appId, {TileSize size = TileSize.small}) {
  return HomeApp(uid: "app-$appId", appId: appId, size: size);
}

List<HomeItem> _defaultPage() => [
      _starterItem("phone", size: TileSize.wide),
      _starterItem("messages"),
      _starterItem("browser"),
      _starterItem("mail", size: TileSize.large),
      _starterItem("camera"),
      _starterItem("gallery"),
      _starterItem("contacts", size: TileSize.large),
      _starterItem("calendar", size: TileSize.wide),
      _starterItem("weather"),
      _starterItem("clock", size: TileSize.wide),
      _starterItem("youtube", size: TileSize.large),
      const HomeFolder(
        uid: "folder-utilities",
        name: "Utilities",
        appIds: ["calculator", "notes", "files", "flashlight"],
        size: TileSize.large,
      ),
      const HomeFolder(
        uid: "folder-social",
        name: "Social",
        appIds: [
          "facebook",
          "instagram",
          "whatsapp",
          "twitter",
          "messenger",
          "tiktok",
          "youtube",
          "linkedin",
          "spotify",
          "snapchat",
          "reddit",
          "telegram",
        ],
        size: TileSize.large,
      ),
      _starterItem("music"),
      _starterItem("maps", size: TileSize.wide),
      _starterItem("settings"),
    ];

class LauncherSettings {
  int columns;
  String accentId;
  String wallpaperId;
  bool doubleTapLock;
  bool swipeUpDrawer;
  bool showLabels;
  bool tileAnimations;
  TileSize defaultTileSize;
  Map<String, String> customIconMap;
  bool hapticFeedback;
  bool clock24Hour;
  bool useFahrenheit;

  LauncherSettings({
    this.columns = 4,
    this.accentId = "amber",
    this.wallpaperId = "midnight",
    this.doubleTapLock = false,
    this.swipeUpDrawer = true,
    this.showLabels = true,
    this.tileAnimations = true,
    this.defaultTileSize = TileSize.small,
    Map<String, String>? customIconMap,
    this.hapticFeedback = true,
    this.clock24Hour = false,
    this.useFahrenheit = false,
  }) : customIconMap = customIconMap ?? {};

  LauncherSettings copy() => LauncherSettings(
        columns: columns,
        accentId: accentId,
        wallpaperId: wallpaperId,
        doubleTapLock: doubleTapLock,
        swipeUpDrawer: swipeUpDrawer,
        showLabels: showLabels,
        tileAnimations: tileAnimations,
        defaultTileSize: defaultTileSize,
        customIconMap: Map.of(customIconMap),
        hapticFeedback: hapticFeedback,
        clock24Hour: clock24Hour,
        useFahrenheit: useFahrenheit,
      );

  Map<String, dynamic> toJson() => {
        "columns": columns,
        "accentId": accentId,
        "wallpaperId": wallpaperId,
        "doubleTapLock": doubleTapLock,
        "swipeUpDrawer": swipeUpDrawer,
        "showLabels": showLabels,
        "tileAnimations": tileAnimations,
        "defaultTileSize": tileSizeToJson(defaultTileSize),
        "customIconMap": customIconMap,
        "hapticFeedback": hapticFeedback,
        "clock24Hour": clock24Hour,
        "useFahrenheit": useFahrenheit,
      };

  factory LauncherSettings.fromJson(Map<String, dynamic> json) =>
      LauncherSettings(
        columns: (json["columns"] as int?) ?? 4,
        accentId: (json["accentId"] as String?) ?? "amber",
        wallpaperId: (json["wallpaperId"] as String?) ?? "midnight",
        doubleTapLock: (json["doubleTapLock"] as bool?) ?? false,
        swipeUpDrawer: (json["swipeUpDrawer"] as bool?) ?? true,
        showLabels: (json["showLabels"] as bool?) ?? true,
        tileAnimations: (json["tileAnimations"] as bool?) ?? true,
        defaultTileSize: tileSizeFromJson(json["defaultTileSize"] as String?),
        customIconMap: (json["customIconMap"] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as String)) ??
            {},
        hapticFeedback: (json["hapticFeedback"] as bool?) ?? true,
        clock24Hour: (json["clock24Hour"] as bool?) ?? false,
        useFahrenheit: (json["useFahrenheit"] as bool?) ?? false,
      );
}

/// App-wide launcher state: pages of tiles + settings, persisted to
/// SharedPreferences. Mirrors the RN `LauncherContext`.
class LauncherProvider extends ChangeNotifier {
  List<List<HomeItem>> pages = [_defaultPage()];
  LauncherSettings settings = LauncherSettings();
  bool loaded = false;

  LauncherProvider() {
    _hydrate();
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final parsed = jsonDecode(raw) as Map<String, dynamic>;
        final rawPages = parsed["pages"] as List<dynamic>?;
        if (rawPages != null) {
          pages = rawPages
              .map((page) => (page as List<dynamic>)
                  .map((item) => HomeItem.fromJson(item as Map<String, dynamic>))
                  .toList())
              .toList();
        }
        final rawSettings = parsed["settings"] as Map<String, dynamic>?;
        if (rawSettings != null) {
          settings = LauncherSettings.fromJson(rawSettings);
        }
      }
    } catch (_) {
      // Corrupt storage — fall back to defaults, matching RN behavior.
    } finally {
      loaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final state = {
      "pages": pages.map((page) => page.map((i) => i.toJson()).toList()).toList(),
      "settings": settings.toJson(),
    };
    await prefs.setString(_storageKey, jsonEncode(state));
  }

  void _commit() {
    notifyListeners();
    _persist();
  }

  AccentOption get accent =>
      accentOptions.firstWhere((a) => a.id == settings.accentId, orElse: () => accentOptions.first);

  WallpaperOption get wallpaper => wallpaperOptions
      .firstWhere((w) => w.id == settings.wallpaperId, orElse: () => wallpaperOptions.first);

  Set<String> get installedAppIds {
    final set = <String>{};
    for (final page in pages) {
      for (final item in page) {
        if (item is HomeApp) {
          set.add(item.appId);
        } else if (item is HomeFolder) {
          set.addAll(item.appIds);
        }
      }
    }
    return set;
  }

  void addAppToHome(String appId) {
    final alreadyThere = pages.any((page) => page.any((item) =>
        (item is HomeApp && item.appId == appId) ||
        (item is HomeFolder && item.appIds.contains(appId))));
    if (alreadyThere) return;

    final item = HomeApp(
      uid: "app-$appId-${_uuid.v4().substring(0, 8)}",
      appId: appId,
      size: settings.defaultTileSize,
    );
    if (pages.isEmpty) pages.add([]);
    pages[0] = [...pages[0], item];
    _commit();
  }

  void removeItem(int pageIndex, String uid) {
    if (pageIndex < 0 || pageIndex >= pages.length) return;
    pages[pageIndex] = pages[pageIndex].where((i) => i.uid != uid).toList();
    pages = pages
        .asMap()
        .entries
        .where((e) => e.value.isNotEmpty || e.key == 0)
        .map((e) => e.value)
        .toList();
    _commit();
  }

  void renameFolder(String uid, String name) {
    pages = pages
        .map((page) => page
            .map((item) =>
                item is HomeFolder && item.uid == uid ? item.copyWith(name: name) : item)
            .toList())
        .toList();
    _commit();
  }

  void removeAppFromFolder(String folderUid, String appId) {
    pages = pages
        .map((page) => page
            .map((item) => item is HomeFolder && item.uid == folderUid
                ? item.copyWith(appIds: item.appIds.where((id) => id != appId).toList())
                : item)
            .toList())
        .toList();
    _commit();
  }

  void moveAppToFolder(int pageIndex, String appUid, String folderUid) {
    if (pageIndex < 0 || pageIndex >= pages.length) return;
    final page = List<HomeItem>.of(pages[pageIndex]);
    final appIdx = page.indexWhere((i) => i.uid == appUid && i is HomeApp);
    if (appIdx == -1) return;
    final appItem = page[appIdx] as HomeApp;
    final folderIdx = page.indexWhere((i) => i.uid == folderUid && i is HomeFolder);
    if (folderIdx == -1) return;
    final folder = page[folderIdx] as HomeFolder;
    if (folder.appIds.contains(appItem.appId)) return;
    page[folderIdx] = folder.copyWith(appIds: [...folder.appIds, appItem.appId]);
    page.removeAt(appIdx);
    pages[pageIndex] = page;
    _commit();
  }

  void moveAppToNewFolder(int pageIndex, String appUid, String folderName) {
    if (pageIndex < 0 || pageIndex >= pages.length) return;
    final page = List<HomeItem>.of(pages[pageIndex]);
    final appIdx = page.indexWhere((i) => i.uid == appUid && i is HomeApp);
    if (appIdx == -1) return;
    final appItem = page[appIdx] as HomeApp;
    final newFolder = HomeFolder(
      uid: "folder-${DateTime.now().millisecondsSinceEpoch}",
      name: folderName.isEmpty ? "New Folder" : folderName,
      appIds: [appItem.appId],
      size: appItem.size,
    );
    page[appIdx] = newFolder;
    pages[pageIndex] = page;
    _commit();
  }

  void reorderPage(int pageIndex, int from, int to) {
    if (pageIndex < 0 || pageIndex >= pages.length) return;
    final page = List<HomeItem>.of(pages[pageIndex]);
    if (from == to || from < 0 || from >= page.length) return;
    final clampedTo = to.clamp(0, page.length - 1);
    final moved = page.removeAt(from);
    page.insert(clampedTo, moved);
    pages[pageIndex] = page;
    _commit();
  }

  void moveItemToPage(String uid, int fromPageIndex, int toPageIndex) {
    if (fromPageIndex < 0 ||
        fromPageIndex >= pages.length ||
        toPageIndex < 0 ||
        toPageIndex >= pages.length ||
        fromPageIndex == toPageIndex) {
      return;
    }
    final fromPage = List<HomeItem>.of(pages[fromPageIndex]);
    final idx = fromPage.indexWhere((i) => i.uid == uid);
    if (idx == -1) return;
    final item = fromPage.removeAt(idx);
    pages[fromPageIndex] = fromPage;
    pages[toPageIndex] = [...pages[toPageIndex], item];
    pages = pages
        .asMap()
        .entries
        .where((e) => e.value.isNotEmpty || e.key == 0)
        .map((e) => e.value)
        .toList();
    _commit();
  }

  void addPage() {
    pages = [...pages, <HomeItem>[]];
    _commit();
  }

  void removePage(int pageIndex) {
    if (pages.length <= 1) return;
    if (pageIndex < 0 || pageIndex >= pages.length) return;
    if (pages[pageIndex].isNotEmpty) return;
    pages = [...pages]..removeAt(pageIndex);
    _commit();
  }

  void setTileSize(String uid, TileSize size) {
    pages = pages
        .map((page) => page.map((item) => item.uid == uid ? item.withSize(size) : item).toList())
        .toList();
    _commit();
  }

  void setCustomSpan(String uid, TileSpan span) {
    pages = pages
        .map((page) =>
            page.map((item) => item.uid == uid ? item.withCustomSpan(span) : item).toList())
        .toList();
    _commit();
  }

  void setTileColor(String uid, String? color) {
    pages = pages
        .map((page) =>
            page.map((item) => item.uid == uid ? item.withColor(color) : item).toList())
        .toList();
    _commit();
  }

  void setTileTransparent(String uid, bool transparent) {
    pages = pages
        .map((page) => page
            .map((item) => item.uid == uid ? item.withTransparent(transparent) : item)
            .toList())
        .toList();
    _commit();
  }

  void setTileHidden(String uid, bool hidden) {
    pages = pages
        .map((page) =>
            page.map((item) => item.uid == uid ? item.withHidden(hidden) : item).toList())
        .toList();
    _commit();
  }

  /// All items across all pages, in page order, for management UIs like the
  /// Settings "Manage tiles" list.
  List<HomeItem> get allItems => pages.expand((page) => page).toList();

  void setColumns(int columns) {
    settings.columns = columns;
    _commit();
  }

  void setAccent(String accentId) {
    settings.accentId = accentId;
    _commit();
  }

  void setWallpaper(String wallpaperId) {
    settings.wallpaperId = wallpaperId;
    _commit();
  }

  void setDoubleTapLock(bool value) {
    settings.doubleTapLock = value;
    _commit();
  }

  void setSwipeUpDrawer(bool value) {
    settings.swipeUpDrawer = value;
    _commit();
  }

  void setShowLabels(bool value) {
    settings.showLabels = value;
    _commit();
  }

  void setTileAnimations(bool value) {
    settings.tileAnimations = value;
    _commit();
  }

  void setDefaultTileSize(TileSize size) {
    settings.defaultTileSize = size;
    _commit();
  }

  void setHapticFeedback(bool value) {
    settings.hapticFeedback = value;
    _commit();
  }

  void setClock24Hour(bool value) {
    settings.clock24Hour = value;
    _commit();
  }

  void setUseFahrenheit(bool value) {
    settings.useFahrenheit = value;
    _commit();
  }

  String exportState() {
    final state = {
      "pages": pages.map((page) => page.map((i) => i.toJson()).toList()).toList(),
      "settings": settings.toJson(),
    };
    return const JsonEncoder.withIndent("  ").convert(state);
  }

  bool importState(String json) {
    try {
      final parsed = jsonDecode(json) as Map<String, dynamic>;
      final rawPages = parsed["pages"] as List<dynamic>;
      pages = rawPages
          .map((page) => (page as List<dynamic>)
              .map((item) => HomeItem.fromJson(item as Map<String, dynamic>))
              .toList())
          .toList();
      settings = LauncherSettings.fromJson(parsed["settings"] as Map<String, dynamic>);
      _commit();
      return true;
    } catch (_) {
      return false;
    }
  }

  void resetToDefault() {
    pages = [_defaultPage()];
    settings = LauncherSettings();
    _commit();
  }
}
