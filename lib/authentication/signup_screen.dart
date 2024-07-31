import 'dart:io';

import 'package:cccd/authentication/login_screen.dart';
import 'package:cccd/methods/common_methods.dart';
import 'package:cccd/pages/dashboard.dart';
import 'package:cccd/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController drivernameTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController vehiclemodelTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController =
      TextEditingController();
  TextEditingController vehicleColorEditingController = TextEditingController();
  CommonMethods cmethods = CommonMethods();
  XFile? imageFile;
  String urlOfUploadedImage = "";

  checkIfNetworkAvailable() {
    cmethods.checkConnectivity(context);

    if (imageFile != null) {
      signUpFormValidation();
    } else {
      cmethods.displaySnackbar("Please choose image", context);
    }
  }

  signUpFormValidation() {
    String email = emailTextEditingController.text.trim();
    if (drivernameTextEditingController.text.trim().length < 4) {
      cmethods.displaySnackbar(
          'Your name must be atleast 4 characters', context);
    } else if (phoneTextEditingController.text.trim().length < 10) {
      cmethods.displaySnackbar(
          'Your Phone number must be atleast 10 characters', context);
    } else if (!email.contains('@')) {
      cmethods.displaySnackbar('Please enter email address', context);
    } else if (passwordTextEditingController.text.trim().length < 6) {
      cmethods.displaySnackbar(
          'Your Password must be atleast 6 characters', context);
    } else if (vehiclemodelTextEditingController.text.trim().isEmpty) {
      cmethods.displaySnackbar('Please enter Car Model', context);
    } else if (vehicleNumberTextEditingController.text.trim().isEmpty) {
      cmethods.displaySnackbar('Please enter Car Number', context);
    } else if (vehicleColorEditingController.text.trim().isEmpty) {
      cmethods.displaySnackbar('Please enter Car Color', context);
    } else {
      uploadImageToStorage();
    }
  }

  uploadImageToStorage() async {
    String imageIdName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage =
        FirebaseStorage.instance.ref().child("images").child(imageIdName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });

    registerNewdriver();
  }

  registerNewdriver() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: " Registering Account"));

    final User? driverFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text.trim(),
                password: passwordTextEditingController.text.trim())
            .catchError((errorMsg) {
      Navigator.pop(context);
      cmethods.displaySnackbar(errorMsg.toString(), context);
    }))
        .user;
    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference driversRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(driverFirebase!.uid);

    Map carDataInfo = {
      'car-model' : vehiclemodelTextEditingController.text.trim(),
      'car-number' : vehicleNumberTextEditingController.text.trim(),
      'car-color': vehicleColorEditingController.text.trim()
    };

    Map driverDataMap = {
      "photo" : urlOfUploadedImage,
      'car details' : carDataInfo,
      'name': drivernameTextEditingController.text.trim(),
      'email': emailTextEditingController.text.trim(),
      'phone': phoneTextEditingController.text.trim(),
      'uid': driverFirebase.uid,
      'blockStatus': "no"
    };
    driversRef.set(driverDataMap);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => Dashboard()));
  }

  getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              imageFile == null
                  ? const CircleAvatar(
                      radius: 80,
                      backgroundImage:
                          AssetImage("assets/images/avatarman.png"),
                    )
                  : Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                          image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: FileImage(File(imageFile!.path)))),
                    ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  getImageFromGallery();
                },
                child: const Text(
                  'Choose Image',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    TextField(
                      controller: drivernameTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: ' Your name',
                          labelStyle: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Your Phone number',
                          labelStyle: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Your email',
                          labelStyle: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Your password',
                          labelStyle: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: vehiclemodelTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: ' Your Car Model',
                          labelStyle: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: vehicleNumberTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: ' Your Car Number',
                          labelStyle: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: vehicleColorEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: ' Your Car Color',
                          labelStyle: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 10)),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: const Text(
                        'Already have a account? Login here',
                        style: TextStyle(color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
