import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  void startListeningForNewNotifications() {
    // Handle initial message when the app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((message) {
      _handleMessage(message);
    });

    // Handle incoming messages when the app is in the background and opened
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage? message) {
    if (message != null) {
      String? tripID = message.data["tripID"];
      if (tripID != null) {
        // Process tripID, e.g., navigate to trip details page
        print("Received trip ID: $tripID");
      }
    }
  }
}
