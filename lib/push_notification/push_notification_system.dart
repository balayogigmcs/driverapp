
// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:cccd/global/global_var.dart';
import 'package:cccd/models/trip_details.dart';
import 'package:cccd/widgets/loading_dialog.dart';
import 'package:cccd/widgets/notification_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PushNotificationSystem {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> generateDeviceRegistrationToken() async {
    try {
      String? deviceToken;

      if (kIsWeb) {
        print("Kis web");
        // Web-specific token generation
        deviceToken = await _firebaseMessaging.getToken();

        // Register the service worker for FCM on the web
        // try {
        //   await html.window.navigator.serviceWorker
        //       ?.register('/firebase-messaging-sw.js');
        //   print('Service worker registered successfully.');
        // } catch (e) {
        //   print('Error registering service worker: $e');
        // }
      } else {
        // For Android & iOS
        deviceToken = await _firebaseMessaging.getToken();

        // Mobile platform: Subscribe to topics
        await _firebaseMessaging.subscribeToTopic("drivers");
        await _firebaseMessaging.subscribeToTopic("users");
      }

      if (deviceToken != null) {
        DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child("deviceToken");

        print(deviceToken);

        await referenceOnlineDriver.set(deviceToken);
      } else {
        print("Failed to get device token.");
      }
    } catch (e) {
      print("Error generating device token: $e");
    }
  }

  void startListeningForNewNotifications(BuildContext context) {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        retrieveTripRequestInfo(tripID, context);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        retrieveTripRequestInfo(tripID, context);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        retrieveTripRequestInfo(tripID, context);
      }
    });
  }

  Future<void> retrieveTripRequestInfo(String tripID, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Getting details..."),
    );

    DatabaseReference tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequests").child(tripID);

    await tripRequestRef.once().then((dataSnapshot)  {
      Navigator.pop(context);

      // audioPlayer.open(Audio("assets/audio/alert_sound.mp3"));

      TripDetails tripDetailsInfo = TripDetails();

      double pickUpLat = double.parse((dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["latitude"]);
      double pickUpLng = double.parse((dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["longitude"]);

      tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);
      tripDetailsInfo.pickUpAddress = (dataSnapshot.snapshot.value! as Map)["pickUpAddress"];

      double dropOffLat = double.parse((dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["latitude"]);
      double dropOffLng = double.parse((dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["longitude"]);

      tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);
      tripDetailsInfo.dropOffAddress = (dataSnapshot.snapshot.value! as Map)["dropOffAddress"];

      tripDetailsInfo.userName = (dataSnapshot.snapshot.value! as Map)["userName"];
      tripDetailsInfo.userPhone = (dataSnapshot.snapshot.value! as Map)["userPhone"];
      tripDetailsInfo.tripID = tripID;

//       List<Map<dynamic, dynamic>> mobilityAidDataList = await fetchMobilityAidData();
// print("before NotificationDialog is called");
      showDialog(
        context: context,
        builder: (BuildContext context) => NotificationDialog(
          tripDetailsInfo: tripDetailsInfo,
          // mobilityAidDataList: mobilityAidDataList,
        ),
      );
    });
  }
  // Future<List<Map<dynamic, dynamic>>> fetchMobilityAidData() async {
  //   List<Map<dynamic, dynamic>> mobilityAidDataList = [];
  //   DatabaseReference mobilityAidsRef =
  //       FirebaseDatabase.instance.ref().child('mobilityAids');
  //   print("Fetching mobility aid data...");

  //   await mobilityAidsRef
  //       .orderByChild('isCurrent')
  //       .equalTo(true)
  //       .once()
  //       .then((mobilityAidSnap) async {
  //     final values = mobilityAidSnap.snapshot.value as Map<dynamic, dynamic>?;
  //     if (values != null) {
  //       mobilityAidDataList.clear(); // Clear the list before adding new data
  //       values.forEach((key, value) async {
  //         mobilityAidDataList.add(Map<dynamic, dynamic>.from(value));

  //         // Update the fetched record to set isCurrent to false
  //         await mobilityAidsRef.child(key).update({'isCurrent': false});
  //       });
  //     }
  //     print('Fetched mobility aid data: $mobilityAidDataList'); // Debugging log
  //   }).catchError((error) {
  //     print('Error fetching mobility aid data: $error'); // Debugging log
  //   });
  //   return mobilityAidDataList;
  // }
}

// Future<List<Map<dynamic, dynamic>>> fetchMobilityAidData() async {
//   List<Map<dynamic, dynamic>> mobilityAidDataList = [];
//   DatabaseReference mobilityAidsRef =
//       FirebaseDatabase.instance.ref().child('mobilityAids');
//   print("Fetching mobility aid data...");

//   await mobilityAidsRef
//       .orderByChild('isCurrent')
//       .equalTo(true)
//       .once()
//       .then((mobilityAidSnap) async {
//     final values = mobilityAidSnap.snapshot.value as Map<dynamic, dynamic>?;
//     if (values != null) {
//       mobilityAidDataList.clear(); // Clear the list before adding new data
//       values.forEach((key, value) {
//         mobilityAidDataList.add(Map<dynamic, dynamic>.from(value));

//         // Update the fetched record to set isCurrent to false
//         mobilityAidsRef.child(key).update({'isCurrent': false});
//       });
//     }
//     print('Fetched mobility aid data: $mobilityAidDataList'); // Debugging log
//   }).catchError((error) {
//     print('Error fetching mobility aid data: $error'); // Debugging log
//   });
//   return mobilityAidDataList;
// }


