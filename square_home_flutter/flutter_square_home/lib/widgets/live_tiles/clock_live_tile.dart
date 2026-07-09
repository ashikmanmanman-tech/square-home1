import 'dart:async';

import 'package:flutter/material.dart';

/// Digital clock live tile: local time plus two extra world zones (Canada
/// and India), matching the RN `ClockLiveTile` stacked-rows layout. Uses the
/// device's real system clock — no mocked time.
class ClockLiveTile extends StatefulWidget {
  final double width;
  final double height;
  final bool use24Hour;

  const ClockLiveTile({
    super.key,
    required this.width,
    required this.height,
    this.use24Hour = false,
  });

  @override
  State<ClockLiveTile> createState() => _ClockLiveTileState();
}

class _ClockLiveTileState extends State<ClockLiveTile> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatIn(String timeZoneLabel, Duration offsetFromUtc) {
    final utc = _now.toUtc();
    final shifted = utc.add(offsetFromUtc);
    final hour24 = shifted.hour;
    final minute = shifted.minute.toString().padLeft(2, "0");
    final second = shifted.second.toString().padLeft(2, "0");
    if (widget.use24Hour) {
      return "${hour24.toString().padLeft(2, "0")}:$minute:$second";
    }
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final period = hour24 >= 12 ? "pm" : "am";
    return "$hour12:$minute:$second $period";
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.height < 90;
    final localHour24 = _now.hour;
    final localMinute = _now.minute.toString().padLeft(2, "0");
    final localSecond = _now.second.toString().padLeft(2, "0");
    final String localTime;
    if (widget.use24Hour) {
      localTime = "${localHour24.toString().padLeft(2, "0")}:$localMinute:$localSecond";
    } else {
      final localHour12 = localHour24 % 12 == 0 ? 12 : localHour24 % 12;
      final localPeriod = localHour24 >= 12 ? "pm" : "am";
      localTime = "$localHour12:$localMinute:$localSecond $localPeriod";
    }

    final rows = <Widget>[
      _row("Local", localTime, primary: true),
    ];
    if (!compact) {
      // Canada (Eastern, UTC-4 DST-agnostic approximation) and India
      // (UTC+5:30) — fixed offsets since Flutter has no bundled IANA tz
      // database without an extra dependency (documented constraint).
      rows.add(_row("Canada", _formatIn("Canada", const Duration(hours: -4))));
      rows.add(_row("India", _formatIn("India", const Duration(hours: 5, minutes: 30))));
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _row(String label, String time, {bool primary = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontWeight: primary ? FontWeight.w600 : FontWeight.w400,
              fontSize: primary ? 20 : 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
