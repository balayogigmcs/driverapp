import 'package:cccd/pages/trips_history_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  String currentDriverTotalTripsCompleted = "";

  getCurrentDriverTotalNumberOfTripsCompleted() async {
    DatabaseReference tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequests");

    await tripRequestRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        Map<dynamic, dynamic> allTripsMap = snap.snapshot.value as Map;

        int allTripsLength = allTripsMap.length;

        List<String> tripsCompletedByCurrentDriver = [];

        allTripsMap.forEach((key, value) {
          if (value["status"] != null) {
            if (value["status"] == "ended") {
              if (value["driverID"] == FirebaseAuth.instance.currentUser!.uid) {
                tripsCompletedByCurrentDriver.add(key);
              }
            }
          }

          setState(() {
            currentDriverTotalTripsCompleted =
                tripsCompletedByCurrentDriver.length.toString();
          });
        });
      }
    });
  }

  void initState() {
    super.initState();
    getCurrentDriverTotalNumberOfTripsCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              color: Colors.indigo,
              width: 300,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/totaltrips.png",
                      width: 120,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Total Trips",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      currentDriverTotalTripsCompleted,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),
          // check trip history
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => TripsHistoryPage()));
            },
            child: Center(
              child: Container(
                color: Colors.indigo,
                width: 300,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/tripscompleted.png",
                        width: 120,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Check Trip History",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        currentDriverTotalTripsCompleted,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
