// import 'dart:async';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// class MapPage extends StatefulWidget {
//   final double destLat;
//   final double destLng;

//   const MapPage({
//     super.key,
//     required this.destLat,
//     required this.destLng,
//   });

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   final Completer<GoogleMapController> _mapController =
//       Completer<GoogleMapController>();

//   final Location _locationController = Location();

//   LatLng? _currentPosition;
//   late LatLng _destination;

//   Map<PolylineId, Polyline> polylines = {};

//   @override
//   void initState() {
//     super.initState();
//     _destination = LatLng(widget.destLat, widget.destLng);

//     getLocationUpdates().then(
//       (_) => {
//         getPolylinePoints().then(
//           (coordinates) => generatePolylineFromPoints(coordinates),
//         ),
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Map Navigation"),
//         backgroundColor: const Color(0xFF126E06),
//       ),
//       body: _currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               onMapCreated: (GoogleMapController controller) =>
//                   _mapController.complete(controller),
//               initialCameraPosition: CameraPosition(
//                 target: _destination,
//                 zoom: 13,
//               ),
//               markers: {
//                 if (_currentPosition != null)
//                   Marker(
//                     markerId: const MarkerId("current"),
//                     position: _currentPosition!,
//                     infoWindow: const InfoWindow(title: "You are here"),
//                     icon: BitmapDescriptor.defaultMarkerWithHue(
//                         BitmapDescriptor.hueBlue),
//                   ),
//                 Marker(
//                   markerId: const MarkerId("destination"),
//                   position: _destination,
//                   infoWindow: const InfoWindow(title: "Destination"),
//                 ),
//               },
//               polylines: Set<Polyline>.of(polylines.values),
//               myLocationEnabled: true,
//               myLocationButtonEnabled: false,
//             ),
//       floatingActionButton: _currentPosition == null
//           ? null
//           : FloatingActionButton(
//               backgroundColor: const Color(0xFF126E06),
//               child: const Icon(Icons.my_location),
//               onPressed: () {
//                 _cameraToPosition(_currentPosition!);
//               },
//             ),
//     );
//   }

//   Future<void> _cameraToPosition(LatLng pos) async {
//     final GoogleMapController controller = await _mapController.future;
//     CameraPosition newCameraPosition = CameraPosition(target: pos, zoom: 14);
//     await controller.animateCamera(
//       CameraUpdate.newCameraPosition(newCameraPosition),
//     );
//   }

//   Future<void> getLocationUpdates() async {
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     serviceEnabled = await _locationController.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _locationController.requestService();
//       if (!serviceEnabled) return;
//     }

//     permissionGranted = await _locationController.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await _locationController.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) return;
//     }

//     _locationController.onLocationChanged
//         .listen((LocationData currentLocation) {
//       if (currentLocation.latitude != null &&
//           currentLocation.longitude != null) {
//         setState(() {
//           _currentPosition = LatLng(
//             currentLocation.latitude!,
//             currentLocation.longitude!,
//           );
//         });
//       }
//     });
//   }

//   Future<List<LatLng>> getPolylinePoints() async {
//     if (_currentPosition == null) return [];

//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints(apiKey: "YOUR_API_KEY_HERE");

//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       request: PolylineRequest(
//         origin: PointLatLng(
//             _currentPosition!.latitude, _currentPosition!.longitude),
//         destination: PointLatLng(_destination.latitude, _destination.longitude),
//         mode: TravelMode.driving,
//       ),
//     );

//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//     } else {
//       print("Error fetching polyline: ${result.errorMessage}");
//     }

//     return polylineCoordinates;
//   }

//   void generatePolylineFromPoints(List<LatLng> polylineCoordinates) {
//     PolylineId id = const PolylineId("route");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.blue,
//       points: polylineCoordinates,
//       width: 6,
//     );

//     setState(() {
//       polylines[id] = polyline;
//     });
//   }
// }
