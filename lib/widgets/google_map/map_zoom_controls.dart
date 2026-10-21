import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/utils/app_ui.dart';

/// Floating zoom in / zoom out controls for Google Maps screens.
class MapZoomControls extends StatelessWidget {
  const MapZoomControls({
    super.key,
    this.controller,
    this.mapController,
    this.top,
    this.bottom = 24,
    this.right = 12,
    this.minZoom = 3,
    this.maxZoom = 20,
  }) : assert(controller != null || mapController != null);

  final Completer<GoogleMapController>? controller;
  final GoogleMapController? mapController;
  final double? top;
  final double? bottom;
  final double right;
  final double minZoom;
  final double maxZoom;

  Future<GoogleMapController?> _resolveController() async {
    if (mapController != null) return mapController;
    final completer = controller;
    if (completer == null || !completer.isCompleted) return null;
    return completer.future;
  }

  Future<void> _zoom({required bool zoomIn}) async {
    try {
      final map = await _resolveController();
      if (map == null) return;
      final currentZoom = await map.getZoomLevel();
      final nextZoom = (zoomIn ? currentZoom + 1 : currentZoom - 1)
          .clamp(minZoom, maxZoom)
          .toDouble();
      if ((nextZoom - currentZoom).abs() < 0.01) return;
      await map.animateCamera(CameraUpdate.zoomTo(nextZoom));
    } catch (e) {
      debugPrint('MapZoomControls zoom failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: top == null ? bottom : null,
      right: right,
      child: Material(
        color: AppUi.cardColor(context),
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppUi.line(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ZoomButton(
                icon: Icons.add_rounded,
                onTap: () => _zoom(zoomIn: true),
              ),
              Divider(height: 1, color: AppUi.line(context)),
              _ZoomButton(
                icon: Icons.remove_rounded,
                onTap: () => _zoom(zoomIn: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppUi.ink(context), size: 22),
        ),
      ),
    );
  }
}
