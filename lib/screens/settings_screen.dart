import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_catalog.dart';
import '../models/home_item.dart';
import '../models/tile_size.dart';
import '../state/launcher_provider.dart';

/// Toggles for grid columns (4/6), accent color, wallpaper, labels,
/// animations and default tile size — mirroring the RN `SettingsSheet`.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final launcher = context.watch<LauncherProvider>();
    final settings = launcher.settings;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0D10),
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _sectionLabel("Layout"),
          ListTile(
            title: const Text("Grid density", style: TextStyle(color: Colors.white)),
            subtitle: Text("${settings.columns} columns", style: const TextStyle(color: Colors.white54)),
            trailing: SegmentedButton<int>(
              segments: gridColumnOptions
                  .map((c) => ButtonSegment(value: c, label: Text("$c")))
                  .toList(),
              selected: {settings.columns},
              onSelectionChanged: (s) => launcher.setColumns(s.first),
            ),
          ),
          SwitchListTile(
            title: const Text("Show labels", style: TextStyle(color: Colors.white)),
            value: settings.showLabels,
            onChanged: launcher.setShowLabels,
          ),
          SwitchListTile(
            title: const Text("Tile animations", style: TextStyle(color: Colors.white)),
            value: settings.tileAnimations,
            onChanged: launcher.setTileAnimations,
          ),
          SwitchListTile(
            title: const Text("Swipe up for app drawer", style: TextStyle(color: Colors.white)),
            value: settings.swipeUpDrawer,
            onChanged: launcher.setSwipeUpDrawer,
          ),
          SwitchListTile(
            title: const Text("Double-tap to lock", style: TextStyle(color: Colors.white)),
            value: settings.doubleTapLock,
            onChanged: launcher.setDoubleTapLock,
          ),
          SwitchListTile(
            title: const Text("Haptic feedback", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Vibrate on tile tap", style: TextStyle(color: Colors.white54)),
            value: settings.hapticFeedback,
            onChanged: launcher.setHapticFeedback,
          ),
          _sectionLabel("Live tiles"),
          SwitchListTile(
            title: const Text("24-hour clock", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Show 14:30 instead of 2:30 pm", style: TextStyle(color: Colors.white54)),
            value: settings.clock24Hour,
            onChanged: launcher.setClock24Hour,
          ),
          SwitchListTile(
            title: const Text("Use Fahrenheit", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Weather tile temperature unit", style: TextStyle(color: Colors.white54)),
            value: settings.useFahrenheit,
            onChanged: launcher.setUseFahrenheit,
          ),
          _sectionLabel("Accent color"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: accentOptions.map((a) {
                final selected = a.id == settings.accentId;
                return GestureDetector(
                  onTap: () => launcher.setAccent(a.id),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: a.color,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _sectionLabel("Wallpaper"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: wallpaperOptions.map((w) {
                final selected = w.id == settings.wallpaperId;
                return GestureDetector(
                  onTap: () => launcher.setWallpaper(w.id),
                  child: Container(
                    width: 56,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: w.colors),
                      borderRadius: BorderRadius.circular(6),
                      border: selected ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _sectionLabel("Manage tiles"),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              "Turn tiles on to show them on the Start screen, off to hide "
              "them without deleting. Tap the pencil to rename, resize, "
              "recolor, or set transparency.",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          ...launcher.allItems.map((item) {
            final label = item is HomeFolder ? item.name : (findCatalogApp((item as HomeApp).appId)?.name ?? item.appId);
            final icon = item is HomeFolder ? Icons.folder : (findCatalogApp((item as HomeApp).appId)?.icon ?? Icons.apps);
            return ListTile(
              leading: Icon(icon, color: Colors.white70),
              title: Text(label, style: const TextStyle(color: Colors.white)),
              subtitle: Text(item.size.name, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
                    onPressed: () => _showEditTileDialog(context, launcher, item),
                  ),
                  Switch(
                    value: !item.hidden,
                    onChanged: (on) => launcher.setTileHidden(item.uid, !on),
                  ),
                ],
              ),
            );
          }),
          _sectionLabel("Backup"),
          ListTile(
            title: const Text("Export layout", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Copy your tiles & settings as JSON", style: TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.upload_outlined, color: Colors.white54),
            onTap: () => _showExportDialog(context, launcher),
          ),
          ListTile(
            title: const Text("Import layout", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Paste a previously exported JSON backup", style: TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.download_outlined, color: Colors.white54),
            onTap: () => _showImportDialog(context, launcher),
          ),
          _sectionLabel("Reset"),
          ListTile(
            title: const Text("Reset to default layout", style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1C22),
                  title: const Text("Reset layout?", style: TextStyle(color: Colors.white)),
                  content: const Text(
                    "This removes all tile customizations and restores the starter layout.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Reset", style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
              if (confirm == true) launcher.resetToDefault();
            },
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, LauncherProvider launcher) {
    final json = launcher.exportState();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C22),
        title: const Text("Export layout", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(json, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Copy to clipboard"),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, LauncherProvider launcher) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C22),
        title: const Text("Import layout", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 10,
            minLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: const InputDecoration(
              hintText: "Paste exported JSON here",
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final ok = launcher.importState(controller.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? "Layout imported" : "Invalid backup JSON — import failed"),
                ),
              );
            },
            child: const Text("Import"),
          ),
        ],
      ),
    );
  }

  void _showEditTileDialog(BuildContext context, LauncherProvider launcher, HomeItem item) {
    final nameController = item is HomeFolder ? TextEditingController(text: item.name) : null;

    showDialog(
      context: context,
      builder: (ctx) {
        TileSize selectedSize = item.size;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1C22),
              title: Text(
                item is HomeFolder ? "Edit folder" : "Edit tile",
                style: const TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (nameController != null) ...[
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Folder name",
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text("Size", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TileSize.values.where((s) => s != TileSize.custom).map((s) {
                        final selected = s == selectedSize;
                        return ChoiceChip(
                          label: Text(s.name),
                          selected: selected,
                          onSelected: (_) => setDialogState(() => selectedSize = s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Color", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        GestureDetector(
                          onTap: () => launcher.setTileColor(item.uid, null),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white38),
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white54),
                          ),
                        ),
                        ...accentOptions.map((a) {
                          final hex = "#${a.color.value.toRadixString(16).substring(2)}";
                          final selected = item.color == hex;
                          return GestureDetector(
                            onTap: () => launcher.setTileColor(item.uid, hex),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: a.color,
                                shape: BoxShape.circle,
                                border: selected ? Border.all(color: Colors.white, width: 2) : null,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Transparent", style: TextStyle(color: Colors.white)),
                      value: item.transparent,
                      onChanged: (v) => launcher.setTileTransparent(item.uid, v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                TextButton(
                  onPressed: () {
                    launcher.setTileSize(item.uid, selectedSize);
                    if (nameController != null) {
                      launcher.renameFolder(item.uid, nameController.text.trim());
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
}
