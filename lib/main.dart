import 'package:cccd/animation/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      title: 'Drivers App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.blue),
          headlineMedium: TextStyle(
              fontSize: 26.0, fontWeight: FontWeight.bold, color: Colors.blue),
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.blue),
          labelLarge: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
          labelLarge: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      home: SplashScreen(), // Use AnimationScreen as the initial screen
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
