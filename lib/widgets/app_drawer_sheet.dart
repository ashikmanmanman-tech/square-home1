import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_catalog.dart';
import '../state/launcher_provider.dart';
import 'app_icon.dart';

/// Full-screen app drawer: alphabetical list of every catalog app, with
/// search filtering and long-press (350ms) to add to Home, mirroring the
/// RN `AppDrawerSheet`.
class AppDrawerSheet extends StatefulWidget {
  const AppDrawerSheet({super.key});

  @override
  State<AppDrawerSheet> createState() => _AppDrawerSheetState();
}

class _AppDrawerSheetState extends State<AppDrawerSheet> {
  final _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final launcher = context.watch<LauncherProvider>();
    final filtered = appCatalog
        .where((app) => app.name.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final grouped = <String, List<CatalogApp>>{};
    for (final app in filtered) {
      final letter = app.name[0].toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(app);
    }
    final letters = grouped.keys.toList()..sort();

    return Material(
      color: const Color(0xFF0C0D10),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Search apps",
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.search, color: Colors.white38),
                        filled: true,
                        fillColor: Color(0xFF1A1C22),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: letters.length,
                itemBuilder: (context, sectionIndex) {
                  final letter = letters[sectionIndex];
                  final apps = grouped[letter]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ...apps.map((app) {
                        final installed = launcher.installedAppIds.contains(app.id);
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: app.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(child: AppIconWidget(app: app, size: 22)),
                          ),
                          title: Text(app.name, style: const TextStyle(color: Colors.white)),
                          trailing: installed
                              ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18)
                              : null,
                          onLongPress: () {
                            launcher.addAppToHome(app.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 2),
                                content: Text(
                                  installed
                                      ? "${app.name} is already on Home"
                                      : "Added ${app.name} to Home",
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
