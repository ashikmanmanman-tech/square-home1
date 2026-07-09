import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

enum _WeatherStatus { loading, deniedOrDisabled, error, ready }

class _WeatherSnapshot {
  final double tempC;
  final int weatherCode;
  final String place;

  _WeatherSnapshot({required this.tempC, required this.weatherCode, required this.place});
}

/// Real-time weather via the free, keyless open-meteo.com API, using the
/// device's real GPS location (expo-location equivalent: geolocator +
/// geocoding). No mocked temperature/condition data.
class WeatherLiveTile extends StatefulWidget {
  final double width;
  final double height;
  final bool useFahrenheit;

  const WeatherLiveTile({
    super.key,
    required this.width,
    required this.height,
    this.useFahrenheit = false,
  });

  @override
  State<WeatherLiveTile> createState() => _WeatherLiveTileState();
}

class _WeatherLiveTileState extends State<WeatherLiveTile> {
  _WeatherStatus _status = _WeatherStatus.loading;
  _WeatherSnapshot? _snapshot;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _status = _WeatherStatus.deniedOrDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _status = _WeatherStatus.deniedOrDisabled);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final uri = Uri.parse(
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=${position.latitude}&longitude=${position.longitude}"
        "&current=temperature_2m,weather_code",
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        if (mounted) setState(() => _status = _WeatherStatus.error);
        return;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final current = body["current"] as Map<String, dynamic>?;
      if (current == null) {
        if (mounted) setState(() => _status = _WeatherStatus.error);
        return;
      }

      String place = "Current location";
      try {
        final placemarks =
            await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          place = p.locality?.isNotEmpty == true
              ? p.locality!
              : (p.subAdministrativeArea ?? p.administrativeArea ?? place);
        }
      } catch (_) {
        // Reverse geocoding is best-effort; keep the fallback label.
      }

      if (mounted) {
        setState(() {
          _snapshot = _WeatherSnapshot(
            tempC: (current["temperature_2m"] as num).toDouble(),
            weatherCode: (current["weather_code"] as num).toInt(),
            place: place,
          );
          _status = _WeatherStatus.ready;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _status = _WeatherStatus.error);
    }
  }

  IconData _iconForCode(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code <= 3) return Icons.wb_cloudy_outlined;
    if (code >= 45 && code <= 48) return Icons.foggy;
    if (code >= 51 && code <= 67) return Icons.grain;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 80 && code <= 82) return Icons.grain;
    if (code >= 95) return Icons.thunderstorm_outlined;
    return Icons.wb_cloudy_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.height < 80;
    final iconSize = (widget.width < widget.height ? widget.width : widget.height) * 0.36;

    if (_status != _WeatherStatus.ready || _snapshot == null) {
      final message = switch (_status) {
        _WeatherStatus.deniedOrDisabled => "No location access",
        _WeatherStatus.error => "Weather unavailable",
        _ => null,
      };
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_cloudy_outlined, size: iconSize, color: Colors.white70),
            if (message != null && !compact)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
          ],
        ),
      );
    }

    final snapshot = _snapshot!;
    final displayTemp = widget.useFahrenheit
        ? (snapshot.tempC * 9 / 5 + 32).round()
        : snapshot.tempC.round();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(_iconForCode(snapshot.weatherCode), size: iconSize, color: Colors.white),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$displayTemp°${widget.useFahrenheit ? "F" : "C"}",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
              ),
              if (!compact)
                Text(
                  snapshot.place,
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
