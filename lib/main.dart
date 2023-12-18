import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  _myMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Marker markerBogota = Marker(
    markerId: const MarkerId('Bogota'),
    position: const LatLng(4.60971, -74.08175),
    infoWindow: const InfoWindow(title: 'Bogota'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    draggable: true,
    onDragEnd: (latlng) {
      print(latlng);
    },
    onTap: () {
      print('Click a Bogota');
    },
  );

  Marker markerEcuador = const Marker(
    markerId: MarkerId('Ecuador'),
    position: LatLng(-1.831239, -78.183406),
  );

  gotoEcuador() {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(-1.831239, -78.183406),
          zoom: 13,
        ),
      ),
    );
  }

  gotoCurrentLocation() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      // TODO: Logica para cuando el usuario rechaza los permisos
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 11,
    );

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  Future<bool> _handlePermission() async {
    bool serviceEnable;
    LocationPermission permission;

    serviceEnable = await _geolocatorPlatform.isLocationServiceEnabled();

    if (!serviceEnable) {
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();

      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google maps'),
        ),
        body: GoogleMap(
          onMapCreated: _myMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(4.60971, -74.08175),
            zoom: 13,
          ),
          mapType: MapType.normal,
          markers: {markerBogota, markerEcuador},
          polylines: {
            const Polyline(
              polylineId: PolylineId('Ruta 1'),
              points: [
                LatLng(4.60971, -74.08175),
                LatLng(-1.831239, -78.183406)
              ],
              width: 3,
              color: Colors.pink,
            ),
          },
          circles: {
            const Circle(
              circleId: CircleId('Geo 1'),
              center: LatLng(-1.831239, -78.183406),
              radius: 100,
              strokeColor: Colors.red,
              strokeWidth: 3,
              fillColor: Colors.yellow,
            ),
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // gotoEcuador();
            gotoCurrentLocation();
          },
          // label: const Text('Ecuador'),
          label: const Text('Actual'),
          icon: const Icon(Icons.home),
        ),
      ),
    );
  }
}