// Future<List<Map<dynamic, dynamic>>> fetchMobilityAidData() async {
//   List<Map<dynamic, dynamic>> mobilityAidDataList = [];
//   DatabaseReference mobilityAidsRef =
//       FirebaseDatabase.instance.ref().child('mobilityAids');
//   print("Fetching mobility aid data...");

//   await mobilityAidsRef
//       .orderByChild('isCurrent')
//       .equalTo(true)
//       .once()
//       .then((mobilityAidSnap) async {
//     final values = mobilityAidSnap.snapshot.value as Map<dynamic, dynamic>?;
//     if (values != null) {
//       mobilityAidDataList.clear(); // Clear the list before adding new data
//       values.forEach((key, value) async {
//         mobilityAidDataList.add(Map<dynamic, dynamic>.from(value));

//         // Update the fetched record to set isCurrent to false
//         await mobilityAidsRef.child(key).update({'isCurrent': false});
//       });
//     }
//     print('Fetched mobility aid data: $mobilityAidDataList'); // Debugging log
//   }).catchError((error) {
//     print('Error fetching mobility aid data: $error'); // Debugging log
//   });
//   return mobilityAidDataList;
// }










// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:cccd/global/global_var.dart';
// import 'package:cccd/models/trip_details.dart';
// import 'package:cccd/widgets/loading_dialog.dart';
// import 'package:cccd/widgets/notification_dialog.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class PushNotificationSystem {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final User? user = FirebaseAuth.instance.currentUser;

//   Future<void> generateDeviceRegistrationToken() async {
//     try {
//       String? deviceToken = await _firebaseMessaging.getToken();
//       if (deviceToken != null) {
//         DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance
//             .ref()
//             .child("drivers")
//             .child(FirebaseAuth.instance.currentUser!.uid)
//             .child("deviceToken");

//         await referenceOnlineDriver.set(deviceToken);

//         _firebaseMessaging.subscribeToTopic("drivers");
//         _firebaseMessaging.subscribeToTopic("users");
//       } else {
//         print("Failed to get device token.");
//       }
//     } catch (e) {
//       print("Error generating device token: $e");
//     }
//   }

//   void startListeningForNewNotifications(BuildContext context) {
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? messageRemote) {
//       if (messageRemote != null) {
//         String tripID = messageRemote.data["tripID"];
//         retrieveTripRequestInfo(tripID, context);
//       }
//     });

//     FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
//       if (messageRemote != null) {
//         String tripID = messageRemote.data["tripID"];
//         retrieveTripRequestInfo(tripID, context);
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
//       if (messageRemote != null) {
//         String tripID = messageRemote.data["tripID"];
//         retrieveTripRequestInfo(tripID, context);
//       }
//     });
//   }

//   Future<void> retrieveTripRequestInfo(
//       String tripID, BuildContext context) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) =>
//           LoadingDialog(messageText: "Getting details..."),
//     );

//     DatabaseReference tripRequestRef =
//         FirebaseDatabase.instance.ref().child("tripRequests").child(tripID);

//     await tripRequestRef.once().then((dataSnapshot) async {
//       Navigator.pop(context);

//       audioPlayer.open(Audio("assets/audio/alert_sound.mp3"));

//       TripDetails tripDetailsInfo = TripDetails();

//       double pickUpLat = double.parse(
//           (dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["latitude"]);
//       double pickUpLng = double.parse(
//           (dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["longitude"]);

//       tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);
//       tripDetailsInfo.pickUpAddress =
//           (dataSnapshot.snapshot.value! as Map)["pickUpAddress"];

//       double dropOffLat = double.parse(
//           (dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["latitude"]);
//       double dropOffLng = double.parse(
//           (dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["longitude"]);

//       tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);
//       tripDetailsInfo.dropOffAddress =
//           (dataSnapshot.snapshot.value! as Map)["dropOffAddress"];

//       tripDetailsInfo.userName =
//           (dataSnapshot.snapshot.value! as Map)["userName"];
//       tripDetailsInfo.userPhone =
//           (dataSnapshot.snapshot.value! as Map)["userPhone"];
//       tripDetailsInfo.tripID = tripID;

//       List<Map<dynamic, dynamic>> mobilityAidDataList =
//           await fetchMobilityAidData();

//       showDialog(
//         context: context,
//         builder: (BuildContext context) => NotificationDialog(
//           tripDetailsInfo: tripDetailsInfo,
//           mobilityAidDataList: mobilityAidDataList,
//         ),
//       );
//     });
//   }

//   Future<List<Map<dynamic, dynamic>>> fetchMobilityAidData() async {
//     List<Map<dynamic, dynamic>> mobilityAidDataList = [];
//     DatabaseReference mobilityAidsRef =
//         FirebaseDatabase.instance.ref().child('mobilityAids');
//     print("Fetching mobility aid data...");
//     await mobilityAidsRef.once().then((mobilityAidSnap) {
//       final values = mobilityAidSnap.snapshot.value as Map<dynamic, dynamic>?;
//       if (values != null) {
//         values.forEach((key, value) {
//           mobilityAidDataList.add(Map<dynamic, dynamic>.from(value));
//         });
//       }
//       print('Fetched mobility aid data: $mobilityAidDataList'); // Debugging log
//     }).catchError((error) {
//       print('Error fetching mobility aid data: $error'); // Debugging log
//     });
//     return mobilityAidDataList;
//   }
// }



