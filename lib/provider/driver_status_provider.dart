import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class DriverStatusProvider extends ChangeNotifier {
  bool _isOnline = false;

  bool get isOnline => _isOnline;

  Future<void> toggleOnlineStatus() async {
    _isOnline = !_isOnline;
    notifyListeners();
    await updateDriverStatusInFirebase();
  }

  Future<void> updateDriverStatusInFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(user.uid)
          .update({'status': _isOnline ? 'online' : 'offline'});
    }
    print("updateDriverStatusInFirebase");
  }

  Future<void> setInitialStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(user.uid)
          .once();
      final DataSnapshot snapshot = event.snapshot;
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && data['status'] != null) {
        _isOnline = data['status'] == 'online';
      }
      notifyListeners();
    }
  }

  Future<void> setOnline() async {
    _isOnline = true;
    notifyListeners();
    await updateDriverStatusInFirebase();
  }

  Future<void> setOffline() async {
    _isOnline = false;
    notifyListeners();
    await updateDriverStatusInFirebase();
  }
}
