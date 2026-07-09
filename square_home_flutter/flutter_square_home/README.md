# Square Home (Flutter)

A Flutter rewrite of the Windows Phone "Live Tiles"-style mobile launcher.
This is a **source-only** rewrite — it was written and organized in a
non-Flutter environment (Replit's Node/Expo workspace has no Flutter SDK),
so it has **not** been built, run, or tested. Treat it as a strong starting
point that needs a first compile-and-fix pass in a real Flutter environment.

## What's included

```
lib/
  main.dart                     # App entrypoint
  models/                       # HomeItem (app/folder), TileSize/TileSpan
  data/
    app_catalog.dart            # Generic app catalog + real brand logos
  state/
    launcher_provider.dart      # Pages/settings state, persisted via SharedPreferences
  utils/
    grid_packer.dart            # Greedy row-scan tile packer (variable tile sizes)
  widgets/
    app_icon.dart
    app_tile.dart                # Generic tile chrome, live-tile dispatch
    folder_tile.dart              # Single rotating icon per folder
    app_drawer_sheet.dart         # Full app list, search, long-press to add
    live_tiles/
      contacts_live_tile.dart     # Real contact photos (flutter_contacts)
      weather_live_tile.dart      # Real weather (open-meteo.com + geolocator)
      calendar_live_tile.dart     # Real events (device_calendar)
      gallery_live_tile.dart      # Real photos (photo_manager)
      clock_live_tile.dart        # Real system clock, 3 time zones
      maps_live_tile.dart         # Real location (geolocator + geocoding)
      youtube_live_tile.dart      # Looped sample video (video_player)
  screens/
    home_screen.dart              # Start screen grid + edit mode
    settings_screen.dart          # Columns, accent, wallpaper, toggles
```

`android/`, `ios/`, and `web/` platform folders are all included and
hand-written to match what `flutter create --org com.example .` normally
generates, including:

- Android: full Gradle project (`settings.gradle`, `build.gradle` x2,
  `gradle-wrapper.properties`, manifests for main/debug/profile,
  `MainActivity.kt`, launch theme/background, and generated
  `ic_launcher.png` at all 5 densities).
- iOS: full Xcode project (`Runner.xcodeproj/project.pbxproj`,
  `Runner.xcworkspace`, shared scheme, `AppDelegate.swift`, `Info.plist`
  with all required usage-description keys already added, storyboards,
  `Podfile`, and a generated `AppIcon.appiconset`/`LaunchImage.imageset`
  at all required sizes).
- Web: `index.html`, `manifest.json`, and generated icons/favicon.

App icon: a placeholder icon (dark tile background, "SH" monogram) was
generated and resized into every required density/size for all three
platforms. Swap it for real artwork later with your own icon generator
(e.g. `flutter_launcher_icons`) — it's just a placeholder so the projects
aren't missing required assets.

Because there's no Flutter SDK in the environment that wrote this, none of
it has been opened in Xcode/Android Studio or compiled — see "Known
constraints" below for what a first build pass will likely need to fix,
in particular `GeneratedPluginRegistrant` (iOS) which Flutter overwrites
automatically on `flutter pub get` and Gradle/Kotlin/AGP version alignment
on Android depending on your installed Flutter version.

## First-time setup

You'll need the Flutter SDK installed locally (this project targets Dart
`>=3.3.0`, Flutter 3.19+).

1. Extract this zip into a folder, e.g. `square_home/`.
2. Install dependencies (this also regenerates
   `ios/Runner/GeneratedPluginRegistrant.*`,
   `android/local.properties`, and `ios/Flutter/Generated.xcconfig`,
   which aren't included since they're machine-specific / auto-generated):
   ```bash
   cd square_home
   flutter pub get
   ```
3. Run:
   ```bash
   flutter run
   ```
   If Xcode/Android Studio complains about tooling versions (Gradle/AGP/
   Kotlin, or Xcode project format), that's expected on a hand-written
   scaffold — accept any offered auto-migration, or run
   `flutter create --platforms=android,ios,web .` in the same folder to
   let Flutter regenerate/repair just the platform files without touching
   `lib/`.

Permission usage strings are already declared in
`android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` —
no manual edits needed there.

