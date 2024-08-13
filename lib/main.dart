import 'package:cccd/animation/splashscreen.dart';
import 'package:cccd/provider/driver_status_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Firebase initialization for web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAtedTYdh2b484usx8sIa1JELhOY7vOIJM",
        appId: "1:185150577423:web:1609a142ee2dd704357c7a",
        messagingSenderId: "185150577423",
        projectId: "cccc-4b8a5",
        authDomain: "cccc-4b8a5.firebaseapp.com",
        databaseURL: "https://cccc-4b8a5-default-rtdb.firebaseio.com",
        storageBucket: "cccc-4b8a5.appspot.com",
        measurementId: "G-XB7PHQ9P2Q",
      ),
    );

    // Request notification permission for web
    await requestNotificationPermissionWeb();

    // Request location permission for web (Geolocation API)
    await requestLocationPermissionWeb();

  } else {
    // Firebase initialization for mobile (iOS/Android)
    await Firebase.initializeApp();

    // Check and request location permission if needed (only on mobile platforms)
    try {
      var locationStatus = await Permission.locationWhenInUse.status;
      if (locationStatus.isDenied) {
        await Permission.locationWhenInUse.request();
      }
    } catch (e) {
      print('Error requesting location permission: $e');
    }

    // Check and request notification permission if needed (only on mobile platforms)
    try {
      var notificationStatus = await Permission.notification.status;
      if (notificationStatus.isDenied) {
        await Permission.notification.request();
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }

  runApp(const MyApp());
}

// Function to request notification permission on the web
Future<void> requestNotificationPermissionWeb() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
}

// Function to request location permission on the web using the Geolocator package
Future<void> requestLocationPermissionWeb() async {
  // Check the current permission status
  LocationPermission permission = await Geolocator.checkPermission();

  // If permission is denied, request permission
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Handle the case when the user denies the permission
      print('Location permission denied');
      return;
    }
  }

  // If permission is permanently denied, you can guide the user to the settings
  if (permission == LocationPermission.deniedForever) {
    // Permissions are permanently denied, handle appropriately
    print('Location permissions are permanently denied');
    return;
  }

  // If permission is granted, you can proceed with getting the location
  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    print('Location permission granted');
    // You can now access the user's location
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverStatusProvider(),
      child: MaterialApp(
        title: 'Drivers App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue),
            headlineMedium: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue),
            bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
            bodyMedium: TextStyle(fontSize: 14.0, color: Colors.blue),
            labelLarge: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue),
          ),
        ),
        // darkTheme: ThemeData.dark().copyWith(
        //   scaffoldBackgroundColor: Colors.black,
        //   textTheme: const TextTheme(
        //     headlineLarge: TextStyle(
        //         fontSize: 32.0,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.white),
        //     bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
        //     bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
        //     labelLarge: TextStyle(
        //         fontSize: 14.0,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.white),
        //   ),
        // ),
        home: SplashScreen(), // Use SplashScreen as the initial screen
      ),
    );
  }
}




// import 'package:cccd/animation/animation.dart';
// import 'package:cccd/authentication/login_screen.dart';
// import 'package:cccd/pages/dashboard.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   // Check and request location permission if needed
//   var locationStatus = await Permission.locationWhenInUse.status;
//   if (locationStatus.isDenied) {
//     await Permission.locationWhenInUse.request();
//   }

//   // Check and request notification permission if needed
//   var notificationStatus = await Permission.notification.status;
//   if (notificationStatus.isDenied) {
//     await Permission.notification.request();
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Drivers App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light().copyWith(
//         scaffoldBackgroundColor: Colors.white,
//         textTheme: const TextTheme(
//           headlineLarge: TextStyle(
//               fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.blue),
//           headlineMedium: TextStyle(
//               fontSize: 26.0, fontWeight: FontWeight.bold, color: Colors.blue),
//           bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
//           bodyMedium: TextStyle(fontSize: 14.0, color: Colors.blue),
//           labelLarge: TextStyle(
//               fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.blue),
//         ),
//       ),
//       darkTheme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: Colors.black,
//         textTheme: const TextTheme(
//           headlineLarge: TextStyle(
//               fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
//           bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
//           bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
//           labelLarge: TextStyle(
//               fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//       ),
//       home: FutureBuilder(
//         // Check if FirebaseAuth initState initialized and currentUser is not null
//         future: Firebase.initializeApp(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Display loading indicator while Firebase initializes
//             return CircularProgressIndicator();
//           } else {
//             // Firebase initialized, determine initial screen
//             if (FirebaseAuth.instance.currentUser == null) {
//               return LoginScreen();
//             } else {
//               return Dashboard();
//             }
//           }
//         },
//       ),
//     );
//   }
// }
