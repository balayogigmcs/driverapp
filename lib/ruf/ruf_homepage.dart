// import 'dart:async';
// import 'package:cccd/global/global_var.dart';
// import 'package:cccd/provider/driver_status_provider.dart';
// import 'package:cccd/push_notification.dart/push_notification_system.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final Completer<GoogleMapController> googleMapCompleterController =
//       Completer<GoogleMapController>();
//   GoogleMapController? controllerGoogleMap;
//   Position? currentPositionOfDriver;
//   DatabaseReference? newTripRequestReference;

//   @override
//   void initState() {
//     super.initState();
//     getCurrentLiveLocationOfDriver();
//     initializePushNotificationSystem();
//     initializeGeofire();
//   }

//   void initializeGeofire() {
//     Geofire.initialize("onlineDrivers");
//   }

//   Future<void> getCurrentLiveLocationOfDriver() async {
//     Position positionOfUser = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.bestForNavigation);
//     setState(() {
//       currentPositionOfDriver = positionOfUser;
//     });

//     LatLng positionOfUserInLatLng = LatLng(
//         currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);
//     CameraPosition cameraPosition =
//         CameraPosition(target: positionOfUserInLatLng, zoom: 15);
//     controllerGoogleMap!
//         .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//   }

//   void setAndGetLocationUpdates() {
//     Geolocator.getPositionStream().listen((Position position) {
//       setState(() {
//         currentPositionOfDriver = position;
//       });

//       final provider = Provider.of<DriverStatusProvider>(context, listen: false);
//       if (provider.isOnline) {
//         // Update driver location
//         Geofire.setLocation(
//             FirebaseAuth.instance.currentUser!.uid,
//             currentPositionOfDriver!.latitude,
//             currentPositionOfDriver!.longitude);
//       }

//       LatLng positionLatLng = LatLng(currentPositionOfDriver!.latitude,
//           currentPositionOfDriver!.longitude);

//       controllerGoogleMap!
//           .animateCamera(CameraUpdate.newLatLng(positionLatLng));
//     });
//   }

//   void goOnlineNow() {
//     Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
//         currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

//     newTripRequestReference = FirebaseDatabase.instance
//         .ref()
//         .child("drivers")
//         .child(FirebaseAuth.instance.currentUser!.uid)
//         .child("newTripStatus");

//     newTripRequestReference!.set("waiting");
//   }

//   void goOfflineNow() {
//     if (newTripRequestReference != null && FirebaseAuth.instance.currentUser != null) {
//       Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

//       newTripRequestReference!.onDisconnect();
//       newTripRequestReference!.remove();
//       newTripRequestReference = null;
//     } else {
//       // Handle the case where newTripRequestReference or currentUser is null
//       print('Error: newTripRequestReference is null or currentUser is null');
//     }
//   }

//   void initializePushNotificationSystem() {
//     PushNotificationSystem notificationSystem = PushNotificationSystem();
//     notificationSystem.generateDeviceRegistrationToken();
//     notificationSystem.startListeningForNewNotifications(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DriverStatusProvider>(context);

//     return Scaffold(
//       body: Stack(
//         children: [
//           // GOOGLE MAP
//           GoogleMap(
//             padding: EdgeInsets.only(top: 136),
//             mapType: MapType.normal,
//             myLocationButtonEnabled: true,
//             myLocationEnabled: true,
//             initialCameraPosition: googlePlexInitialPositon,
//             onMapCreated: (GoogleMapController mapController) {
//               controllerGoogleMap = mapController;
//               googleMapCompleterController.complete(controllerGoogleMap);

//               getCurrentLiveLocationOfDriver();
//             },
//           ),

//           Container(
//             height: 136,
//             width: double.infinity,
//             color: Colors.black54,
//           ),

//           // GO ONLINE OR OFFLINE CONTAINER
//           Positioned(
//               top: 61,
//               left: 0,
//               right: 0,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                       onPressed: () {
//                         showModalBottomSheet(
//                             context: context,
//                             isDismissible: false,
//                             builder: (BuildContext context) {
//                               return Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.black54,
//                                     borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(15),
//                                         topRight: Radius.circular(15)),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black45,
//                                         blurRadius: 5,
//                                         spreadRadius: 0.5,
//                                         offset: Offset(0.7, 0.7),
//                                       ),
//                                     ]),
//                                 height: 221,
//                                 child: Padding(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 24, vertical: 18),
//                                   child: Column(
//                                     children: [
//                                       const SizedBox(
//                                         height: 11,
//                                       ),
//                                       Text(
//                                         (!provider.isOnline)
//                                             ? "GO ONLINE NOW"
//                                             : "GO OFFLINE NOW",
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             fontSize: 22,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white70),
//                                       ),
//                                       const SizedBox(
//                                         height: 21,
//                                       ),
//                                       Text(
//                                         (!provider.isOnline)
//                                             ? "You are about to go online, you will become available to receive notifications from users,"
//                                             : "You are about to go offline, you will stop receiving new trip requests from users.",
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white70),
//                                       ),
//                                       const SizedBox(
//                                         height: 21,
//                                       ),
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                               child: ElevatedButton(
//                                             onPressed: () {
//                                               Navigator.pop(context);
//                                             },
//                                             child: Text(
//                                               "BACK",
//                                             ),
//                                           )),
//                                           const SizedBox(
//                                             height: 16,
//                                           ),
//                                           Expanded(
//                                               child: ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                                 backgroundColor: (!provider.isOnline)
//                                                     ? Colors.green
//                                                     : Colors.pink),
//                                             onPressed: () {
//                                               if (!provider.isOnline) {
//                                                 // go online
//                                                 goOnlineNow();
//                                                 setAndGetLocationUpdates();
//                                                 provider.setOnlineStatus(true);
//                                                 Navigator.pop(context);
//                                               } else {
//                                                 // go offline
//                                                 goOfflineNow();
//                                                 provider.setOnlineStatus(false);
//                                                 Navigator.pop(context);
//                                               }
//                                             },
//                                             child: Text(
//                                               "CONFIRM",
//                                             ),
//                                           )),
//                                         ],
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             });
//                       },
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: (!provider.isOnline)
//                               ? Colors.green
//                               : Colors.pink),
//                       child: Text(
//                           (!provider.isOnline) ? "GO ONLINE NOW" : "GO OFFLINE NOW")),
//                 ],
//               ))
//         ],
//       ),
//     );
//   }

//   @override
//   void debugFillProperties(DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(properties);
//     properties.add(DiagnosticsProperty<Position?>(
//         'currentPositionOfDriver', currentPositionOfDriver));
//   }
// }