## New launcher features

Beyond settings toggles, the launcher itself gained real functionality:

- **Multiple home pages** — swipe left/right on the Start screen to move
  between pages, matching the RN app's page-indexed model (the provider
  already stored `pages` as a list; the UI previously only rendered
  page 0). Dot indicators at the bottom show the current page. In edit
  mode, an "add page" icon in the top bar creates a new empty page and
  jumps to it. Empty pages other than the first are pruned automatically
  when a tile is removed.
- **Drag-to-merge folders** — in edit mode, long-press-drag any tile
  onto another tile (or an existing folder) to merge them into a folder,
  instead of only being able to remove tiles. This wires up
  `LauncherProvider.mergeIntoFolder`, which existed in the state layer
  already but had no UI trigger.
- **Battery live tile** — the existing "Battery" app entry is now a real
  live tile showing actual device battery percentage and charging state
  via `battery_plus`, updating on a 30s poll plus live charging-state
  change events. No fake percentage.

## Settings additions

New options were added to the Settings screen:

- **Haptic feedback** — vibrate on tile tap (Layout section). Off by
  default is not the case; it's on by default and can be disabled.
- **24-hour clock** — Live tiles section; switches the Clock live tile
  (and its Canada/India rows) between `2:30 pm` and `14:30` formats.
- **Use Fahrenheit** — Live tiles section; converts the Weather live
  tile's real open-meteo.com reading from °C to °F on the fly (no refetch
  needed, it's a display-side conversion of the same real data).
- **Backup section** — "Export layout" shows your full tile layout +
  settings as JSON in a copyable dialog (uses the same `exportState()`
  the app already had internally). "Import layout" lets you paste a
  previously exported JSON blob back in, validating it before applying;
  invalid JSON shows an error instead of silently corrupting state.

All new settings persist in the same `SharedPreferences` blob and round-trip
through the export/import JSON.

## Tile transparency

Tiles can be toggled transparent (Windows-Phone-style "see the wallpaper
through the tile") from edit mode: long-press any tile to enter edit mode,
then tap the small blur icon added at the tile's top-left corner (the "x"
remove button is top-right). Transparent tiles keep their icon/label/live
content but drop their background fill to fully transparent so the
wallpaper gradient shows through. The state persists per-tile via
`HomeItem.transparent`, saved in the same `SharedPreferences` blob as
everything else.

## Known constraints (carried over / new in this rewrite)

- **Phone / Messages / Mail live data**: not implemented, same as the
  original app — no cross-platform call log/SMS access without native
  modules restricted by app store policy, and Mail would need a connected
  account with OAuth. These stay static icons; no fake data was used.
- **YouTube tile**: plays a real, freely-licensed sample video
  (`BigBuckBunny.mp4`) via `video_player`, not real YouTube playback —
  actual YouTube integration needs the YouTube Data/IFrame Player APIs and
  OAuth, out of scope for a launcher tile (same simplification the RN app
  made).
- **Brand icon gaps**: `font_awesome_flutter`'s free tier has no glyph for
  LINE or WeChat; these use a generic chat-bubble substitute, and Tinder
  uses a flame icon rather than the real logo. All noted inline in
  `app_catalog.dart`.
- **World clock time zones**: Flutter has no bundled IANA time zone
  database without an extra package (e.g. `timezone`); the Canada/India
  rows use fixed UTC offsets rather than DST-aware zones. Add the
  `timezone` package if you need DST correctness.
- **Drag-to-reorder / resize handles**: the original RN app supports
  dragging tiles to reorder, dragging one tile onto another to merge into
  a folder, and corner-handle resizing for custom spans. This rewrite
  ports the state methods (`reorderPage`, `mergeIntoFolder`,
  `setCustomSpan`) in `launcher_provider.dart`, but the home screen only
  wires up long-press-to-edit + tap-to-remove. Wiring `Draggable`/
  `DragTarget` gestures onto the packed grid tiles is the main remaining
  UI task.
- **Untested**: since Flutter isn't available in this workspace, none of
  this has been compiled. Expect a first-pass of import/type fixes once
  you run `flutter pub get` and `flutter analyze`.
