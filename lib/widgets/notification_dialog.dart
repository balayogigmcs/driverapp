import 'dart:async';
import 'package:cccd/global/global_var.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cccd/methods/common_methods.dart';
import 'package:cccd/models/trip_details.dart';
import 'package:cccd/pages/new_trip_page.dart';
import 'package:cccd/widgets/loading_dialog.dart';
// import 'package:synchronized/synchronized.dart';

class NotificationDialog extends StatefulWidget {
  final TripDetails? tripDetailsInfo;

  NotificationDialog({super.key, this.tripDetailsInfo});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  String tripRequestStatus = "";
  CommonMethods cMethods = CommonMethods();
  // final Lock _firebaseLock = Lock();

  @override
  void initState() {
    super.initState();
    cancelNotificationRequestAfter20Sec(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Timer? _timer;

  void cancelNotificationRequestAfter20Sec(BuildContext context) {
    const oneTickPerSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneTickPerSecond, (timer) {
      if (!mounted) return;

      driverTripRequestTimeout -= 1;
      if (tripRequestStatus == 'accepted' || driverTripRequestTimeout <= 0) {
        timer.cancel();
        driverTripRequestTimeout = 20; // Reset timeout for potential reuse
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  checkAvailablityOfTripRequest(BuildContext context) async {
  print("entered into checkAvailablityOfTripRequest");

  print("before showDialog");
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Please wait...'));

  print("after showDialog");


  DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
      .ref()
      .child("drivers")
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child("newTripStatus");

      Navigator.pop(context);

  print("after creating driverTripStatusRef");

  // Using a transaction to safely check and update the trip status
  driverTripStatusRef.runTransaction((mutableData) {
    if (mutableData == widget.tripDetailsInfo!.tripID) {
      mutableData = "accepted";
      return Transaction.success(mutableData);
    } else {
      // Abort the transaction
      return Transaction.abort();
    }
  }).then((transactionResult) {
    if (transactionResult.committed) {
      print("Trip status set to accepted.");
      cMethods.turnOffLocationUpdatesForHomepage();
      Navigator.of(context).pop(); // Close the loading dialog
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  NewTripPage(newTripDetailInfo: widget.tripDetailsInfo)));
    } else {
      print("Transaction not committed. Status might be 'cancelled' or 'timeout'");
      cMethods.displaySnackbar("Failed to accept trip request", context);
    }
  }).catchError((error) {
    print("Transaction failed: $error");
    Navigator.of(context).pop(); // Close the loading dialog
    cMethods.displaySnackbar("An error occurred", context);
  });
}


  // checkAvailablityOfTripRequest(BuildContext context) async {
  //   print("entered into checkAvailablityOfTripRequest");

  //   print("before showDialog");
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) =>
  //           LoadingDialog(messageText: 'Please wait...'));

  //   print("after showDialog");

  //   DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
  //       .ref()
  //       .child("drivers")
  //       .child(FirebaseAuth.instance.currentUser!.uid)
  //       .child("newTripStatus");

  //   print("after creating driverTripStatusRef");

  //   // try {
  //   driverTripStatusRef.once().then((snap) async {
  //     Navigator.pop(context);
  //     Navigator.pop(context);
  //     String newTripStatusValue = "";

  //     if (snap.snapshot.value != null) {
  //       newTripStatusValue = snap.snapshot.value.toString();
  //       print(newTripStatusValue);
  //       print(widget.tripDetailsInfo!.tripID);
  //     } else {
  //       cMethods.displaySnackbar("Trip Request Not found", context);
  //     }

  //     if (newTripStatusValue == widget.tripDetailsInfo!.tripID) {
  //       print("before set to accepted inside function");
  //       // await Future.delayed(Duration(seconds: 2));
  //       // await _setTripAccepted(driverTripStatusRef);
  //       await driverTripStatusRef.set("accepted");
  //       print("Trip status set to accepted.");
  //       print("before turnOffLocationUpdatesForHomepage");
  //       cMethods.turnOffLocationUpdatesForHomepage();
  //       print("after turnOffLocationUpdatesForHomepage");

  //       print("entered into NewTripPage");
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (BuildContext context) =>
  //                   NewTripPage(newTripDetailInfo: widget.tripDetailsInfo)));
  //     } else if (newTripStatusValue == "cancelled") {
  //       cMethods.displaySnackbar(
  //           "Trip request has been Cancelled by User", context);
  //     } else if (newTripStatusValue == "timeout") {
  //       cMethods.displaySnackbar("Trip request Timeout", context);
  //     } else {
  //       cMethods.displaySnackbar("Trip request removed, Not Found", context);
  //     }
  //   });
  //   // } catch (e, stackTrace) {
  //   //   print("Error is : $e");
  //   //   print("StackTrace ; $stackTrace");
  //   //   cMethods.displaySnackbar("An error occurred", context);
  //   // }
  // }

  // Future<void> _setTripAccepted(DatabaseReference ref) async {
  //   await _firebaseLock.synchronized(() async {
  //     try {
  //       print("Setting trip status to accepted.");
  //       await ref.set("accepted");
  //       print("Trip status set to accepted.");
  //       if (mounted) {
  //         Navigator.pop(context);
  //       } else {
  //         print("not mounted");
  //       }
  //       // Proceed with other operations after setting status
  //     } catch (e) {
  //       print('Error setting trip status: $e');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      child: Container(
          margin: const EdgeInsets.all(5),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                "assets/images/uberexec.png",
                width: 140,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text("NEW TRIP REQUEST",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(
                height: 20,
              ),
              Divider(
                thickness: 1,
                height: 1,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/images/initial.png",
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Text(
                            widget.tripDetailsInfo!.pickUpAddress.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/images/final.png",
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Text(
                            widget.tripDetailsInfo!.dropOffAddress.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Divider(
                thickness: 1,
                height: 1,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // audioPlayer.stop();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink),
                            child: Text(
                              "DECLINE",
                              style: TextStyle(color: Colors.white),
                            ))),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              // audioPlayer.stop();
                              setState(() {
                                tripRequestStatus = "accepted";
                              });
                              checkAvailablityOfTripRequest(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: Text(
                              "ACCEPT",
                              style: TextStyle(color: Colors.white),
                            ))),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          )),
    );
  }

