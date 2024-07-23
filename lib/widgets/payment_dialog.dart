import 'package:cccd/methods/common_methods.dart';
import 'package:cccd/pages/dashboard.dart';

import 'package:flutter/material.dart';
// import 'package:restart_app/restart_app.dart';

class PaymentDialog extends StatefulWidget {
  String? fareAmount;
  PaymentDialog({super.key, required this.fareAmount});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  CommonMethods cmethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.black54,
        child: Container(
          margin: EdgeInsets.all(4),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 21,
              ),
              Text(
                "COLLECT CASH",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 21,
              ),
              const Divider(
                thickness: 1,
                height: 1.5,
                color: Colors.white70,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "\$ ${widget.fareAmount}!",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "This is the fare amount (\$ ${widget.fareAmount}!) to be charged from the patient", // Updated text with correct syntax
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 31,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    cmethods.turnOnLocationUpdatesForHomepage();

                    //Restart.restartApp();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Dashboard()));
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('COLLECT CASH')),
              const SizedBox(
                height: 41,
              ),
            ],
          ),
        ));
  }
}
