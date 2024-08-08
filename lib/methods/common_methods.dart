import 'dart:convert';
import 'package:cccd/global/global_var.dart';
import 'package:cccd/models/direction_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      displaySnackbar('check internet connection', context);
    }
  }

  displaySnackbar(String messageText, BuildContext context) {
    var snackbar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

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
    }
  }

  static sendRequestToAPI(String apiUrl) async {
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

    var responceFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if (responceFromDirectionsAPI == "error") {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();
    detailsModel.distanceTextString =
        responceFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits =
        responceFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];
    detailsModel.durationTextString =
        responceFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits =
        responceFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodePoints =
        responceFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

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

    double totalOverAllFareAmount = baseFareAmount +
        totalDistanceTravelFareAmount +
        totalDurationSpendFareAmount;

    return totalOverAllFareAmount.toStringAsFixed(1);
  }
}