  void setTripAccepted() {
    runZonedGuarded(() async {
      DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("newTripStatus");
      await driverTripStatusRef.set("accepted");
    }, (e, stack) {
      print('Failed to set trip accepted: $e');
    });
  }
}




// import 'dart:async';
// import 'package:cccd/global/global_var.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:cccd/methods/common_methods.dart';
// import 'package:cccd/models/trip_details.dart';
// import 'package:cccd/pages/new_trip_page.dart';
// import 'package:cccd/widgets/loading_dialog.dart';

// class NotificationDialog extends StatefulWidget {
//   final TripDetails? tripDetailsInfo;
//   final List<Map<dynamic, dynamic>> mobilityAidDataList;

//   NotificationDialog({super.key, this.tripDetailsInfo, required this.mobilityAidDataList});

//   @override
//   State<NotificationDialog> createState() => _NotificationDialogState();
// }

// class _NotificationDialogState extends State<NotificationDialog> {
//   String tripRequestStatus = "";
//   CommonMethods cMethods = CommonMethods();
//   String? selectedMobilityAid;

//   cancelNotificationRequestAfter20Sec(BuildContext context) {
//     const oneTickPerSecond = Duration(seconds: 1);

//     var timerCountDown = Timer.periodic(oneTickPerSecond, (timer) {
//       driverTripRequestTimeout = driverTripRequestTimeout - 1;

//       if (tripRequestStatus == 'accepted') {
//         timer.cancel();
//         driverTripRequestTimeout = 20;
//       }

//       if (driverTripRequestTimeout == 0) {
//         Navigator.pop(context);
//         timer.cancel();
//         driverTripRequestTimeout = 20;
//       }
//     });
//   }

