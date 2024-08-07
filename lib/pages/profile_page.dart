import 'package:cccd/authentication/login_screen.dart';
import 'package:cccd/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController carTextEditingController = TextEditingController();

  setDriverInfo() {
    setState(() {
      nameTextEditingController.text = driverName;
      phoneTextEditingController.text = driverPhone;
      emailTextEditingController.text =
          FirebaseAuth.instance.currentUser!.email.toString();
      carTextEditingController.text =
          carNumber + " - " + carModel + " - " + carColor;
    });
  }

  void initState() {
    super.initState();
    setDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,
        body: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //image
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  image: DecorationImage(
                      fit: BoxFit.fitHeight, image: NetworkImage(driverPhoto))),
            ),
        
            const SizedBox(
              height: 16,
            ),
        
            //driver name
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18, top: 8),
              child: TextField(
                controller: nameTextEditingController,
                textAlign: TextAlign.center,
                enabled: false,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2)),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.black,
                    )),
              ),
            ),
            //driver phone
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18, top: 4),
              child: TextField(
                controller: phoneTextEditingController,
                textAlign: TextAlign.center,
                enabled: false,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2)),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.black,
                    )),
              ),
            ),
            //driver email
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18, top: 4),
              child: TextField(
                controller: emailTextEditingController,
                textAlign: TextAlign.center,
                enabled: false,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2)),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.black,
                    )),
              ),
            ),
            //driver car
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18, top: 4),
              child: TextField(
                controller: carTextEditingController,
                textAlign: TextAlign.center,
                enabled: false,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2)),
                    prefixIcon: Icon(
                      Icons.drive_eta_rounded,
                      color: Colors.black,
                    )),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            // log out button
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 20)),
              child: const Text(
                'LogOut',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
