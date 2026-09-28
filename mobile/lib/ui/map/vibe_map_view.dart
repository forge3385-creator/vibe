import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../services/sound_manager.dart';

class VibeMapView extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final double radiusKm;
  final bool interactive;
  final String? centerLabel;
  final List<Map<String, dynamic>>? markers;
  final ValueChanged<double>? onRadiusChanged;

  const VibeMapView({
    super.key,
    this.initialLat = 37.7749, // San Francisco default
    this.initialLng = -122.4194,
    this.radiusKm = 5.0,
    this.interactive = true,
    this.centerLabel = 'You are here',
    this.markers,
    this.onRadiusChanged,
  });

  @override
  State<VibeMapView> createState() => _VibeMapViewState();
}

class _VibeMapViewState extends State<VibeMapView> {
  late double _lat;
  late double _lng;
  int _zoom = 13;
  Offset _panOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
  }

  math.Point<double> _latLngToTileFraction(double lat, double lng, int zoom) {
    final n = math.pow(2.0, zoom);
    final x = (lng + 180.0) / 360.0 * n;
    final latRad = lat * math.pi / 180.0;
    final y = (1.0 - (math.log(math.tan(latRad) + (1.0 / math.cos(latRad))) / math.pi)) / 2.0 * n;
    return math.Point(x, y);
  }

  void _zoomIn() {
    if (_zoom < 16) {
      SoundManager().playTap();
      setState(() => _zoom++);
    }
  }

  void _zoomOut() {
    if (_zoom > 10) {
      SoundManager().playTap();
      setState(() => _zoom--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final centerTile = _latLngToTileFraction(_lat, _lng, _zoom);
        const tileSize = 256.0;

        final centerPixelX = centerTile.x * tileSize + _panOffset.dx;
        final centerPixelY = centerTile.y * tileSize + _panOffset.dy;

        final minTileX = ((centerPixelX - width / 2) / tileSize).floor();
        final maxTileX = ((centerPixelX + width / 2) / tileSize).floor();
        final minTileY = ((centerPixelY - height / 2) / tileSize).floor();
        final maxTileY = ((centerPixelY + height / 2) / tileSize).floor();

        final maxTiles = math.pow(2, _zoom).toInt();

        return ClipRRect(
          borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
          child: Container(
            color: const Color(0xFF10101A),
            child: GestureDetector(
              onPanUpdate: widget.interactive
                  ? (details) {
                      setState(() {
                        _panOffset += details.delta;
                      });
                    }
                  : null,
              child: Stack(
                children: [
                  // Real Map Tiles (CartoDB Dark Matter / OSM)
                  for (int tx = minTileX; tx <= maxTileX; tx++)
                    for (int ty = minTileY; ty <= maxTileY; ty++)
                      if (ty >= 0 && ty < maxTiles)
                        Positioned(
                          left: (tx * tileSize) - (centerPixelX - width / 2),
                          top: (ty * tileSize) - (centerPixelY - height / 2),
                          width: tileSize,
                          height: tileSize,
                          child: Image.network(
                            'https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/$_zoom/${((tx % maxTiles) + maxTiles) % maxTiles}/$ty.png',
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) {
                              return Container(
                                color: const Color(0xFF141424),
                                child: const Center(
                                  child: Icon(Icons.map_outlined, color: Color(0x33FFFFFF), size: 24),
                                ),
                              );
                            },
                          ),
                        ),

                  // Ambient Vignette & Radial Depth Tint
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.1,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF07070D).withAlpha(120),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Radius Search Circle Overlay
                  Center(
                    child: Container(
                      width: widget.radiusKm * 28.0,
                      height: widget.radiusKm * 28.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VibeTokens.glowPurple.withAlpha(25),
                        border: Border.all(
                          color: VibeTokens.glowPurple.withAlpha(120),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: VibeTokens.glowPurple.withAlpha(40),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center Pin (User Location)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xCC0D0B18),
                            borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                            border: Border.all(color: const Color(0x66A78BFA)),
                            boxShadow: const [
                              BoxShadow(color: Colors.black45, blurRadius: 8),
                            ],
                          ),
                          child: Text(
                            widget.centerLabel ?? 'You',
                            style: VibeTokens.labelSm.copyWith(
                              color: VibeTokens.brandPurple200,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: VibeTokens.glowPurple.withAlpha(50),
                              ),
                            ),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: VibeTokens.glowPurple,
                                boxShadow: [
                                  BoxShadow(
                                    color: VibeTokens.glowPurple,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Additional Nearby Candidate Markers
                  if (widget.markers != null)
                    for (final m in widget.markers!)
                      _buildCandidateMarker(m, width, height),

                  // Map Controls (Zoom + Recenter)
                  if (widget.interactive)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildControlBtn(Icons.add, _zoomIn),
                          const SizedBox(height: 6),
                          _buildControlBtn(Icons.remove, _zoomOut),
                          const SizedBox(height: 6),
                          _buildControlBtn(Icons.my_location, () {
                            SoundManager().playTap();
                            setState(() => _panOffset = Offset.zero);
                          }),
                        ],
                      ),
                    ),

                  // Map Provider Attribution
                  Positioned(
                    left: 10,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xB307070D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '© OpenStreetMap · CartoDB',
                        style: VibeTokens.labelSm.copyWith(
                          fontSize: 9,
                          color: const Color(0x80FFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCandidateMarker(Map<String, dynamic> marker, double width, double height) {
    final double dx = (marker['dx'] as double? ?? 0.0) + (width / 2);
    final double dy = (marker['dy'] as double? ?? 0.0) + (height / 2);

    return Positioned(
      left: dx - 18,
      top: dy - 18,
      child: Tooltip(
        message: marker['name'] ?? 'Vibe peer',
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xE61E1638),
            border: Border.all(color: VibeTokens.glowCyan, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: VibeTokens.glowCyan.withAlpha(80),
                blurRadius: 10,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            marker['icon'] ?? '⚡',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xCC0D0B18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x33A78BFA)),
          ),
          child: Icon(icon, color: VibeTokens.darkTextPrimary, size: 16),
        ),
      ),
    );
  }
}