//   checkAvailablityOfTripRequest(BuildContext context) async {
//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) =>
//             LoadingDialog(messageText: 'Please wait ....'));

//     DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
//         .ref()
//         .child("drivers")
//         .child(FirebaseAuth.instance.currentUser!.uid)
//         .child("newTripStatus");

//     await driverTripStatusRef.once().then((snap) {
//       Navigator.pop(context);
//       Navigator.pop(context);

//       String newTripStatusValue = "";
//       if (snap.snapshot.value != null) {
//         newTripStatusValue = snap.snapshot.value.toString();
//       } else {
//         cMethods.displaySnackbar("Trip Request Not found", context);
//       }

//       if (newTripStatusValue == widget.tripDetailsInfo!.tripID) {
//         driverTripStatusRef.set("accepted");

//         // disable homepage location updates

//         cMethods.turnOffLocationUpdatesForHomepage();
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (BuildContext context) =>
//                     NewTripPage(newTripDetailInfo: widget.tripDetailsInfo)));
//       } else if (newTripStatusValue == "cancelled") {
//         cMethods.displaySnackbar(
//             "Trip request has been Cancelled by User", context);
//       } else if (newTripStatusValue == "timeout") {
//         cMethods.displaySnackbar("Trip request Timeout", context);
//       } else {
//         cMethods.displaySnackbar("Trip request removed , Not Found", context);
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     cancelNotificationRequestAfter20Sec(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       backgroundColor: Colors.white,
//       child: Container(
//           margin: const EdgeInsets.all(5),
//           width: double.infinity,
//           decoration: BoxDecoration(
//               color: Colors.white, borderRadius: BorderRadius.circular(5)),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(
//                 height: 30,
//               ),
//               Image.asset(
//                 "assets/images/uberexec.png",
//                 width: 140,
//               ),
//               const SizedBox(
//                 height: 16,
//               ),
//               const Text("NEW TRIP REQUEST",
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black)),
//               const SizedBox(
//                 height: 20,
//               ),
//               Divider(
//                 thickness: 1,
//                 height: 1,
//                 color: Colors.black,
//               ),
//               const SizedBox(
//                 height: 10,
//               ),

//               // PICKUP AND DROPOFF
//               Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     // PICK UP
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Image.asset(
//                           "assets/images/initial.png",
//                           width: 16,
//                           height: 16,
//                         ),
//                         const SizedBox(
//                           width: 18,
//                         ),
//                         Expanded(
//                           child: Text(
//                             widget.tripDetailsInfo!.pickUpAddress.toString(),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 2,
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.black,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),

