import 'dart:async';
import 'package:cccd/global/global_var.dart';
import 'package:cccd/methods/map_theme_methods.dart';
import 'package:cccd/pages/profile_page.dart';
import 'package:cccd/provider/driver_status_provider.dart';
import 'package:cccd/push_notification/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    // initializeStatus();
    retrieveCurrentDriverInfo();
    getCurrentLiveLocationOfDriver();
    // if (kIsWeb) {
    //   print("checkWebPermissionsAndAMap");
    //   checkWebPermissionsAndLoadMap();
    // } else {
    //   print("getCurrentLiveLocationOfDriver");
    //   getCurrentLiveLocationOfDriver();
    // }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

//   @override
// void didChangeAppLifecycleState(AppLifecycleState state) {
//   super.didChangeAppLifecycleState(state);
//   if (state == AppLifecycleState.paused) {
//     // Do nothing, status remains the same
//   } else if (mounted) {
//     final driverStatusProvider = context.read<DriverStatusProvider>();
//     if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
//       // App is being closed or terminated, set status to offline
//       if (driverStatusProvider.isOnline) {
//         goOfflineNow();
//       }
//     }
//   }
// }


  Future<void> checkWebPermissionsAndLoadMap() async {
    await requestLocationPermissionWeb();
    if (currentPositionOfDriver != null) {
      setState(() {
        LatLng positionOfUserInLatLng = LatLng(
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );

        CameraPosition cameraPosition = CameraPosition(
          target: positionOfUserInLatLng,
          zoom: 15,
        );

        if (controllerGoogleMap != null) {
          controllerGoogleMap!.animateCamera(
            CameraUpdate.newCameraPosition(cameraPosition),
          );
        }
      });
    }
  }

  Future<void> requestLocationPermissionWeb() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPositionOfDriver = position;
      });
    }
  }

  Future<void> getCurrentLiveLocationOfDriver() async {
    try {
      Position positionOfUser = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPositionOfDriver = positionOfUser;
      driverCurrentPosition = currentPositionOfDriver;
      if (currentPositionOfDriver != null && controllerGoogleMap != null) {
        LatLng positionOfUserInLatLng = LatLng(
            currentPositionOfDriver!.latitude,
            currentPositionOfDriver!.longitude);
        CameraPosition cameraPosition =
            CameraPosition(target: positionOfUserInLatLng, zoom: 15);

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
    if (currentPositionOfDriver == null) {
      print('Cannot go online without a valid location');
      return;
    }
    if (kIsWeb) {
      print("Pressed goOnline now");
      DatabaseReference driversRef = FirebaseDatabase.instance
          .ref()
          .child('onlineDrivers')
          .child(FirebaseAuth.instance.currentUser?.uid ?? "");

      driversRef.update({
        'latitude': currentPositionOfDriver!.latitude,
        'longitude': currentPositionOfDriver!.longitude,
      }).catchError((error) {
        print('Failed to update driver location: $error');
      });

      DatabaseReference newTripRequestReference = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(FirebaseAuth.instance.currentUser?.uid ?? "")
          .child("newTripStatus");

      newTripRequestReference.set("waiting").catchError((error) {
        print('Failed to set newTripStatus: $error');
      });

      newTripRequestReference.onValue.listen((event) {
        if (event.snapshot.exists) {
          print("newTripStatus1 is still present: ${event.snapshot.value}");
        } else {
          print("newTripStatus has been removed!");
        }
      });
    } else {
      // Mobile implementation using GeoFire
      Geofire.initialize("onlineDrivers");
      Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude);

      DatabaseReference newTripRequestReference = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("newTripStatus");

      newTripRequestReference.set("waiting");
      newTripRequestReference.onValue.listen((event) {
        // Handle changes in newTripStatus
      });
    }
  }

  void setAndGetLocationUpdates() {
    print("setAndGetLocationsUpdates");
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      if (!mounted) return;

      setState(() {
        currentPositionOfDriver = position;
      });

      if (Provider.of<DriverStatusProvider>(context, listen: false).isOnline) {
        if (kIsWeb) {
          final DatabaseReference ref = FirebaseDatabase.instance
              .ref()
              .child('onlineDrivers')
              .child(FirebaseAuth.instance.currentUser!.uid);
          print("ref");

          ref.update({
            'latitude': position.latitude,
            'longitude': position.longitude,
          });
        } else {
          Geofire.setLocation(
              FirebaseAuth.instance.currentUser!.uid,
              currentPositionOfDriver!.latitude,
              currentPositionOfDriver!.longitude);
        }
      }

      if (controllerGoogleMap != null) {
        LatLng positionLatLng = LatLng(currentPositionOfDriver!.latitude,
            currentPositionOfDriver!.longitude);

        controllerGoogleMap!
            .animateCamera(CameraUpdate.newLatLng(positionLatLng));
      }
    });
  }

  // // void setAndGetLocationUpdates() {
  // //   positionStreamHomePage =
  // //       Geolocator.getPositionStream().listen((Position position) {
  // //     currentPositionOfDriver = position;

  // //     if (Provider.of<DriverStatusProvider>(context, listen: false).isOnline) {
  // //       if (kIsWeb) {
  // //         // Web implementation
  // //         final DatabaseReference ref = FirebaseDatabase.instance
  // //             .ref()
  // //             .child('onlineDrivers')
  // //             .child(FirebaseAuth.instance.currentUser!.uid);

  // //         ref.update({
  // //           'latitude': position.latitude,
  // //           'longitude': position.longitude,
  // //         });
  // //       } else {
  // //         // Mobile implementation using GeoFire
  // //         Geofire.setLocation(
  // //             FirebaseAuth.instance.currentUser!.uid,
  // //             currentPositionOfDriver!.latitude,
  // //             currentPositionOfDriver!.longitude);
  // //       }
  // //     }

  //     LatLng positionLatLng = LatLng(currentPositionOfDriver!.latitude,
  //         currentPositionOfDriver!.longitude);

  //     controllerGoogleMap!
  //         .animateCamera(CameraUpdate.newLatLng(positionLatLng));
  //   });
  // }

  void goOfflineNow() {
    if (kIsWeb) {
      // Web implementation
      final DatabaseReference onlineDriversRef = FirebaseDatabase.instance
          .ref()
          .child('onlineDrivers')
          .child(FirebaseAuth.instance.currentUser!.uid);

      // Remove the driver's newTripStatus and location data
      onlineDriversRef.remove().then((_) {
        final DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child('newTripStatus');
        print("ref");
        print(ref);

        ref.remove().then((_) {
          Provider.of<DriverStatusProvider>(context, listen: false)
              .setOffline();
        }).catchError((error) {
          print("Failed to remove newTripStatus: $error");
        });
      }).catchError((error) {
        print("Failed to remove online driver data: $error");
      });
    } else {
      // Mobile implementation using GeoFire
      Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid).then((_) {
        DatabaseReference newTripRequestReference = FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child("newTripStatus");

        newTripRequestReference.remove().then((_) {
          Provider.of<DriverStatusProvider>(context, listen: false)
              .setOffline();
        }).catchError((error) {
          print("Failed to remove newTripStatus: $error");
        });
      }).catchError((error) {
        print("Failed to remove location: $error");
      });
    }
  }

  Future<void> initializePushNotificationSystem() async {
    if (mounted) {
      PushNotificationSystem notificationSystem = PushNotificationSystem();
      print("before generate device registation token");
      await notificationSystem.generateDeviceRegistrationToken();
      print("after generate device registation token");
      print("before startListeningForNewNotifications");
      notificationSystem.startListeningForNewNotifications(context);
      print("after startListeningForNewNotifications");
    }
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
        // Correctly casting the LinkedMap<Object?, Object?> to Map<String, dynamic>
        final Map<String, dynamic>? driverData =
            Map<String, dynamic>.from(snap.value as Map);

        if (driverData != null) {
          driverName = driverData["name"] ?? 'Unknown';
          driverPhone = driverData["phone"] ?? 'Unknown';
          driverPhoto = driverData["photo"] ?? 'Unknown';
          carColor = driverData["car details"]?["car-color"] ?? 'Unknown';
          carModel = driverData["car details"]?["car-model"] ?? 'Unknown';
          carNumber = driverData["car details"]?["car-number"] ?? 'Unknown';
        }
      }

      await initializePushNotificationSystem();
      print("initializePushNotificationSystem ended");
    } catch (e) {
      print('Error in retrieveCurrentDriverInfo: $e');
    }
  }

 Future<void> initializeStatus() async {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final driverStatusProvider = Provider.of<DriverStatusProvider>(context, listen: false);
    driverStatusProvider.setInitialStatus();
  });
}


  @override
  Widget build(BuildContext context) {
    final driverStatusProvider = Provider.of<DriverStatusProvider>(context);
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Driver Map"),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const Divider(
                height: 1,
                color: Colors.black,
                thickness: 1,
              ),

              //header
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/avatarman.png",
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          const Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(
                height: 1,
                color: Colors.black,
                thickness: 1,
              ),

              const SizedBox(
                height: 10,
              ),

              //body
              //Personal details
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => ProfilePage()),
                  // );
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ProfilePage()),
                      // );
                    },
                    icon: const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text(
                    "Personal details",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

              // wallet
              // GestureDetector(
              //   onTap: () {
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //       builder: (context) => ProfilePage()),
              //     // );
              //   },
              //   child: ListTile(
              //     leading: IconButton(
              //       onPressed: () {
              //         // Navigator.push(
              //         //   context,
              //         //   MaterialPageRoute(
              //         //       builder: (context) => ProfilePage()),
              //         // );
              //       },
              //       icon: const Icon(
              //         Icons.wallet,
              //         color: Colors.black,
              //       ),
              //     ),
              //     title: const Text(
              //       "Wallet",
              //       style: TextStyle(color: Colors.black),
              //     ),
              //   ),
              // ),

//Trips
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => ProfilePage()),
                  // );
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ProfilePage()),
                      // );
                    },
                    icon: const Icon(
                      Icons.account_tree,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text(
                    "Trips",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
// Earnings
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => ProfilePage()),
                  // );
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ProfilePage()),
                      // );
                    },
                    icon: const Icon(
                      Icons.credit_card,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text(
                    "Earnings",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

// Manage vehicles
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => ProfilePage()),
                  // );
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ProfilePage()),
                      // );
                    },
                    icon: const Icon(
                      Icons.car_rental_outlined,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text(
                    "Manage Vehicles",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

//manage documents
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => ProfilePage()),
                  // );
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ProfilePage()),
                      // );
                    },
                    icon: const Icon(
                      Icons.edit_document,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text(
                    "Manage Documents",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

//settings
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => ProfilePage()),
                  // );
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ProfilePage()),
                      // );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text(
                    "Settings",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

