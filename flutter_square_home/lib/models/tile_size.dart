/// Mirrors the original app's `TileSize` union: "small" | "wide" | "large" |
/// "tall" | "xlarge" | "custom".
enum TileSize { small, wide, large, tall, xlarge, custom }

/// Grid span, expressed in base grid units (same concept as the RN
/// `TileSpan` type). Only meaningful on its own for `custom` tiles; for the
/// fixed sizes, use [spanForSize].
class TileSpan {
  final int cols;
  final int rows;

  const TileSpan(this.cols, this.rows);

  Map<String, dynamic> toJson() => {"cols": cols, "rows": rows};

  factory TileSpan.fromJson(Map<String, dynamic> json) =>
      TileSpan(json["cols"] as int, json["rows"] as int);

  @override
  bool operator ==(Object other) =>
      other is TileSpan && other.cols == cols && other.rows == rows;

  @override
  int get hashCode => Object.hash(cols, rows);
}

/// Base-unit spans for each fixed tile size, matching the RN app's packing
/// rules (small=1x1, wide=2x1, large=2x2, tall=1x2, xlarge=4x2).
TileSpan spanForSize(TileSize size, {TileSpan? customSpan}) {
  switch (size) {
    case TileSize.small:
      return const TileSpan(1, 1);
    case TileSize.wide:
      return const TileSpan(2, 1);
    case TileSize.large:
      return const TileSpan(2, 2);
    case TileSize.tall:
      return const TileSpan(1, 2);
    case TileSize.xlarge:
      return const TileSpan(4, 2);
    case TileSize.custom:
      return customSpan ?? const TileSpan(1, 1);
  }
}

String tileSizeToJson(TileSize size) => size.name;

TileSize tileSizeFromJson(String? value) => TileSize.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TileSize.small,
    );
