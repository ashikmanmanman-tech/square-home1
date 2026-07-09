import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A curated catalog of generic app entries used to populate the app
/// drawer, mirroring the original `APP_CATALOG`. Names are intentionally
/// generic except for the "brand" entries, which use real social-platform
/// logos via font_awesome_flutter.
class CatalogApp {
  final String id;
  final String name;
  final IconData icon;
  final bool isBrand;
  final Color color;

  const CatalogApp({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isBrand = false,
  });
}

/// NOTE (rewrite constraint): Flutter's bundled Material icon font does not
/// have a 1:1 glyph for every original Expo icon. A few brand logos also
/// aren't in font_awesome_flutter's free tier (LINE, WeChat). Those use the
/// closest reasonable Material substitute instead of a fake/mocked icon.
final List<CatalogApp> appCatalog = [
  const CatalogApp(id: "phone", name: "Phone", icon: Icons.call, color: Color(0xFF34C759)),
  const CatalogApp(id: "messages", name: "Messages", icon: Icons.message, color: Color(0xFF30D158)),
  const CatalogApp(id: "mail", name: "Mail", icon: Icons.email_outlined, color: Color(0xFF3B82F6)),
  const CatalogApp(id: "browser", name: "Browser", icon: Icons.explore_outlined, color: Color(0xFF2F95DC)),
  const CatalogApp(id: "camera", name: "Camera", icon: Icons.camera_alt_outlined, color: Color(0xFF71717A)),
  const CatalogApp(id: "gallery", name: "Gallery", icon: Icons.photo_library_outlined, color: Color(0xFFF472B6)),
  const CatalogApp(id: "calendar", name: "Calendar", icon: Icons.calendar_month, color: Color(0xFFEF4444)),
  const CatalogApp(id: "clock", name: "Clock", icon: Icons.access_time, color: Color(0xFF1A1A1A)),
  const CatalogApp(id: "weather", name: "Weather", icon: Icons.wb_cloudy_outlined, color: Color(0xFF0EA5E9)),
  const CatalogApp(id: "notes", name: "Notes", icon: Icons.description_outlined, color: Color(0xFFEAB308)),
  const CatalogApp(id: "files", name: "Files", icon: Icons.folder_outlined, color: Color(0xFF3B82F6)),
  const CatalogApp(id: "calculator", name: "Calculator", icon: Icons.calculate_outlined, color: Color(0xFF52525B)),
  const CatalogApp(id: "music", name: "Music", icon: Icons.music_note, color: Color(0xFFFB7185)),
  const CatalogApp(id: "video", name: "Video", icon: Icons.videocam_outlined, color: Color(0xFFA855F7)),
  const CatalogApp(id: "maps", name: "Maps", icon: Icons.location_on, color: Color(0xFF22C55E)),
  const CatalogApp(id: "contacts", name: "Contacts", icon: Icons.people_alt, color: Color(0xFFF97316)),
  const CatalogApp(id: "settings", name: "Settings", icon: Icons.settings_outlined, color: Color(0xFF64748B)),
  const CatalogApp(id: "store", name: "Store", icon: Icons.storefront_outlined, color: Color(0xFF06B6D4)),
  const CatalogApp(id: "news", name: "News", icon: Icons.article_outlined, color: Color(0xFFDC2626)),
  const CatalogApp(id: "health", name: "Health", icon: Icons.favorite_outline, color: Color(0xFFF43F5E)),
  const CatalogApp(id: "wallet", name: "Wallet", icon: Icons.account_balance_wallet_outlined, color: Color(0xFF16A34A)),
  const CatalogApp(id: "cloud", name: "Cloud", icon: Icons.cloud_outlined, color: Color(0xFF0284C7)),
  const CatalogApp(id: "chat", name: "Chat", icon: Icons.chat_bubble_outline, color: Color(0xFF8B5CF6)),
  const CatalogApp(id: "games", name: "Games", icon: Icons.sports_esports_outlined, color: Color(0xFFE11D48)),
  const CatalogApp(id: "podcasts", name: "Podcasts", icon: Icons.podcasts, color: Color(0xFF9333EA)),
  const CatalogApp(id: "books", name: "Books", icon: Icons.menu_book_outlined, color: Color(0xFFB45309)),
  const CatalogApp(id: "recorder", name: "Recorder", icon: Icons.mic_none, color: Color(0xFFDC2626)),
  const CatalogApp(id: "flashlight", name: "Flashlight", icon: Icons.flashlight_on_outlined, color: Color(0xFFFACC15)),
  const CatalogApp(id: "timer", name: "Timer", icon: Icons.timer_outlined, color: Color(0xFFF59E0B)),
  const CatalogApp(id: "translate", name: "Translate", icon: Icons.translate, color: Color(0xFF0EA5E9)),
  const CatalogApp(id: "scanner", name: "Scanner", icon: Icons.document_scanner_outlined, color: Color(0xFF475569)),
  const CatalogApp(id: "fitness", name: "Fitness", icon: Icons.directions_run, color: Color(0xFF22C55E)),
  const CatalogApp(id: "recipes", name: "Recipes", icon: Icons.restaurant_menu, color: Color(0xFFD97706)),
  const CatalogApp(id: "todo", name: "To-Do", icon: Icons.checklist, color: Color(0xFF4F46E5)),
  const CatalogApp(id: "vault", name: "Vault", icon: Icons.lock_outline, color: Color(0xFF334155)),
  const CatalogApp(id: "player", name: "Player", icon: Icons.play_circle_outline, color: Color(0xFFEF4444)),
  const CatalogApp(id: "wifi", name: "Network", icon: Icons.wifi, color: Color(0xFF0891B2)),
  const CatalogApp(id: "battery", name: "Battery", icon: Icons.battery_full, color: Color(0xFF65A30D)),
  const CatalogApp(id: "backup", name: "Backup", icon: Icons.backup_outlined, color: Color(0xFF525252)),
  const CatalogApp(id: "search", name: "Search", icon: Icons.search, color: Color(0xFF737373)),
  const CatalogApp(id: "theme", name: "Themes", icon: Icons.palette_outlined, color: Color(0xFFDB2777)),

  // Real social/brand logos via FontAwesome.
  const CatalogApp(id: "facebook", name: "Facebook", icon: FontAwesomeIcons.facebookF, color: Color(0xFF1877F2), isBrand: true),
  const CatalogApp(id: "messenger", name: "Messenger", icon: FontAwesomeIcons.facebookMessenger, color: Color(0xFF00B2FF), isBrand: true),
  const CatalogApp(id: "instagram", name: "Instagram", icon: FontAwesomeIcons.instagram, color: Color(0xFFC13584), isBrand: true),
  const CatalogApp(id: "whatsapp", name: "WhatsApp", icon: FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), isBrand: true),
  const CatalogApp(id: "twitter", name: "Twitter", icon: FontAwesomeIcons.twitter, color: Color(0xFF1DA1F2), isBrand: true),
  const CatalogApp(id: "pinterest", name: "Pinterest", icon: FontAwesomeIcons.pinterest, color: Color(0xFFE60023), isBrand: true),
  const CatalogApp(id: "tiktok", name: "TikTok", icon: FontAwesomeIcons.tiktok, color: Color(0xFF1A1A1A), isBrand: true),
  const CatalogApp(id: "youtube", name: "YouTube", icon: FontAwesomeIcons.youtube, color: Color(0xFFFF0000), isBrand: true),
  const CatalogApp(id: "linkedin", name: "LinkedIn", icon: FontAwesomeIcons.linkedinIn, color: Color(0xFF0A66C2), isBrand: true),
  // Tinder logo isn't in font_awesome_flutter's free set — substituting a
  // flame glyph (documented gap, not a fake brand icon).
  const CatalogApp(id: "tinder", name: "Tinder", icon: Icons.local_fire_department, color: Color(0xFFFD5068)),
  const CatalogApp(id: "spotify", name: "Spotify", icon: FontAwesomeIcons.spotify, color: Color(0xFF1DB954), isBrand: true),
  const CatalogApp(id: "vimeo", name: "Vimeo", icon: FontAwesomeIcons.vimeoV, color: Color(0xFF1AB7EA), isBrand: true),
  const CatalogApp(id: "snapchat", name: "Snapchat", icon: FontAwesomeIcons.snapchat, color: Color(0xFFFFFC00), isBrand: true),
  const CatalogApp(id: "tumblr", name: "Tumblr", icon: FontAwesomeIcons.tumblr, color: Color(0xFF35465C), isBrand: true),
  // LINE has no free FontAwesome brand glyph — substituting a chat bubble
  // (documented gap).
  const CatalogApp(id: "line", name: "LINE", icon: Icons.chat_bubble, color: Color(0xFF00B900)),
  // WeChat likewise has no bundled Material/FontAwesome-free glyph.
  const CatalogApp(id: "wechat", name: "WeChat", icon: Icons.chat_bubble_outline, color: Color(0xFF07C160)),
  const CatalogApp(id: "twitch", name: "Twitch", icon: FontAwesomeIcons.twitch, color: Color(0xFF9146FF), isBrand: true),
  const CatalogApp(id: "skype", name: "Skype", icon: FontAwesomeIcons.skype, color: Color(0xFF00AFF0), isBrand: true),
  const CatalogApp(id: "reddit", name: "Reddit", icon: FontAwesomeIcons.redditAlien, color: Color(0xFFFF4500), isBrand: true),
  const CatalogApp(id: "dribbble", name: "Dribbble", icon: FontAwesomeIcons.dribbble, color: Color(0xFFEA4C89), isBrand: true),
  const CatalogApp(id: "flickr", name: "Flickr", icon: FontAwesomeIcons.flickr, color: Color(0xFFFF0084), isBrand: true),
  const CatalogApp(id: "telegram", name: "Telegram", icon: FontAwesomeIcons.telegram, color: Color(0xFF229ED9), isBrand: true),
  const CatalogApp(id: "soundcloud", name: "SoundCloud", icon: FontAwesomeIcons.soundcloud, color: Color(0xFFFF5500), isBrand: true),
  const CatalogApp(id: "behance", name: "Behance", icon: FontAwesomeIcons.behance, color: Color(0xFF1769FF), isBrand: true),
];

CatalogApp? findCatalogApp(String id) {
  for (final app in appCatalog) {
    if (app.id == id) return app;
  }
  return null;
}
