// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // final Completer<GoogleMapController> googleMapCompleterController =
  //     Completer<GoogleMapController>();
  // GoogleMapController? controllerGoogleMap;
  // Position? currentPositionOfUser;

  // @override
  // void initState() {
  //   super.initState();
  //   getCurrentLiveLocationOfUser();
  // }

  // void updateMapTheme(GoogleMapController controller) {
  //   getJsonFileFromThemes('themes/dark_style.json')
  //       .then((value) => setGoogleMapStyle(value, controller));
  // }

  // Future<String> getJsonFileFromThemes(String path) async {
  //   ByteData byteData = await rootBundle.load(path);
  //   var list = byteData.buffer.asUint8List(
  //       byteData.offsetInBytes, byteData.lengthInBytes);
  //   return utf8.decode(list);
  // }

  // void setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
  //   controller.setMapStyle(googleMapStyle);
  // }

  // getCurrentLiveLocationOfUser() async {
  //   Position positionOfUser = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.bestForNavigation);
  //   currentPositionOfUser = positionOfUser;

  //   LatLng positionOfUserInLatLng =
  //       LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
  //   CameraPosition cameraPosition =
  //       CameraPosition(target: positionOfUserInLatLng, zoom: 15);
  //   controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('DashBoard'),
      // body: Stack(
      //   children: [
      //     GoogleMap(
      //       mapType: MapType.normal,
      //       myLocationButtonEnabled: true,
      //       myLocationEnabled: true,
      //       initialCameraPosition: CameraPosition(
      //         target: LatLng(37.7749, -122.4194), // Default to San Francisco
      //         zoom: 15,
      //       ),
      //       onMapCreated: (GoogleMapController mapController) {
      //         controllerGoogleMap = mapController;
      //         updateMapTheme(controllerGoogleMap!);
      //         googleMapCompleterController.complete(controllerGoogleMap);
      //       },
      //     ),
      //   ],
      // ),
    );
  }
}