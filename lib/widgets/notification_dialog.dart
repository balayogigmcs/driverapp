import 'dart:async';
import 'package:cccd/global/global_var.dart';
import 'package:cccd/models/trip_details.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatefulWidget {
  TripDetails? tripDetailsInfo;

  NotificationDialog({super.key, this.tripDetailsInfo});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  String tripRequestStatus = "";

  cancelNotificationRequestAfter20Sec(BuildContext context) {
    const oneTickPerSecond = Duration(seconds: 1);

    var timerCountDown = Timer.periodic(oneTickPerSecond, (timer) {
      driverTripRequestTimeout = driverTripRequestTimeout - 1;

      if (tripRequestStatus == 'accepted') {
        timer.cancel();
        driverTripRequestTimeout = 20;
      }

      if (driverTripRequestTimeout == 0) {
        Navigator.pop(context);
        timer.cancel();
        driverTripRequestTimeout = 20;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    cancelNotificationRequestAfter20Sec(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black87,
      child: Container(
          margin: const EdgeInsets.all(5),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(5)),
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
                      color: Colors.grey)),
              const SizedBox(
                height: 20,
              ),
              Divider(
                thickness: 1,
                height: 1,
                color: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),

              //PICKUP AND DROPOFF
              Padding(
                padding: EdgeInsets.all(16),
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
                          widget.tripDetailsInfo!.pickUpAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ))
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
                            widget.tripDetailsInfo!.dropOffAddress.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
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
                color: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),

              // ACCEPT AND DECLINE BUTTON
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
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
                              setState(() {
                                tripRequestStatus = "accepted";
                              });
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
}
