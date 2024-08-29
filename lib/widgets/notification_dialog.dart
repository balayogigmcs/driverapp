import 'dart:async';
import 'package:cccd/global/global_var.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cccd/methods/common_methods.dart';
import 'package:cccd/models/trip_details.dart';
import 'package:cccd/pages/new_trip_page.dart';
import 'package:cccd/widgets/loading_dialog.dart';

class NotificationDialog extends StatefulWidget {
  final TripDetails? tripDetailsInfo;
  final List<Map<dynamic, dynamic>> mobilityAidDataList;

  NotificationDialog({super.key, this.tripDetailsInfo, required this.mobilityAidDataList});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  String tripRequestStatus = "";
  CommonMethods cMethods = CommonMethods();
  String? selectedMobilityAid;
  List<Map<dynamic, dynamic>> displayedMobilityAidDataList = [];

  @override
  void initState() {
    super.initState();
    print("updateMobilityAidData(widget.mobilityAidDataList) called in initState");
    updateMobilityAidData(widget.mobilityAidDataList);
    cancelNotificationRequestAfter20Sec(context);
  }

  void updateMobilityAidData(List<Map<dynamic, dynamic>> newData) {
    setState(() {
      displayedMobilityAidDataList = newData;
    });
  }

  void cancelNotificationRequestAfter20Sec(BuildContext context) {
    const oneTickPerSecond = Duration(seconds: 1);

    Timer.periodic(oneTickPerSecond, (timer) {
      driverTripRequestTimeout = driverTripRequestTimeout - 1;

      if (tripRequestStatus == 'accepted') {
        timer.cancel();
        driverTripRequestTimeout = 20;
      }

      if (driverTripRequestTimeout == 0) {
        if (mounted) {
          Navigator.pop(context);
        }
        timer.cancel();
        driverTripRequestTimeout = 20;
      }
    });
  }

  void checkAvailablityOfTripRequest(BuildContext context) async {
    print("enter into checkAvailabilityOfTripRequest");
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: 'Please wait ....'));

    print("show Dialog");

    DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    print("DatabaseReference created: $driverTripStatusRef");

    try {
        await driverTripStatusRef.once().then((snap) {
            if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
            }

            String newTripStatusValue = "";
            if (snap.snapshot.value != null) {
                newTripStatusValue = snap.snapshot.value.toString();
                print("newTripStatusValue retrieved: $newTripStatusValue");
            } else {
                print("newTripStatusValue is Zero");
                cMethods.displaySnackbar("Trip Request Not found", context);
            }

            if (newTripStatusValue == widget.tripDetailsInfo!.tripID) {
                print("TripID matches: ${widget.tripDetailsInfo!.tripID}");
                driverTripStatusRef.set("accepted").then((_) {
                    print("Trip status set to accepted");
                }).catchError((error) {
                    print("Error setting trip status to accepted: $error");
                });

                // disable homepage location updates
                cMethods.turnOffLocationUpdatesForHomepage();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            NewTripPage(newTripDetailInfo: widget.tripDetailsInfo)));
            } else if (newTripStatusValue == "cancelled") {
                print("Trip request has been Cancelled by User");
                cMethods.displaySnackbar(
                    "Trip request has been Cancelled by User", context);
            } else if (newTripStatusValue == "timeout") {
                print("Trip request Timeout");
                cMethods.displaySnackbar("Trip request Timeout", context);
            } else {
                print("Trip request removed, Not Found");
                cMethods.displaySnackbar("Trip request removed, Not Found", context);
            }
        }).catchError((error) {
            print("Error retrieving trip status: $error");
        });
    } catch (e) {
        print("Exception in checkAvailablityOfTripRequest: $e");
    }
}
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
              const Divider(
                thickness: 1,
                height: 1,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),

              // PICKUP AND DROPOFF
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // PICK UP
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
                            widget.tripDetailsInfo?.pickUpAddress ?? 'N/A',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
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
                    // DROPOFF
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
                            widget.tripDetailsInfo?.dropOffAddress ?? 'N/A',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
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
              const Divider(
                thickness: 1,
                height: 1,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),

              // MOBILITY AID DROPDOWN
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: selectedMobilityAid,
                  items: displayedMobilityAidDataList
                      .map((mobilityAid) {
                        String mobilityAidType = mobilityAid['mobilityAidType'].toString();
                        return DropdownMenuItem<String>(
                          value: mobilityAidType,
                          child: Text(mobilityAidType, style: const TextStyle(color: Colors.blue)),
                        );
                      })
                      .toSet()
                      .toList(), // Ensure unique items
                  onChanged: (value) {
                    setState(() {
                      selectedMobilityAid = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Mobility Aid',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              // ACCEPT AND DECLINE BUTTON
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              audioPlayer.stop();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink),
                            child: const Text(
                              "DECLINE",
                              style: TextStyle(color: Colors.white),
                            ))),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              audioPlayer.stop();
                              setState(() {
                                tripRequestStatus = "accepted";
                              });

                              checkAvailablityOfTripRequest(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text(
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
}
