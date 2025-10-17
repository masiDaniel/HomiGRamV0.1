import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  final double? destLat;
  final double? destLng;
  final String? houseName;

  const MapPage({
    super.key,
    required this.destLat,
    required this.destLng,
    this.houseName,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final Location _locationController = Location();

  LatLng? _currentPosition;
  LatLng? _destination;

  @override
  void initState() {
    super.initState();
    if (widget.destLat != null && widget.destLng != null) {
      _destination = LatLng(widget.destLat!, widget.destLng!);
      getLocationUpdates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Map View"),
        elevation: 0,
      ),
      body: widget.destLat == null || widget.destLng == null
          ? _noDataView(context)
          : Stack(
              children: [
                _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        onMapCreated: (GoogleMapController controller) =>
                            _mapController.complete(controller),
                        initialCameraPosition: CameraPosition(
                          target: _destination!,
                          zoom: 13,
                        ),
                        zoomControlsEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId("destination"),
                            position: _destination!,
                            infoWindow: const InfoWindow(title: "Destination"),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                          ),
                          if (_currentPosition != null)
                            Marker(
                              markerId: const MarkerId("current"),
                              position: _currentPosition!,
                              infoWindow:
                                  const InfoWindow(title: "You are here"),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueAzure),
                            ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      ),

                // 🧭 Custom floating panel
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _floatingPanel(context, isDark),
                ),
              ],
            ),
    );
  }

  Widget _noDataView(BuildContext context) {
    return const Center(
      child: Text(
        "No location data available.",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _floatingPanel(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.9) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF126E06), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.houseName!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF126E06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.directions, color: Colors.white),
            label: const Text("Open Maps",
                style: TextStyle(color: Colors.white, fontSize: 15)),
            onPressed: _openGoogleMaps,
          ),
        ],
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted =
        await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) async {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
    });
  }

  Future<void> _openGoogleMaps() async {
    if (_destination == null) return;

    final double destLat = _destination!.latitude;
    final double destLng = _destination!.longitude;

    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps.")),
      );
    }
  }
}