//                     const SizedBox(
//                       height: 15,
//                     ),
//                     // DROPOFF
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Image.asset(
//                           "assets/images/final.png",
//                           width: 16,
//                           height: 16,
//                         ),
//                         const SizedBox(
//                           width: 18,
//                         ),
//                         Expanded(
//                           child: Text(
//                             widget.tripDetailsInfo!.dropOffAddress.toString(),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 2,
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.black,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Divider(
//                 thickness: 1,
//                 height: 1,
//                 color: Colors.black,
//               ),
//               const SizedBox(
//                 height: 10,
//               ),

//               // MOBILITY AID DROPDOWN
//               Padding(
//                 padding: EdgeInsets.all(16),
//                 child: DropdownButtonFormField<String>(
//                   value: selectedMobilityAid,
//                   items: widget.mobilityAidDataList.map((mobilityAid) {
//                     return DropdownMenuItem<String>(
//                       value: mobilityAid['mobilityAidType'].toString(),
//                       child: Text(mobilityAid['mobilityAidType'].toString(),style: TextStyle(color: Colors.blue),),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedMobilityAid = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Select Mobility Aid',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),

//               // ACCEPT AND DECLINE BUTTON
//               Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                         child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                               audioPlayer.stop();
//                             },
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.pink),
//                             child: Text(
//                               "DECLINE",
//                               style: TextStyle(color: Colors.white),
//                             ))),
//                     const SizedBox(
//                       width: 10,
//                     ),
//                     Expanded(
//                         child: ElevatedButton(
//                             onPressed: () {
//                               audioPlayer.stop();
//                               setState(() {
//                                 tripRequestStatus = "accepted";
//                               });

//                               checkAvailablityOfTripRequest(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green),
//                             child: Text(
//                               "ACCEPT",
//                               style: TextStyle(color: Colors.white),
//                             ))),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               )
//             ],
//           )),
//     );
//   }
// }

// import 'dart:async';
// import 'package:cccd/global/global_var.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:cccd/methods/common_methods.dart';
// import 'package:cccd/models/trip_details.dart';
// import 'package:cccd/pages/new_trip_page.dart';
// import 'package:cccd/widgets/loading_dialog.dart';

// class NotificationDialog extends StatefulWidget {
//   final TripDetails? tripDetailsInfo;
//   // final List<Map<dynamic, dynamic>> mobilityAidDataList;

//   // NotificationDialog({super.key, this.tripDetailsInfo, required this.mobilityAidDataList});
//   NotificationDialog({super.key, this.tripDetailsInfo});

//   @override
//   State<NotificationDialog> createState() => _NotificationDialogState();
// }

// class _NotificationDialogState extends State<NotificationDialog> {
//   String tripRequestStatus = "";
//   CommonMethods cMethods = CommonMethods();
//   String? selectedMobilityAid;
//   List<Map<dynamic, dynamic>> displayedMobilityAidDataList = [];

//   @override
//   void initState() {
//     super.initState();
//     print("initState in NotificationDialog is called");
//     // updateMobilityAidData(widget.mobilityAidDataList);
//     print("before cancelNotificationRequestAfter20Sec called");
//     cancelNotificationRequestAfter20Sec(context);
//     print("after cancelNotificationRequestAfter20Sec called");
//   }

//   // void updateMobilityAidData(List<Map<dynamic, dynamic>> newData) {
//   //   setState(() {
//   //     displayedMobilityAidDataList = newData;
//   //   });
//   // }

//   cancelNotificationRequestAfter20Sec(BuildContext context) {
//     print("entered into cancelNotificationRequestAfter20Sec");
//     const oneTickPerSecond = Duration(seconds: 1);

//     var timerCountDown = Timer.periodic(oneTickPerSecond, (timer) {
  

//       driverTripRequestTimeout = driverTripRequestTimeout - 1;

//       if (tripRequestStatus == 'accepted') {
//         timer.cancel();
//         driverTripRequestTimeout = 20;
//       }

//       if (driverTripRequestTimeout == 0) {
//           Navigator.pop(context);
//         timer.cancel();
//         driverTripRequestTimeout = 20;
//       }
//     });
//     print("cancelNotificationRequestAfter20Sec exited");
//   }

//   checkAvailablityOfTripRequest(BuildContext context) async {
//     print("entered into checkAvailablityOfTripRequest");

//     print("before showDialog");
//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) =>
//             LoadingDialog(messageText: 'Please wait ....'));

//     print("after showDialog");

//     DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
//         .ref()
//         .child("drivers")
//         .child(FirebaseAuth.instance.currentUser!.uid)
//         .child("newTripStatus");
//     print("after creating driverTripStatusRef");

//     await driverTripStatusRef.once().then((snap) {
//       Navigator.pop(context);
//       Navigator.pop(context);
//       print("after poping context");

//       String newTripStatusValue = "";
//       if (snap.snapshot.value != null) {
//         newTripStatusValue = snap.snapshot.value.toString();
//         print(newTripStatusValue);
//       } else {
//         cMethods.displaySnackbar("Trip Request Not found", context);
//       }
//       print("before set to accepted");
//       if (newTripStatusValue == widget.tripDetailsInfo!.tripID) {
//         print("before set to accepted inside function");
//         driverTripStatusRef.set("accepted");
//         // disable homepage location updates
//         print("before turnOffLocationUpdatesForHomepage");
//         cMethods.turnOffLocationUpdatesForHomepage();
//         print("after turnOffLocationUpdatesForHomepage");
//         print("entered into NewTripPage");
//         // Navigator.push(
//         //     context,
//         //     MaterialPageRoute(
//         //         builder: (BuildContext context) =>
//         //             NewTripPage(newTripDetailInfo: widget.tripDetailsInfo)));
//       } else if (newTripStatusValue == "cancelled") {
//         cMethods.displaySnackbar(
//             "Trip request has been Cancelled by User", context);
//       } else if (newTripStatusValue == "timeout") {
//         cMethods.displaySnackbar("Trip request Timeout", context);
//       } else {
//         cMethods.displaySnackbar("Trip request removed, Not Found", context);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       backgroundColor: Colors.white,
//       child: Container(
//           margin: const EdgeInsets.all(5),
//           width: double.infinity,
//           decoration: BoxDecoration(
//               color: Colors.white, borderRadius: BorderRadius.circular(5)),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(
//                 height: 30,
//               ),
//               Image.asset(
//                 "assets/images/uberexec.png",
//                 width: 140,
//               ),
//               const SizedBox(
//                 height: 16,
//               ),
//               const Text("NEW TRIP REQUEST",
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black)),
//               const SizedBox(
//                 height: 20,
//               ),
//               Divider(
//                 thickness: 1,
//                 height: 1,
//                 color: Colors.black,
//               ),
//               const SizedBox(
//                 height: 10,
//               ),

