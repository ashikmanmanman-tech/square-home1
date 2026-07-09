import '../models/home_item.dart';
import '../models/tile_size.dart';

/// A placed tile: its source [HomeItem] plus its top-left cell and span in
/// the base grid, produced by [packTiles].
class PackedTile {
  final HomeItem item;
  final int col;
  final int row;
  final int cols;
  final int rows;

  const PackedTile({
    required this.item,
    required this.col,
    required this.row,
    required this.cols,
    required this.rows,
  });
}

/// Greedy row-scan bin packer: walks items in order and places each one in
/// the first free slot (scanning left-to-right, top-to-bottom) that can fit
/// its span without overlapping previously-placed tiles. This mirrors the
/// Metro tile flow-packing approach used by the original app (variable-size
/// tiles don't lay out correctly with plain flex-wrap, since a wide/tall
/// tile can leave holes that a later small tile should fill).
List<PackedTile> packTiles(List<HomeItem> items, int columns) {
  final packed = <PackedTile>[];
  // occupied[row] = set of occupied column indices in that row.
  final occupied = <int, Set<int>>{};

  bool fits(int row, int col, int cols, int rows) {
    if (col + cols > columns) return false;
    for (var r = row; r < row + rows; r++) {
      final rowSet = occupied[r];
      if (rowSet == null) continue;
      for (var c = col; c < col + cols; c++) {
        if (rowSet.contains(c)) return false;
      }
    }
    return true;
  }

  void markOccupied(int row, int col, int cols, int rows) {
    for (var r = row; r < row + rows; r++) {
      occupied.putIfAbsent(r, () => <int>{});
      for (var c = col; c < col + cols; c++) {
        occupied[r]!.add(c);
      }
    }
  }

  for (final item in items) {
    final span = item.span;
    final cols = span.cols.clamp(1, columns);
    final rows = span.rows.clamp(1, 8);

    var placed = false;
    var row = 0;
    while (!placed) {
      for (var col = 0; col <= columns - cols; col++) {
        if (fits(row, col, cols, rows)) {
          markOccupied(row, col, cols, rows);
          packed.add(
            PackedTile(item: item, col: col, row: row, cols: cols, rows: rows),
          );
          placed = true;
          break;
        }
      }
      row++;
      if (row > 500) {
        // Safety valve; should never happen with sane input.
        break;
      }
    }
  }

  return packed;
}

/// Total number of grid rows spanned across all packed tiles (used to size
/// the scroll content height).
int packedGridRowCount(List<PackedTile> packed) {
  var maxRow = 0;
  for (final tile in packed) {
    final bottom = tile.row + tile.rows;
    if (bottom > maxRow) maxRow = bottom;
  }
  return maxRow;
}

TileSpan effectiveSpan(HomeItem item) => item.span;
