import 'package:cccd/methods/common_methods.dart';
import 'package:cccd/pages/dashboard.dart';
import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final String? fareAmount;
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
      backgroundColor: Colors.white,
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
            const Text(
              "COLLECT CASH",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 21,
            ),
            const Divider(
              thickness: 1,
              height: 1.5,
              color: Colors.white,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "\$ ${widget.fareAmount}!",
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "This is the fare amount (\$ ${widget.fareAmount}) to be charged from the patient", // Updated text with correct syntax
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(
              height: 31,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);

                if (CommonMethods().turnOnLocationUpdatesForHomepage != null) {
                  CommonMethods().turnOnLocationUpdatesForHomepage();
                } else {
                  print('Error: turnOnLocationUpdatesForHomepage is null');
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Dashboard(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('COLLECT AMOUNT'),
            ),
            const SizedBox(
              height: 41,
            ),
          ],
        ),
      ),
    );
  }
}
