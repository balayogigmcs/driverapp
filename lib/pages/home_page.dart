import 'dart:async';
import 'package:cccd/global/global_var.dart';
import 'package:cccd/methods/map_theme_methods.dart';
import 'package:cccd/provider/driver_status_provider.dart';
import 'package:cccd/push_notification.dart/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  MapThemeMethods themeMethods = MapThemeMethods();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCurrentLiveLocationOfDriver();
    retrieveCurrentDriverInfo();
    initializeStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App is in background, do nothing to keep the status the same
    } else if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // App is being closed or terminated, set status to offline
      if (Provider.of<DriverStatusProvider>(context, listen: false).isOnline) {
        goOfflineNow();
      }
    }
  }

  Future<void> getCurrentLiveLocationOfDriver() async {
    try {
      Position positionOfUser = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      currentPositionOfDriver = positionOfUser;
      driverCurrentPosition = currentPositionOfDriver;

      LatLng positionOfUserInLatLng = LatLng(currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: positionOfUserInLatLng, zoom: 15);

      if (controllerGoogleMap != null) {
        controllerGoogleMap!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      } else {
        print('controllerGoogleMap is null');
      }
    } catch (e) {
      print('Error in getting current location: $e');
    }
  }

  void goOnlineNow() {
    // all drivers who are available for new trip requests
    Geofire.initialize("onlineDrivers");

    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
        currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    DatabaseReference newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    newTripRequestReference.set("waiting");
    newTripRequestReference.onValue.listen((event) {});
  }

  void setAndGetLocationUpdates() {
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      if (Provider.of<DriverStatusProvider>(context, listen: false).isOnline) {
        Geofire.setLocation(
            FirebaseAuth.instance.currentUser!.uid,
            currentPositionOfDriver!.latitude,
            currentPositionOfDriver!.longitude);
      }

      LatLng positionLatLng = LatLng(currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude);

      controllerGoogleMap!
          .animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  void goOfflineNow() {
    // Stop sharing live location updates to driver
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    DatabaseReference newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    newTripRequestReference.onDisconnect();
    newTripRequestReference.remove();

    // Set the driver status to offline in Firebase Realtime Database
    Provider.of<DriverStatusProvider>(context, listen: false).setOffline();
  }

  void initializePushNotificationSystem() {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotifications(context);
  }

  void retrieveCurrentDriverInfo() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .once();

      DataSnapshot snap = event.snapshot;
      if (snap.value != null) {
        Map driverData = snap.value as Map;

        driverName = driverData["name"] ?? 'Unknown';
        driverPhone = driverData["phone"] ?? 'Unknown';
        driverPhoto = driverData["photo"] ?? 'Unknown';
        carColor = driverData["car details"]["car-color"] ?? 'Unknown';
        carModel = driverData["car details"]["car-model"] ?? 'Unknown';
        carNumber = driverData["car details"]["car-number"] ?? 'Unknown';
      }

      initializePushNotificationSystem();
    } catch (e) {
      // Handle exceptions if needed
      print('Error in retrieveCurrentDriverInfo: $e');
    }
  }

  void initializeStatus() async {
    await Provider.of<DriverStatusProvider>(context, listen: false)
        .setInitialStatus();
  }

  @override
  Widget build(BuildContext context) {
    final driverStatusProvider = Provider.of<DriverStatusProvider>(context);
    if (kIsWeb) {
      return AdminScaffold(
        appBar: AppBar(
          title: Text("Driver Map"),
        ),
        sideBar: const SideBar(
          items: [
            AdminMenuItem(
              title: 'Dashboard',
              route: '/',
              icon: Icons.dashboard,
            ),
            AdminMenuItem(
              title: 'Drivers',
              route: '/drivers',
              icon: Icons.drive_eta,
            ),
            // Add more menu items as needed
          ],
          selectedRoute: '/',
        ),
        body: Stack(
          children: [
            // GOOGLE MAP
            GoogleMap(
              padding: EdgeInsets.only(top: 136),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: googlePlexInitialPositon,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                googleMapCompleterController.complete(controllerGoogleMap);

                // Now it is safe to call getCurrentLiveLocationOfDriver()
                getCurrentLiveLocationOfDriver();
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
                            decoration: const BoxDecoration(
                              color: Colors.white,
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
                              ],
                            ),
                            height: 221,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 18),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 11,
                                  ),
                                  Text(
                                    (!driverStatusProvider.isOnline)
                                        ? "GO ONLINE NOW"
                                        : "GO OFFLINE NOW",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(
                                    height: 21,
                                  ),
                                  Text(
                                    (!driverStatusProvider.isOnline)
                                        ? "You are about to go online, you will become available to receive notification from users,"
                                        : "You are about to go offline, you will stop receiving new trip requests from users.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
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
                                          child: const Text(
                                            "BACK",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  (!driverStatusProvider
                                                          .isOnline)
                                                      ? Colors.green
                                                      : Colors.pink),
                                          onPressed: () {
                                            if (!driverStatusProvider
                                                .isOnline) {
                                              // go online
                                              goOnlineNow();

                                              // get driver location updates
                                              setAndGetLocationUpdates();

                                              Navigator.pop(context);

                                              // Update driver status in Firebase Realtime Database
                                              driverStatusProvider
                                                  .toggleOnlineStatus();
                                            } else {
                                              // go offline
                                              goOfflineNow();

                                              Navigator.pop(context);

                                              // Update driver status in Firebase Realtime Database
                                              driverStatusProvider
                                                  .toggleOnlineStatus();
                                            }
                                          },
                                          child: Text(
                                            "CONFIRM",
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: driverStatusProvider.isOnline
                            ? Colors.pink
                            : Colors.green),
                    child: Text(driverStatusProvider.isOnline
                        ? "GO OFFLINE NOW"
                        : "GO ONLINE NOW"),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: [
            // GOOGLE MAP
            GoogleMap(
              padding: EdgeInsets.only(top: 136),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: googlePlexInitialPositon,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                googleMapCompleterController.complete(controllerGoogleMap);

                // Now it is safe to call getCurrentLiveLocationOfDriver()
                getCurrentLiveLocationOfDriver();
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
                            decoration: const BoxDecoration(
                              color: Colors.white,
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
                              ],
                            ),
                            height: 221,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 18),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 11,
                                  ),
                                  Text(
                                    (!driverStatusProvider.isOnline)
                                        ? "GO ONLINE NOW"
                                        : "GO OFFLINE NOW",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(
                                    height: 21,
                                  ),
                                  Text(
                                    (!driverStatusProvider.isOnline)
                                        ? "You are about to go online, you will become available to receive notification from users,"
                                        : "You are about to go offline, you will stop receiving new trip requests from users.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
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
                                          child: const Text(
                                            "BACK",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  (!driverStatusProvider
                                                          .isOnline)
                                                      ? Colors.green
                                                      : Colors.pink),
                                          onPressed: () {
                                            if (!driverStatusProvider
                                                .isOnline) {
                                              // go online
                                              goOnlineNow();

                                              // get driver location updates
                                              setAndGetLocationUpdates();

                                              Navigator.pop(context);

                                              // Update driver status in Firebase Realtime Database
                                              driverStatusProvider
                                                  .toggleOnlineStatus();
                                            } else {
                                              // go offline
                                              goOfflineNow();

                                              Navigator.pop(context);

                                              // Update driver status in Firebase Realtime Database
                                              driverStatusProvider
                                                  .toggleOnlineStatus();
                                            }
                                          },
                                          child: Text(
                                            "CONFIRM",
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: driverStatusProvider.isOnline
                            ? Colors.pink
                            : Colors.green),
                    child: Text(driverStatusProvider.isOnline
                        ? "GO OFFLINE NOW"
                        : "GO ONLINE NOW"),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Position?>(
        'currentPositionOfDriver', currentPositionOfDriver));
  }
}
