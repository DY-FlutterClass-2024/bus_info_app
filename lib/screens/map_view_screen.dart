import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:bus_info_app_2/utils/google_maps_style.dart';

class MapViewScreen extends StatefulWidget {
  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  late GoogleMapController mapController;
  LocationData? currentLocation;
  final Location location = Location();

  final LatLng _defaultLocation = const LatLng(37.241369, 127.215994); // 기본 위치

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentLocation = await location.getLocation();
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(darkMapStyle); // Use the imported map style
    if (currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도 화면'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: currentLocation != null
              ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
              : _defaultLocation,
          zoom: 11.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}