import 'dart:async';

import 'package:cccd/global/global_var.dart';
import 'package:cccd/methods/common_methods.dart';
import 'package:cccd/methods/map_theme_methods.dart';
import 'package:cccd/models/trip_details.dart';
import 'package:cccd/widgets/loading_dialog.dart';
import 'package:cccd/widgets/payment_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class NewTripPage extends StatefulWidget {
  TripDetails? newTripDetailInfo;
  NewTripPage({super.key, this.newTripDetailInfo});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  MapThemeMethods themeMethods = MapThemeMethods();
  double googleMapPaddingFromBottom = 0;
  List<LatLng> coordinatesPolylineLatLngList = [];
  PolylinePoints pointsPolyline = PolylinePoints();
  Set<Marker> markerSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polylineSet = Set<Polyline>();
  BitmapDescriptor? carMarkerIcon;
  bool directionRequested = false;
  String statusOfTrip = "accepted";
  String durationText = "";
  String distanceText = "";
  String buttonTitleText = "ARRIVED";
  Color buttonColor = Colors.indigoAccent;
  CommonMethods cmethods = CommonMethods();

  makeMarker() {
    if (carMarkerIcon == null) {
      ImageConfiguration configuration =
          createLocalImageConfiguration(context, size: Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(
              configuration, "assets/images/tracking.png")
          .then((valueIcon) {
        carMarkerIcon = valueIcon;
      });
    }
  }

  obtainDirectionAndDrawRoute(
      sourceLocationLatLng, destinationLocationLatLng) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: 'Please wait ....'));

    var tripDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
        sourceLocationLatLng, destinationLocationLatLng);

    Navigator.pop(context);

    List<PointLatLng> latLngPoints =
        pointsPolyline.decodePolyline(tripDetailsInfo!.encodePoints!);

    coordinatesPolylineLatLngList.clear();

    if (latLngPoints.isNotEmpty) {
      latLngPoints.forEach((PointLatLng pointLatLng) {
        coordinatesPolylineLatLngList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

// DRAW POLYLINE
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          polylineId: const PolylineId("polylineID"),
          color: Colors.pink,
          points: coordinatesPolylineLatLngList,
          jointType: JointType.round,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      polylineSet.add(polyline);
    });

    // FIT THE POLYLINE ON GOOGLEMAP

    LatLngBounds boundsLatLng;

    double minLat =
        sourceLocationLatLng.latitude < destinationLocationLatLng.latitude
            ? sourceLocationLatLng.latitude
            : destinationLocationLatLng.latitude;
    double maxLat =
        sourceLocationLatLng.latitude > destinationLocationLatLng.latitude
            ? sourceLocationLatLng.latitude
            : destinationLocationLatLng.latitude;

    double minLng =
        sourceLocationLatLng.longitude < destinationLocationLatLng.longitude
            ? sourceLocationLatLng.longitude
            : destinationLocationLatLng.longitude;
    double maxLng =
        sourceLocationLatLng.longitude > destinationLocationLatLng.longitude
            ? sourceLocationLatLng.longitude
            : destinationLocationLatLng.longitude;

    boundsLatLng = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    Marker sourceMarker = Marker(
      markerId: const MarkerId("pickUpPointMarkerID"),
      position: sourceLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: "Pickup Location",
        snippet: widget.newTripDetailInfo!.pickUpAddress.toString(),
      ),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("dropOffDestinationPointMarkerID"),
      position: destinationLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: "Destination Location",
        snippet: widget.newTripDetailInfo!.dropOffAddress.toString(),
      ),
    );

    setState(() {
      markerSet.add(sourceMarker);
      markerSet.add(destinationMarker);
    });

    Circle sourceCircle = Circle(
        circleId: const CircleId("pickUpPointCircleID"),
        strokeColor: Colors.orange,
        strokeWidth: 4,
        radius: 14,
        center: sourceLocationLatLng,
        fillColor: Colors.green);

    Circle destinationCircle = Circle(
        circleId: const CircleId("dropOffDestinationPointCircleID"),
        strokeColor: Colors.green,
        strokeWidth: 4,
        radius: 14,
        center: destinationLocationLatLng,
        fillColor: Colors.orange);

    setState(() {
      circleSet.add(sourceCircle);
      circleSet.add(destinationCircle);
    });
  }

  getLiveLocationUpdatesOfDriver() {
    positionStreamNewTripPage =
        Geolocator.getPositionStream().listen((Position positionDriver) {
      // Update driver's current position
      driverCurrentPosition = positionDriver;
      LatLng driverCurrentPositionLatLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      // Update marker position on map
      Marker carMarker = Marker(
        markerId: MarkerId("carMarkerID"),
        position: driverCurrentPositionLatLng,
        icon: carMarkerIcon!,
        infoWindow: const InfoWindow(title: "My Location"),
      );

      setState(() {
        // Update marker position
        markerSet
            .removeWhere((element) => element.markerId.value == 'carMarkerID');
        markerSet.add(carMarker);

        // Animate camera to new position
        CameraPosition cameraPosition =
            CameraPosition(target: driverCurrentPositionLatLng, zoom: 14);
        controllerGoogleMap!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      });
//update Trip details information
      updateTripDetailsInformation();

      // Update driver's location in Firebase
      Map<String, dynamic> updatedLocationOfDriver = {
        "latitude": driverCurrentPosition!.latitude,
        "longitude": driverCurrentPosition!.longitude,
      };

      FirebaseDatabase.instance
          .ref()
          .child("tripRequests")
          .child(widget.newTripDetailInfo!.tripID!)
          .child("driverLocation")
          .set(updatedLocationOfDriver);
    });
  }

  //update Trip details information
  updateTripDetailsInformation() async {
    if (!directionRequested) {
      directionRequested = true;

      if (driverCurrentPosition == null) {
        return;
      }

      var driverLocationLatLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      LatLng dropOffDestinationLocationLatLng;
      if (statusOfTrip == "accepted") {
        dropOffDestinationLocationLatLng =
            widget.newTripDetailInfo!.pickUpLatLng!;
      } else {
        dropOffDestinationLocationLatLng =
            widget.newTripDetailInfo!.dropOffLatLng!;
      }

      var directionDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
          driverLocationLatLng, dropOffDestinationLocationLatLng);

      if (directionDetailsInfo != null) {
        directionRequested = false;
        setState(() {
          durationText = directionDetailsInfo.durationTextString!;
          distanceText = directionDetailsInfo.distanceTextString!;
        });
      }
    }
  }

  endTripNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: 'Please wait ....'));

    var driverCurrentLocationLatLng = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    var directionDetailsEndTripInfo =
        await CommonMethods.getDirectionDetailsFromAPI(
            widget.newTripDetailInfo!.pickUpLatLng!,
            driverCurrentLocationLatLng);

    Navigator.pop(context);

    String fareAmount =
        (cmethods.calculateFareAmount(directionDetailsEndTripInfo!)).toString();


    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailInfo!.tripID!)
        .child("fareAmount")
        .set(fareAmount);

    // await FirebaseDatabase.instance
    //     .ref()
    //     .child("tripRequests")
    //     .child(widget.newTripDetailInfo!.tripID!)
    //     .child("status")
    //     .set("completed");

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailInfo!.tripID!)
        .child("status")
        .set("ended");

    positionStreamNewTripPage!.cancel();

    // Dialog for collecting fare amount
    displayPaymentDialog(fareAmount);

    // Save fare amount to driver total earnings
    saveFareAmountToDriverTotalEarnings(fareAmount);
  }

  displayPaymentDialog(fareAmount) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            PaymentDialog(fareAmount: fareAmount));
  }

  saveFareAmountToDriverTotalEarnings(String fareAmount) async {
    DatabaseReference driverEarningsRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("earnings");

    await driverEarningsRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        double previousTotalEarnings =
            double.parse(snap.snapshot.value.toString());
        double fareAmountForTrip = double.parse(fareAmount);

        double newTotalEarnings = previousTotalEarnings + fareAmountForTrip;

        driverEarningsRef.set(newTotalEarnings);
      } else {
        driverEarningsRef.set(fareAmount);
      }
    });
  }

  saveDriverDataToTripInfo() async {
    Map<String, dynamic> driverDataMap = {
      "status": "accepted",
      "driverID": FirebaseAuth.instance.currentUser!.uid,
      "driverName": driverName,
      "driverPhone": driverPhone,
      "driverPhoto": driverPhoto,
      "carDetails": carColor + " - " + carModel + " - " + carNumber,
    };

    Map<String, dynamic> driverCurrentLocation = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString()
    };

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailInfo!.tripID!)
        .update(driverDataMap);

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailInfo!.tripID!)
        .child("driverLocation")
        .update(driverCurrentLocation);
  }

  @override
  void initState() {
    super.initState();
    saveDriverDataToTripInfo();
  }

  @override
  Widget build(BuildContext context) {
  makeMarker();
  return Scaffold(
    body: Stack(
      children: [
        // GOOGLE MAP
        GoogleMap(
          padding: EdgeInsets.only(bottom: googleMapPaddingFromBottom),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          markers: markerSet,
          circles: circleSet,
          polylines: polylineSet,
          initialCameraPosition: googlePlexInitialPositon,
          onMapCreated: (GoogleMapController mapController) async {
            controllerGoogleMap = mapController;
            themeMethods.updateMapTheme(controllerGoogleMap!);
            googleMapCompleterController.complete(controllerGoogleMap);

            setState(() {
              googleMapPaddingFromBottom = 262;
            });

            var driverCurrentLocationLatLng = LatLng(
                driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude);

            var userPickUpLocationLatLng =
                widget.newTripDetailInfo!.pickUpLatLng;

            await obtainDirectionAndDrawRoute(
                driverCurrentLocationLatLng, userPickUpLocationLatLng);

            getLiveLocationUpdatesOfDriver();
          },
        ),

        // TRIP DETAILS
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,  // Changed background color to white
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,  // Changed shadow color to black12
                  blurRadius: 17,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            height: 256,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TRIP DURATION AND DISTANCE
                  Center(
                    child: Text(
                      '$durationText - $distanceText',
                      style: const TextStyle(
                          color: Colors.blue,  // Changed text color to blue
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.newTripDetailInfo!.userName!,
                        style: const TextStyle(
                            color: Colors.black,  // Changed text color to black
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),

                      // Call user Icon Button
                      GestureDetector(
                        onTap: () {
                          launchUrl(Uri.parse(
                              "tel://${widget.newTripDetailInfo!.userPhone.toString()}"));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.phone,
                            color: Colors.blue,  // Changed icon color to blue
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // PICKUP ICON AND LOCATION
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/initial.png",
                        height: 16,
                        width: 16,
                      ),
                      Expanded(
                        child: Text(
                          widget.newTripDetailInfo!.pickUpAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,  // Changed text color to black
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // DROPOFF ICON AND LOCATION
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/final.png",
                        height: 16,
                        width: 16,
                      ),
                      Expanded(
                        child: Text(
                          widget.newTripDetailInfo!.dropOffAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,  // Changed text color to black
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          // Arrived trip button
                          if (statusOfTrip == "accepted") {
                            setState(() {
                              buttonTitleText = "START TRIP";
                              buttonColor = Colors.blue;  // Changed button color to blue
                            });
                            statusOfTrip = "arrived";

                            FirebaseDatabase.instance
                                .ref()
                                .child("tripRequests")
                                .child(widget.newTripDetailInfo!.tripID!)
                                .child("status")
                                .set("arrived");

                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    LoadingDialog(
                                        messageText: 'Please wait ....'));

                            await obtainDirectionAndDrawRoute(
                                widget.newTripDetailInfo!.pickUpLatLng,
                                widget.newTripDetailInfo!.dropOffLatLng);

                            Navigator.pop(context);
                          }
                          // Start trip button
                          else if (statusOfTrip == "arrived") {
                            setState(() {
                              buttonTitleText = "END TRIP";
                              buttonColor = Colors.red;  // Changed button color to amber
                            });
                            statusOfTrip = "ontrip";

                            FirebaseDatabase.instance
                                .ref()
                                .child("tripRequests")
                                .child(widget.newTripDetailInfo!.tripID!)
                                .child("status")
                                .set("ontrip");
                          }
                          // End trip button
                          else if (statusOfTrip == "ontrip") {
                            endTripNow();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor),
                        child: Text(
                          buttonTitleText,
                          style: const TextStyle(color: Colors.white),
                        )),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}

}
