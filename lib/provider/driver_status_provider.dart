// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';

// class DriverStatusProvider with ChangeNotifier {
//   bool _isOnline = false;
//   final FirebaseDatabase _database = FirebaseDatabase.instance;
//   final String _uid = FirebaseAuth.instance.currentUser!.uid;

//   DriverStatusProvider() {
//     _listenToStatusChanges();
//   }

//   bool get isOnline => _isOnline;

//   void _listenToStatusChanges() {
//     _database
//         .ref()
//         .child('drivers')
//         .child(_uid)
//         .child('driverStatus')
//         .onValue
//         .listen((event) {
//       final snapshot = event.snapshot;
//       if (snapshot.exists && snapshot.value == 'online') {
//         _isOnline = true;
//       } else {
//         _isOnline = false;
//       }
//       notifyListeners();
//     });
//   }

//   Future<void> setOnlineStatus(bool online) async {
//     await _database
//         .ref()
//         .child('drivers')
//         .child(_uid)
//         .child('driverStatus')
//         .set(online ? 'online' : 'offline');
//   }
// }


import 'package:flutter/foundation.dart';

class DriverState with ChangeNotifier {
  bool _isDriverAvailable = false;

  bool get isDriverAvailable => _isDriverAvailable;

  void setDriverStatus(bool status) {
    _isDriverAvailable = status;
    notifyListeners();
  }
}

