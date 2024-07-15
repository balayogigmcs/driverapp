import 'package:cccd/authentication/login_screen.dart';
import 'package:cccd/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check and request location permission if needed
  var locationStatus = await Permission.locationWhenInUse.status;
  if (locationStatus.isDenied) {
    await Permission.locationWhenInUse.request();
  }

  // Check and request notification permission if needed
  var notificationStatus = await Permission.notification.status;
  if (notificationStatus.isDenied) {
    await Permission.notification.request();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: FutureBuilder(
        // Check if FirebaseAuth is initialized and currentUser is not null
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display loading indicator while Firebase initializes
            return CircularProgressIndicator();
          } else {
            // Firebase initialized, determine initial screen
            if (FirebaseAuth.instance.currentUser == null) {
              return LoginScreen();
            } else {
              return HomePage();
            }
          }
        },
      ),
    );
  }
}
