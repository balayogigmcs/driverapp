import 'package:cccd/authentication/login_screen.dart';
import 'package:cccd/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late Future<FirebaseApp> _initialization;
  bool _isLogoVisible = false;
  bool _isTextVisible = false;
  String _displayedText = "";
  final String _fullText = "Connective Care";
  int _currentIndex = 0;
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _initialization = Firebase.initializeApp();

    _logoController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _startAnimations();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isLogoVisible = true;
      });

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isTextVisible = true;
        });

        Timer.periodic(Duration(milliseconds: 150), (timer) {
          if (_currentIndex < _fullText.length) {
            setState(() {
              _displayedText += _fullText[_currentIndex];
              _currentIndex++;
            });
          } else {
            timer.cancel();
            // Navigate to the main screen after the animation
            Future.delayed(Duration(seconds: 1), () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => FirebaseAuth.instance.currentUser == null
                      ? LoginScreen()
                      : Dashboard(),
                ),
              );
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text('Error initializing Firebase'),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: MediaQuery.of(context).size.width * 0.5 - 100,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(
                      parent: _logoController,
                      curve: Curves.easeInOut,
                    )),
                    child: AnimatedOpacity(
                      opacity: _isLogoVisible ? 1.0 : 0.0,
                      duration: Duration(seconds: 2),
                      child: Image.asset('assets/images/logo.png', width: 200),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.5 + 20,
                  left: MediaQuery.of(context).size.width * 0.5 - 160,
                  child: AnimatedOpacity(
                    opacity: _isTextVisible ? 1.0 : 0.0,
                    duration: Duration(seconds: 2),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        _displayedText,
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(5.0, 5.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}


// import 'package:cccd/authentication/login_screen.dart';
// import 'package:cccd/pages/dashboard.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   bool _isLogoVisible = false;
//   bool _isTextVisible = false;
//   String _displayedText = "";
//   final String _fullText = "Connective Care";
//   int _currentIndex = 0;
//   late AnimationController _logoController;

//   @override
//   void initState() {
//     super.initState();
//     _logoController = AnimationController(
//       duration: Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true); // Logo scale animation

//     _startAnimations();
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     super.dispose();
//   }

//   void _startAnimations() {
//     Future.delayed(Duration(milliseconds: 500), () {
//       setState(() {
//         _isLogoVisible = true;
//       });

//       Future.delayed(Duration(seconds: 1), () {
//         setState(() {
//           _isTextVisible = true;
//         });

//         Timer.periodic(Duration(milliseconds: 150), (timer) {
//           if (_currentIndex < _fullText.length) {
//             setState(() {
//               _displayedText += _fullText[_currentIndex];
//               _currentIndex++;
//             });
//           } else {
//             timer.cancel();
//             // Navigate to the main screen after the animation
//             Future.delayed(Duration(seconds: 1), () {
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                   builder: (context) => FirebaseAuth.instance.currentUser == null
//                       ? LoginScreen()
//                       : Dashboard(),
//                 ),
//               );
//             });
//           }
//         });
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Set background color to white
//       body: Stack(
//         children: [
//           Positioned(
//             top: MediaQuery.of(context).size.height * 0.2, // Position logo between top and center
//             left: MediaQuery.of(context).size.width * 0.5 - 100, // Center horizontally
//             child: ScaleTransition(
//               scale: Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(
//                 parent: _logoController,
//                 curve: Curves.easeInOut,
//               )),
//               child: AnimatedOpacity(
//                 opacity: _isLogoVisible ? 1.0 : 0.0,
//                 duration: Duration(seconds: 2), // Logo fade-in duration
//                 child: Image.asset('assets/images/logo.png', width: 200), // Replace with your logo path
//               ),
//             ),
//           ),
//           Positioned(
//             top: MediaQuery.of(context).size.height * 0.5 + 20, // Position text below the logo
//             left: MediaQuery.of(context).size.width * 0.5 - 160, // Center horizontally
//             child: AnimatedOpacity(
//               opacity: _isTextVisible ? 1.0 : 0.0,
//               duration: Duration(seconds: 2), // Text fade-in duration
//               child: ShaderMask(
//                 shaderCallback: (bounds) => LinearGradient(
//                   colors: [Colors.purple, Colors.blue],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ).createShader(bounds),
//                 child: Text(
//                   _displayedText,
//                   style: TextStyle(
//                     fontSize: 44,
//                     fontWeight: FontWeight.bold,
//                     shadows: [
//                       Shadow(
//                         blurRadius: 10.0,
//                         color: Colors.black.withOpacity(0.5),
//                         offset: Offset(5.0, 5.0),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
