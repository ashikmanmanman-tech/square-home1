import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

/// Real device battery level + charging state via `battery_plus`. Polls the
/// level every 30s and listens to charging-state changes live — no mocked
/// percentage.
class BatteryLiveTile extends StatefulWidget {
  final double width;
  final double height;

  const BatteryLiveTile({super.key, required this.width, required this.height});

  @override
  State<BatteryLiveTile> createState() => _BatteryLiveTileState();
}

class _BatteryLiveTileState extends State<BatteryLiveTile> {
  final Battery _battery = Battery();
  int? _level;
  BatteryState _state = BatteryState.unknown;
  StreamSubscription<BatteryState>? _sub;
  Timer? _poll;
  bool _errored = false;

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => _load());
    _sub = _battery.onBatteryStateChanged.listen(
      (state) {
        if (mounted) setState(() => _state = state);
        _load();
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      if (mounted) {
        setState(() {
          _level = level;
          _state = state;
          _errored = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _errored = true);
    }
  }

  IconData _icon() {
    if (_state == BatteryState.charging) return Icons.battery_charging_full;
    final level = _level ?? 0;
    if (level >= 90) return Icons.battery_full;
    if (level >= 60) return Icons.battery_5_bar;
    if (level >= 40) return Icons.battery_3_bar;
    if (level >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.height < 80;
    final iconSize = (widget.width < widget.height ? widget.width : widget.height) * 0.4;

    if (_errored || _level == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.battery_unknown, size: iconSize, color: Colors.white70),
            if (!compact)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Battery unavailable",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
          ],
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(_icon(), size: iconSize, color: Colors.white),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$_level%",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
              ),
              if (!compact)
                Text(
                  _state == BatteryState.charging ? "Charging" : "On battery",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
