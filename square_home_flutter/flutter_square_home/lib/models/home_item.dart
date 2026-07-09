import 'tile_size.dart';

/// Base type for anything that can occupy a slot on the Start screen grid.
/// Mirrors the RN `HomeItem` union (`HomeApp | HomeFolder`).
abstract class HomeItem {
  final String kind;
  final String uid;
  final TileSize size;
  final TileSpan? customSpan;
  final String? color;
  final bool transparent;
  final bool hidden;

  const HomeItem({
    required this.kind,
    required this.uid,
    required this.size,
    this.customSpan,
    this.color,
    this.transparent = false,
    this.hidden = false,
  });

  TileSpan get span => spanForSize(size, customSpan: customSpan);

  Map<String, dynamic> toJson();

  HomeItem withSize(TileSize size);
  HomeItem withCustomSpan(TileSpan span);
  HomeItem withColor(String? color);
  HomeItem withTransparent(bool transparent);
  HomeItem withHidden(bool hidden);

  static HomeItem fromJson(Map<String, dynamic> json) {
    if (json["kind"] == "folder") return HomeFolder.fromJson(json);
    return HomeApp.fromJson(json);
  }
}

class HomeApp extends HomeItem {
  final String appId;

  const HomeApp({
    required super.uid,
    required this.appId,
    required super.size,
    super.customSpan,
    super.color,
    super.transparent,
    super.hidden,
  }) : super(kind: "app");

  HomeApp copyWith({
    TileSize? size,
    TileSpan? customSpan,
    String? color,
    bool clearColor = false,
    bool? transparent,
    bool? hidden,
  }) {
    return HomeApp(
      uid: uid,
      appId: appId,
      size: size ?? this.size,
      customSpan: customSpan ?? this.customSpan,
      color: clearColor ? null : (color ?? this.color),
      transparent: transparent ?? this.transparent,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  HomeItem withSize(TileSize size) => copyWith(size: size);

  @override
  HomeItem withCustomSpan(TileSpan span) =>
      copyWith(size: TileSize.custom, customSpan: span);

  @override
  HomeItem withColor(String? color) =>
      color == null ? copyWith(clearColor: true) : copyWith(color: color);

  @override
  HomeItem withTransparent(bool transparent) => copyWith(transparent: transparent);

  @override
  HomeItem withHidden(bool hidden) => copyWith(hidden: hidden);

  @override
  Map<String, dynamic> toJson() => {
        "kind": "app",
        "uid": uid,
        "appId": appId,
        "size": tileSizeToJson(size),
        if (customSpan != null) "customSpan": customSpan!.toJson(),
        if (color != null) "color": color,
        if (transparent) "transparent": transparent,
        if (hidden) "hidden": hidden,
      };

  factory HomeApp.fromJson(Map<String, dynamic> json) => HomeApp(
        uid: json["uid"] as String,
        appId: json["appId"] as String,
        size: tileSizeFromJson(json["size"] as String?),
        customSpan: json["customSpan"] != null
            ? TileSpan.fromJson(json["customSpan"] as Map<String, dynamic>)
            : null,
        color: json["color"] as String?,
        transparent: (json["transparent"] as bool?) ?? false,
        hidden: (json["hidden"] as bool?) ?? false,
      );
}

class HomeFolder extends HomeItem {
  final String name;
  final List<String> appIds;

  const HomeFolder({
    required super.uid,
    required this.name,
    required this.appIds,
    required super.size,
    super.customSpan,
    super.color,
    super.transparent,
    super.hidden,
  }) : super(kind: "folder");

  HomeFolder copyWith({
    String? name,
    List<String>? appIds,
    TileSize? size,
    TileSpan? customSpan,
    String? color,
    bool clearColor = false,
    bool? transparent,
    bool? hidden,
  }) {
    return HomeFolder(
      uid: uid,
      name: name ?? this.name,
      appIds: appIds ?? this.appIds,
      size: size ?? this.size,
      customSpan: customSpan ?? this.customSpan,
      color: clearColor ? null : (color ?? this.color),
      transparent: transparent ?? this.transparent,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  HomeItem withSize(TileSize size) => copyWith(size: size);

  @override
  HomeItem withCustomSpan(TileSpan span) =>
      copyWith(size: TileSize.custom, customSpan: span);

  @override
  HomeItem withColor(String? color) =>
      color == null ? copyWith(clearColor: true) : copyWith(color: color);

  @override
  HomeItem withTransparent(bool transparent) => copyWith(transparent: transparent);

  @override
  HomeItem withHidden(bool hidden) => copyWith(hidden: hidden);

  @override
  Map<String, dynamic> toJson() => {
        "kind": "folder",
        "uid": uid,
        "name": name,
        "appIds": appIds,
        "size": tileSizeToJson(size),
        if (customSpan != null) "customSpan": customSpan!.toJson(),
        if (color != null) "color": color,
        if (transparent) "transparent": transparent,
        if (hidden) "hidden": hidden,
      };

  factory HomeFolder.fromJson(Map<String, dynamic> json) => HomeFolder(
        uid: json["uid"] as String,
        name: json["name"] as String,
        appIds:
            (json["appIds"] as List<dynamic>).map((e) => e as String).toList(),
        size: tileSizeFromJson(json["size"] as String?),
        customSpan: json["customSpan"] != null
            ? TileSpan.fromJson(json["customSpan"] as Map<String, dynamic>)
            : null,
        color: json["color"] as String?,
        transparent: (json["transparent"] as bool?) ?? false,
        hidden: (json["hidden"] as bool?) ?? false,
      );
}
