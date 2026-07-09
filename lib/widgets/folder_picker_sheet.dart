import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_catalog.dart';
import '../models/home_item.dart';
import '../state/launcher_provider.dart';

class FolderPickerSheet extends StatefulWidget {
  final HomeApp item;
  final int pageIndex;

  const FolderPickerSheet({
    super.key,
    required this.item,
    required this.pageIndex,
  });

  @override
  State<FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<FolderPickerSheet> {
  bool _creatingNew = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final launcher = context.watch<LauncherProvider>();
    final accent = launcher.accent.color;

    final folders = launcher.pages
        .expand((p) => p)
        .whereType<HomeFolder>()
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Move to folder',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // New folder row
          if (!_creatingNew)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.create_new_folder, color: Colors.white, size: 20),
              ),
              title: const Text('New folder…', style: TextStyle(color: Colors.white)),
              onTap: () => setState(() => _creatingNew = true),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Folder name',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _confirmNew(launcher),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _confirmNew(launcher),
                  style: TextButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Create'),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => setState(() {
                    _creatingNew = false;
                    _nameController.clear();
                  }),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),

          if (folders.isNotEmpty) ...[
            const Divider(color: Colors.white12, height: 24),
            ...folders.map((folder) {
              final previewApps = folder.appIds
                  .take(4)
                  .map(findCatalogApp)
                  .whereType<CatalogApp>()
                  .toList();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _FolderPreview(apps: previewApps, accent: accent),
                title: Text(folder.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${folder.appIds.length} app${folder.appIds.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                onTap: () {
                  launcher.moveAppToFolder(widget.pageIndex, widget.item.uid, folder.uid);
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  void _confirmNew(LauncherProvider launcher) {
    final name = _nameController.text.trim();
    launcher.moveAppToNewFolder(widget.pageIndex, widget.item.uid, name);
    Navigator.of(context).pop();
  }
}

class _FolderPreview extends StatelessWidget {
  final List<CatalogApp> apps;
  final Color accent;

  const _FolderPreview({required this.apps, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: apps.isEmpty
          ? const Icon(Icons.folder, color: Colors.white54, size: 22)
          : GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(4),
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              children: apps
                  .map((a) => Icon(a.icon, size: 12, color: Colors.white70))
                  .toList(),
            ),
    );
  }
}