//               // PICKUP AND DROPOFF
//               Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     // PICK UP
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Image.asset(
//                           "assets/images/initial.png",
//                           width: 16,
//                           height: 16,
//                         ),
//                         const SizedBox(
//                           width: 18,
//                         ),
//                         Expanded(
//                           child: Text(
//                             widget.tripDetailsInfo?.pickUpAddress ?? 'N/A',
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 2,
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.black,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),

//                     const SizedBox(
//                       height: 15,
//                     ),
//                     // DROPOFF
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Image.asset(
//                           "assets/images/final.png",
//                           width: 16,
//                           height: 16,
//                         ),
//                         const SizedBox(
//                           width: 18,
//                         ),
//                         Expanded(
//                           child: Text(
//                             widget.tripDetailsInfo?.dropOffAddress ?? 'N/A',
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 2,
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.black,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Divider(
//                 thickness: 1,
//                 height: 1,
//                 color: Colors.black,
//               ),
//               const SizedBox(
//                 height: 10,
//               ),

//               // MOBILITY AID DROPDOWN
//               Padding(
//                 padding: EdgeInsets.all(16),
//                 child: DropdownButtonFormField<String>(
//                   value: selectedMobilityAid,
//                   items: displayedMobilityAidDataList.map((mobilityAid) {
//                     return DropdownMenuItem<String>(
//                       value: mobilityAid['mobilityAidType'].toString(),
//                       child: Text(mobilityAid['mobilityAidType'].toString(),
//                           style: TextStyle(color: Colors.blue)),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedMobilityAid = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Select Mobility Aid',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),

//               // ACCEPT AND DECLINE BUTTON
//               Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                         child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                               audioPlayer.stop();
//                             },
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.pink),
//                             child: Text(
//                               "DECLINE",
//                               style: TextStyle(color: Colors.white),
//                             ))),
//                     const SizedBox(
//                       width: 10,
//                     ),
//                     Expanded(
//                         child: ElevatedButton(
//                             onPressed: () {
//                               audioPlayer.stop();
//                               setState(() {
//                                 tripRequestStatus = "accepted";
//                               });
//                               print(
//                                   "before checkAvailablityOfTripRequest is called");
//                               checkAvailablityOfTripRequest(context);
//                               print(
//                                   "after checkAvailablityOfTripRequest is called");
//                             },
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green),
//                             child: Text(
//                               "ACCEPT",
//                               style: TextStyle(color: Colors.white),
//                             ))),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               )
//             ],
//           )),
//     );
//   }
// }