//support
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => ProfilePage()),
                  // );
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ProfilePage()),
                      // );
                    },
                    icon: const Icon(
                      Icons.support_agent,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text(
                    "Support",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
// logout
              GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => ProfilePage()),
                    // );
                  },
                  child: ElevatedButton(
                    onPressed: () {},
                    child:
                        Text("Logout", style: TextStyle(color: Colors.black)),
                  )),
            ],
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 136),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: googlePlexInitialPositon,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                googleMapCompleterController.complete(controllerGoogleMap);
                checkWebPermissionsAndLoadMap();
              },
            ),
            Container(
              height: 136,
              width: double.infinity,
              color: Colors.black54,
            ),
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
                                topRight: Radius.circular(15),
                              ),
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
                                  const SizedBox(height: 11),
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
                                  const SizedBox(height: 21),
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
                                  const SizedBox(height: 21),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("BACK"),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                (!driverStatusProvider.isOnline)
                                                    ? Colors.green
                                                    : Colors.pink,
                                          ),
                                          onPressed: () {
                                            if (!driverStatusProvider
                                                .isOnline) {
                                              goOnlineNow();
                                              setAndGetLocationUpdates();
                                              Navigator.pop(context);
                                              driverStatusProvider
                                                  .toggleOnlineStatus();
                                            } else {
                                              goOfflineNow();
                                              Navigator.pop(context);
                                              driverStatusProvider
                                                  .toggleOnlineStatus();
                                            }
                                          },
                                          child: const Text("CONFIRM"),
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
                          : Colors.green,
                    ),
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
            GoogleMap(
              padding: EdgeInsets.only(top: 136),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: googlePlexInitialPositon,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                googleMapCompleterController.complete(controllerGoogleMap);
                getCurrentLiveLocationOfDriver();
              },
            ),
            Container(
              height: 136,
              width: double.infinity,
              color: Colors.black54,
            ),
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
                                              goOnlineNow();
                                              setAndGetLocationUpdates();
                                              Navigator.pop(context);
                                              driverStatusProvider
                                                  .toggleOnlineStatus();
                                            } else {
                                              goOfflineNow();
                                              Navigator.pop(context);
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
