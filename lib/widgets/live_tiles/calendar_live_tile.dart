import 'dart:async';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Four-corner layout matching the RN `CalendarLiveTile`: day number
/// top-left, weekday top-right, next real event's time bottom-left and
/// title bottom-right. Reads from the device's real calendar via
/// device_calendar (Android/iOS calendar provider), fetching events in the
/// next 30 days.
class CalendarLiveTile extends StatefulWidget {
  final double width;
  final double height;

  const CalendarLiveTile({super.key, required this.width, required this.height});

  @override
  State<CalendarLiveTile> createState() => _CalendarLiveTileState();
}

class _CalendarLiveTileState extends State<CalendarLiveTile> {
  Event? _nextEvent;
  bool _permissionDenied = false;
  final _plugin = DeviceCalendarPlugin();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      var permissionsGranted = await _plugin.hasPermissions();
      if (permissionsGranted.data != true) {
        final requestResult = await _plugin.requestPermissions();
        if (requestResult.data != true) {
          if (mounted) setState(() => _permissionDenied = true);
          return;
        }
      }

      final calendarsResult = await _plugin.retrieveCalendars();
      final calendars = calendarsResult.data ?? [];
      if (calendars.isEmpty) return;

      final now = DateTime.now();
      final end = now.add(const Duration(days: 30));
      final events = <Event>[];
      for (final calendar in calendars) {
        if (calendar.id == null) continue;
        final result = await _plugin.retrieveEvents(
          calendar.id,
          RetrieveEventsParams(startDate: now, endDate: end),
        );
        events.addAll(result.data ?? []);
      }
      events.sort((a, b) {
        final aStart = a.start ?? DateTime(9999);
        final bStart = b.start ?? DateTime(9999);
        return aStart.compareTo(bStart);
      });

      if (mounted) setState(() => _nextEvent = events.isNotEmpty ? events.first : null);
    } catch (_) {
      if (mounted) setState(() => _permissionDenied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayNumFontSize = (widget.height * 0.34).clamp(16.0, 40.0);
    final compact = widget.height < 90;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Text(
              "${now.day}",
              style: TextStyle(
                color: Colors.white,
                fontSize: dayNumFontSize,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Text(
              DateFormat("EEE").format(now),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          if (!compact && !_permissionDenied && _nextEvent != null) ...[
            Positioned(
              left: 0,
              bottom: 0,
              child: Text(
                _nextEvent!.start != null ? DateFormat("h:mm a").format(_nextEvent!.start!) : "",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.width * 0.55),
                child: Text(
                  _nextEvent!.title ?? "Event",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ] else if (!compact && _permissionDenied)
            const Positioned(
              left: 0,
              bottom: 0,
              child: Text(
                "No calendar access",
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
