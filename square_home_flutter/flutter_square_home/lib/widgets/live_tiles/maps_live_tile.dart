import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum _MapsStatus { loading, servicesDisabled, denied, error, ready }

class _LocationSnapshot {
  final String place;
  final String region;
  final double latitude;
  final double longitude;

  _LocationSnapshot({
    required this.place,
    required this.region,
    required this.latitude,
    required this.longitude,
  });
}

/// Windows-Phone "Maps" style live tile: shows the device's real current
/// location (city/region + coordinates), refreshed periodically via
/// geolocator/geocoding — no embedded interactive map, matching the
/// original app's lightweight "you are here" glance tile.
class MapsLiveTile extends StatefulWidget {
  final double width;
  final double height;

  const MapsLiveTile({super.key, required this.width, required this.height});

  @override
  State<MapsLiveTile> createState() => _MapsLiveTileState();
}

class _MapsLiveTileState extends State<MapsLiveTile> {
  _MapsStatus _status = _MapsStatus.loading;
  _LocationSnapshot? _location;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => _load());
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
        if (mounted) setState(() => _status = _MapsStatus.servicesDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _status = _MapsStatus.denied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      var place = "Current location";
      var region = "";
      try {
        final placemarks =
            await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          place = p.locality?.isNotEmpty == true
              ? p.locality!
              : (p.subAdministrativeArea ?? p.name ?? place);
          region = p.administrativeArea?.isNotEmpty == true
              ? p.administrativeArea!
              : (p.country ?? "");
        }
      } catch (_) {
        // Reverse geocoding is best-effort; keep coordinate-only fallback.
      }

      if (mounted) {
        setState(() {
          _location = _LocationSnapshot(
            place: place,
            region: region,
            latitude: position.latitude,
            longitude: position.longitude,
          );
          _status = _MapsStatus.ready;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _status = _MapsStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minDim = widget.width < widget.height ? widget.width : widget.height;
    final iconSize = minDim * 0.34;
    final compact = widget.height < 80;

    if (_status != _MapsStatus.ready || _location == null) {
      final message = switch (_status) {
        _MapsStatus.servicesDisabled => "Location off",
        _MapsStatus.denied => "No location access",
        _MapsStatus.error => "Location unavailable",
        _ => null,
      };
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _status == _MapsStatus.servicesDisabled || _status == _MapsStatus.denied
                  ? Icons.location_off_outlined
                  : Icons.location_on_outlined,
              size: iconSize,
              color: Colors.white70,
            ),
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

    final location = _location!;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.location_on, size: iconSize, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            location.place,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
          ),
          if (location.region.isNotEmpty && !compact)
            Text(
              location.region,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          if (!compact)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                "${location.latitude.toStringAsFixed(3)}, ${location.longitude.toStringAsFixed(3)}",
                style: const TextStyle(color: Colors.white54, fontSize: 9),
              ),
            ),
        ],
      ),
    );
  }
}
