import 'dart:convert';
import 'package:cccd/global/global_var.dart';
import 'package:cccd/models/direction_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class CommonMethods {
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaySnackbar('Check internet connection', context);
    }
  }

  displaySnackbar(String messageText, BuildContext context) {
    var snackbar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

<<<<<<< HEAD
  turnOffLocationUpdatesForHomepage() {
    if (positionStreamHomePage != null) {
      positionStreamHomePage!.pause();
    } else {
      print('positionStreamHomePage is null');
    }

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Geofire.removeLocation(currentUser.uid);
    } else {
      print('currentUser is null');
    }
  }

  turnOnLocationUpdatesForHomepage() {
    if (positionStreamHomePage != null) {
      positionStreamHomePage!.resume();
    } else {
      print('positionStreamHomePage is null');
    }

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (driverCurrentPosition != null) {
        Geofire.setLocation(currentUser.uid, driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude);
      } else {
        print('driverCurrentPosition is null');
      }
    } else {
      print('currentUser is null');
=======
  void turnOffLocationUpdatesForHomepage() {
    print("entered into turnOffLocationUpdatesForHomepage");
    if (positionStreamHomePage != null) {
      print("positionStreamHomePage paused");
      positionStreamHomePage!.pause();
    }
    else{
      print('positionStreamHomePage is null');
    }

    if (FirebaseAuth.instance.currentUser != null) {
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      if (kIsWeb) {
        // Web implementation
        final DatabaseReference onlineDriversRef =
            FirebaseDatabase.instance.ref().child('onlineDrivers').child(uid);

        // Remove the driver's location data
        onlineDriversRef.remove();
        print("onlineDriversRef removed");
        
      } else {
        // Mobile implementation using GeoFire
        Geofire.removeLocation(uid);
      }
    }
  }

  void turnOnLocationUpdatesForHomepage() {
    if (positionStreamHomePage != null && driverCurrentPosition != null) {
      positionStreamHomePage!.resume();
      print("positionStreamHomePage resumed");
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      if (kIsWeb) {
        // Web implementation
        final DatabaseReference onlineDriversRef =
            FirebaseDatabase.instance.ref().child('onlineDrivers').child(uid);

        // Set the driver's location data
        onlineDriversRef.set({
          'latitude': driverCurrentPosition!.latitude,
          'longitude': driverCurrentPosition!.longitude,
        });
      } else {
        // Mobile implementation using GeoFire
        Geofire.setLocation(uid, driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude);
      }
    } else {
      // Handle the case where positionStreamHomePage or driverCurrentPosition is null
      print('Error: positionStreamHomePage or driverCurrentPosition is null');
>>>>>>> web
    }
  }

  static Future sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  // DIRECTION API
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      LatLng source, LatLng destination) async {
    String urlDirectionsAPI =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if (responseFromDirectionsAPI == "error") {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();
    detailsModel.distanceTextString =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];
    detailsModel.durationTextString =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodePoints =
        responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;
  }

  calculateFareAmount(DirectionDetails directionDetails) {
    double distancePerKmAmount = 0.4;
    double durationPerMinuteAmount = 0.3;
    double baseFareAmount = 2;

    double totalDistanceTravelFareAmount =
        (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;

    double totalDurationSpendFareAmount =
        (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

<<<<<<< HEAD
    double totalOverAllFareAmount = baseFareAmount +
=======
    double totalOverallFareAmount = baseFareAmount +
>>>>>>> web
        totalDistanceTravelFareAmount +
        totalDurationSpendFareAmount;

    return totalOverallFareAmount.toStringAsFixed(1);
  }
}
