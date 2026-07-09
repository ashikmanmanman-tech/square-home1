import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// A grid of real contact photos that independently cross-fade, mirroring
/// the RN `ContactsLiveTile`. Always fills every cell — if there are fewer
/// photo-having contacts than cells, contacts are cycled/repeated via
/// modulo rather than leaving blank cells.
class ContactsLiveTile extends StatefulWidget {
  final double width;
  final double height;
  final bool animated;
  final int gridCols;
  final int gridRows;

  const ContactsLiveTile({
    super.key,
    required this.width,
    required this.height,
    this.animated = true,
    this.gridCols = 2,
    this.gridRows = 2,
  });

  @override
  State<ContactsLiveTile> createState() => _ContactsLiveTileState();
}

class _ContactsLiveTileState extends State<ContactsLiveTile> {
  List<Uint8List> _photos = [];
  bool _permissionDenied = false;
  final Map<int, int> _cellPhotoIndex = {};
  Timer? _shuffleTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final granted = await FlutterContacts.requestPermission(readonly: true);
    if (!granted) {
      if (mounted) setState(() => _permissionDenied = true);
      return;
    }
    final contacts = await FlutterContacts.getContacts(withPhoto: true);
    final photos = <Uint8List>[
      for (final c in contacts)
        if (c.photoOrThumbnail != null) c.photoOrThumbnail!,
    ];
    if (mounted) {
      setState(() => _photos = photos);
      final cellCount = widget.gridCols * widget.gridRows;
      for (var i = 0; i < cellCount; i++) {
        _cellPhotoIndex[i] = photos.isEmpty ? -1 : i % photos.length;
      }
      if (photos.isNotEmpty && widget.animated) {
        _shuffleTimer = Timer.periodic(const Duration(seconds: 4), (_) {
          if (!mounted) return;
          setState(() {
            final cell = DateTime.now().millisecondsSinceEpoch % cellCount;
            _cellPhotoIndex[cell] =
                (( _cellPhotoIndex[cell] ?? 0) + 1) % _photos.length;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied || _photos.isEmpty) {
      final minDim = widget.width < widget.height ? widget.width : widget.height;
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Icon(Icons.people_alt, size: minDim * 0.5, color: Colors.white70),
        ),
      );
    }

    final cellWidth = widget.width / widget.gridCols;
    final cellHeight = widget.height / widget.gridRows;
    final cellCount = widget.gridCols * widget.gridRows;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Wrap(
        children: List.generate(cellCount, (index) {
          final photoIdx = _cellPhotoIndex[index] ?? (index % _photos.length);
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: SizedBox(
              key: ValueKey("$index-$photoIdx"),
              width: cellWidth,
              height: cellHeight,
              child: Image.memory(_photos[photoIdx], fit: BoxFit.cover),
            ),
          );
        }),
      ),
    );
  }
}
