import 'dart:async';


import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";


String googleMapKey = "AIzaSyDCF3-Nl94jUPeUuDdpjT92DO3IjZF655o";

const CameraPosition googlePlexInitialPositon = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

StreamSubscription<Position>? positionStreamHomePage;
StreamSubscription<Position>? positionStreamNewTripPage;

int driverTripRequestTimeout  = 20;

final audioPlayer = AssetsAudioPlayer();

Position? driverCurrentPosition;

String driverName = "";
String driverPhone = "";
String driverPhoto = "";
String carColor = "";
String carModel = "";
String carNumber = "";



