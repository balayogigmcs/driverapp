import 'package:cccd/forms/driver_profile.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController driverfirstnameTextEditingController =
      TextEditingController();
      TextEditingController driverlastnameTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Sign Up',
        style: TextStyle(color: Colors.blue),
      ),backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(
                height: 0,
              ),
              Text(
                'Register As a Driver',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              TextFormField(
                controller: driverfirstnameTextEditingController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(fontSize: 14),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 4) {
                    return 'Your name must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: driverlastnameTextEditingController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(fontSize: 14),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 4) {
                    return 'Your name must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Your Phone Number',
                  labelStyle: TextStyle(fontSize: 14),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 10) {
                    return 'Your phone number must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Your Email',
                  labelStyle: TextStyle(fontSize: 14),
                ),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: passwordTextEditingController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Your Password',
                  labelStyle: TextStyle(fontSize: 14),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Your password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileCompletionScreen(
                          driverfirstname: driverfirstnameTextEditingController.text,
                          driverlastname: driverlastnameTextEditingController.text,
                          email: emailTextEditingController.text,
                          password: passwordTextEditingController.text,
                          phone: phoneTextEditingController.text,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'dart:io';
// import 'package:cccd/authentication/login_screen.dart';
// import 'package:cccd/forms/driver_profile.dart';
// import 'package:cccd/methods/common_methods.dart';
// import 'package:cccd/widgets/loading_dialog.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   TextEditingController drivernameTextEditingController = TextEditingController();
//   TextEditingController emailTextEditingController = TextEditingController();
//   TextEditingController passwordTextEditingController = TextEditingController();
//   TextEditingController phoneTextEditingController = TextEditingController();
//   CommonMethods cmethods = CommonMethods();
//   XFile? imageFile;
//   String urlOfUploadedImage = "";

//   checkIfNetworkAvailable() {
//     cmethods.checkConnectivity(context);

//     if (imageFile != null) {
//       signUpFormValidation();
//     } else {
//       cmethods.displaySnackbar("Please choose image", context);
//     }
//   }

//   signUpFormValidation() {
//     String email = emailTextEditingController.text.trim();
//     if (drivernameTextEditingController.text.trim().length < 4) {
//       cmethods.displaySnackbar('Your name must be at least 4 characters', context);
//     } else if (phoneTextEditingController.text.trim().length < 10) {
//       cmethods.displaySnackbar('Your phone number must be at least 10 characters', context);
//     } else if (!email.contains('@')) {
//       cmethods.displaySnackbar('Please enter a valid email address', context);
//     } else if (passwordTextEditingController.text.trim().length < 6) {
//       cmethods.displaySnackbar('Your password must be at least 6 characters', context);
//     } else {
//       uploadImageToStorage();
//     }
//   }

//   uploadImageToStorage() async {
//     String imageIdName = DateTime.now().millisecondsSinceEpoch.toString();
//     Reference referenceImage = FirebaseStorage.instance.ref().child("images").child(imageIdName);

//     UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
//     TaskSnapshot snapshot = await uploadTask;
//     urlOfUploadedImage = await snapshot.ref.getDownloadURL();

//     setState(() {
//       urlOfUploadedImage;
//     });

//     registerNewDriver();
//   }

//   registerNewDriver() async {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) => LoadingDialog(messageText: " Registering Account"));

//     final User? driverFirebase = (await FirebaseAuth.instance
//         .createUserWithEmailAndPassword(
//             email: emailTextEditingController.text.trim(),
//             password: passwordTextEditingController.text.trim())
//         .catchError((errorMsg) {
//       Navigator.pop(context);
//       cmethods.displaySnackbar(errorMsg.toString(), context);
//     }))
//         .user;
//     if (!context.mounted) return;
//     Navigator.pop(context);

//     DatabaseReference driversRef = FirebaseDatabase.instance.ref().child('drivers').child(driverFirebase!.uid);

//     Map driverDataMap = {
//       "photo": urlOfUploadedImage,
//       'name': drivernameTextEditingController.text.trim(),
//       'email': emailTextEditingController.text.trim(),
//       'phone': phoneTextEditingController.text.trim(),
//       'uid': driverFirebase.uid,
//       'blockStatus': "no"
//     };
//     driversRef.set(driverDataMap);

//     Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileCompletionScreen(driverFirebase.uid)));
//   }

//   getImageFromGallery() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         imageFile = pickedFile;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: [
//               const SizedBox(
//                 height: 30,
//               ),
//               imageFile == null
//                   ? const CircleAvatar(
//                       radius: 80,
//                       backgroundImage: AssetImage("assets/images/avatarman.png"),
//                     )
//                   : Container(
//                       width: 180,
//                       height: 180,
//                       decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.grey,
//                           image: DecorationImage(
//                               fit: BoxFit.fitHeight,
//                               image: FileImage(File(imageFile!.path)))),
//                     ),
//               const SizedBox(
//                 height: 20,
//               ),
//               GestureDetector(
//                 onTap: () {
//                   getImageFromGallery();
//                 },
//                 child: const Text(
//                   'Choose Image',
//                   style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(5),
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: drivernameTextEditingController,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: const InputDecoration(
//                           labelText: 'Your name',
//                           labelStyle: TextStyle(fontSize: 14)),
//                     ),
//                     const SizedBox(
//                       height: 22,
//                     ),
//                     TextField(
//                       controller: phoneTextEditingController,
//                       keyboardType: TextInputType.phone,
//                       decoration: const InputDecoration(
//                           labelText: 'Your phone number',
//                           labelStyle: TextStyle(fontSize: 14)),
//                     ),
//                     const SizedBox(
//                       height: 22,
//                     ),
//                     TextField(
//                       controller: emailTextEditingController,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: const InputDecoration(
//                           labelText: 'Your email',
//                           labelStyle: TextStyle(fontSize: 14)),
//                     ),
//                     const SizedBox(
//                       height: 22,
//                     ),
//                     TextField(
//                       controller: passwordTextEditingController,
//                       obscureText: true,
//                       keyboardType: TextInputType.text,
//                       decoration: const InputDecoration(
//                           labelText: 'Your password',
//                           labelStyle: TextStyle(fontSize: 14)),
//                     ),
//                     const SizedBox(
//                       height: 22,
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         checkIfNetworkAvailable();
//                       },
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 80, vertical: 10)),
//                       child: const Text(
//                         'Sign Up',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 12,
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => LoginScreen()));
//                       },
//                       child: const Text(
//                         'Already have an account? Login here',
//                         style: TextStyle(color: Colors.blue),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
