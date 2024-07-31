
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cccd/global/global_var.dart';
import 'package:cccd/models/trip_details.dart';
import 'package:cccd/widgets/loading_dialog.dart';
import 'package:cccd/widgets/notification_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> generateDeviceRegistrationToken() async {
    try {
      String? deviceToken = await _firebaseMessaging.getToken();
      if (deviceToken != null) {
        DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child("deviceToken");

        await referenceOnlineDriver.set(deviceToken);

        _firebaseMessaging.subscribeToTopic("drivers");
        _firebaseMessaging.subscribeToTopic("users");
      } else {
        print("Failed to get device token.");
      }
    } catch (e) {
      print("Error generating device token: $e");
      // Handle error, e.g., show error message to the user
    }
  }

  void startListeningForNewNotifications(BuildContext context) {
    // Handle initial message when the app is terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];

        retrieveTripRequestInfo(tripID, context);
      }
    });

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];

        retrieveTripRequestInfo(tripID, context);
      }
    });

    // Handle incoming messages when the app is in the background and opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];

        retrieveTripRequestInfo(tripID, context);
      }
    });
  }

  retrieveTripRequestInfo(String tripID, BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "getting details ...."));

    DatabaseReference tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequests").child(tripID);

    tripRequestRef.once().then((dataSnapshot) {
      Navigator.pop(context);

      // play Notification sound

      audioPlayer.open(Audio("assets/audio/alert_sound.mp3"));



      TripDetails tripDetailsInfo = TripDetails();

      double pickUpLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["latitude"]);
      double pickUpLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["longitude"]);

      tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);

      tripDetailsInfo.pickUpAddress =
          (dataSnapshot.snapshot.value! as Map)["pickUpAddress"];

      double dropOffLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["latitude"]);
      double dropOffLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["longitude"]);

      tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);

      tripDetailsInfo.dropOffAddress =
          (dataSnapshot.snapshot.value! as Map)["dropOffAddress"];

      tripDetailsInfo.userName =
          (dataSnapshot.snapshot.value! as Map)["userName"];
      tripDetailsInfo.userPhone =
          (dataSnapshot.snapshot.value! as Map)["userPhone"];

      tripDetailsInfo.tripID = tripID;

      showDialog(
          context: context,
          builder: (BuildContext context) =>
              NotificationDialog(tripDetailsInfo: tripDetailsInfo));
    });
  }
}