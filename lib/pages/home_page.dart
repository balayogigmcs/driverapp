import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cccd/global/global_var.dart';
import 'package:cccd/push_notification.dart/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  Color colorToShow = Colors.green;
  String titleToShow = "GO ONLINE NOW";
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReference;

  @override
  void initState() {
    super.initState();
    getCurrentLiveLocationOfDriver();

    initializePushNotificationSystem();
  }

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes('themes/dark_style.json')
        .then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String path) async {
    ByteData byteData = await rootBundle.load(path);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  void setGoogleMapStyle(
      String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfDriver() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  goOnlineNow() {
    // all driver who are available for new trip requests
    Geofire.initialize("onlineDrivers");

    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    newTripRequestReference!.set("waiting");
    newTripRequestReference!.onValue.listen((event) {});
  }

  setAndGetLocationUpdates() {
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfUser = position;

      if (isDriverAvailable == true) {
        Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
            currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
      }

      LatLng positionLatLng = LatLng(
          currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

      controllerGoogleMap!
          .animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  goOfflineNow() {
    //Stop sharing live location updates to driver
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

// the below method is executed in initState()
  initializePushNotificationSystem() {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // GOOGLE MAP
          GoogleMap(
            padding: EdgeInsets.only(top: 136),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default to San Francisco
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);
            },
          ),

          Container(
            height: 136,
            width: double.infinity,
            color: Colors.black54,
          ),

          // GO ONLINE OR OFFLINE CONTAINER
          Positioned(
              top: 61,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            isDismissible: false,
                            builder: (BuildContext context) {
                              return Container(
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black45,
                                        blurRadius: 5,
                                        spreadRadius: 0.5,
                                        offset: Offset(0.7, 0.7),
                                      ),
                                    ]),
                                height: 221,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 18),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 11,
                                      ),
                                      Text(
                                        (!isDriverAvailable)
                                            ? "GO ONLINE NOW"
                                            : "GO OFFLINE NOW",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70),
                                      ),
                                      const SizedBox(
                                        height: 21,
                                      ),
                                      Text(
                                        (!isDriverAvailable)
                                            ? "You are about to go online, you will become available to receive notification from users,"
                                            : "You are about to go offline, you will stop receiving new trip requests from users.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70),
                                      ),
                                      const SizedBox(
                                        height: 21,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "BACK",
                                            ),
                                          )),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Expanded(
                                              child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: (titleToShow ==
                                                        "GO ONLINE NOW")
                                                    ? Colors.green
                                                    : Colors.pink),
                                            onPressed: () {
                                              if (!isDriverAvailable) {
                                                // go online
                                                goOnlineNow();

                                                //get driver location updates
                                                setAndGetLocationUpdates();

                                                Navigator.pop(context);

                                                setState(() {
                                                  colorToShow = Colors.pink;
                                                  titleToShow =
                                                      "GO OFFLINE NOW";
                                                  isDriverAvailable = true;
                                                });
                                              } else {
                                                // go offline
                                                goOfflineNow();

                                                Navigator.pop(context);

                                                setState(() {
                                                  colorToShow = Colors.green;
                                                  titleToShow = "GO ONLINE NOW";
                                                  isDriverAvailable = false;
                                                });
                                              }
                                            },
                                            child: Text(
                                              "CONFIRM",
                                            ),
                                          )),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorToShow),
                      child: Text(titleToShow))
                ],
              ))
        ],
      ),
    );
  }
}
