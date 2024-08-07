import 'dart:io';
import 'package:cccd/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cccd/methods/common_methods.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String driverfirstname;
  final String driverlastname;
  final String email;
  final String password;
  final String phone;

  ProfileCompletionScreen({
    required this.driverfirstname,
    required this.driverlastname,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  _ProfileCompletionScreenState createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  TextEditingController dateOfBirthTextEditingController = TextEditingController();
  TextEditingController driversLicenseNumberTextEditingController = TextEditingController();
  TextEditingController driversLicenseExpiryTextEditingController = TextEditingController();
  TextEditingController socialSecurityNumberTextEditingController = TextEditingController();
  CommonMethods cmethods = CommonMethods();

  String gender = 'Male';
  bool termsOfServiceAgreement = false;
  bool privacyPolicyAgreement = false;
  bool dataCollectionConsent = false;
  bool backgroundCheckConsent = false;

  XFile? driverPhoto;
  XFile? driversLicensePhoto;
  XFile? vehicleInsurancePhoto;
  XFile? vehicleRegistrationPhoto;

  Future<void> pickImage(ImageSource source, String imageType) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (imageType == 'driverPhoto') {
        driverPhoto = pickedFile;
      } else if (imageType == 'driversLicense') {
        driversLicensePhoto = pickedFile;
      } else if (imageType == 'vehicleInsurance') {
        vehicleInsurancePhoto = pickedFile;
      } else if (imageType == 'vehicleRegistration') {
        vehicleRegistrationPhoto = pickedFile;
      }
    });
  }

  Future<String> uploadImage(XFile? imageFile, String imageName) async {
    if (imageFile == null) return '';

    String imageIdName = DateTime.now().millisecondsSinceEpoch.toString() + "_" + imageName;
    Reference referenceImage = FirebaseStorage.instance.ref().child("images").child(imageIdName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile.path));
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: driverPhoto != null
                            ? DecorationImage(
                                image: FileImage(File(driverPhoto!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey,
                      ),
                      child: driverPhoto == null
                          ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => pickImage(ImageSource.gallery, 'driverPhoto'),
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              driverPhoto == null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select a photo',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : SizedBox(height: 20),
              TextFormField(
                controller: dateOfBirthTextEditingController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime date = DateTime(1900);
                  FocusScope.of(context).requestFocus(FocusNode());

                  date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      ) ??
                      DateTime.now();

                  dateOfBirthTextEditingController.text = dateFormat.format(date);
                },
              ),
              DropdownButtonFormField(
                value: gender,
                items: ['Male', 'Female', 'Other'].map((String category) {
                  return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: <Widget>[
                          Text(category,style: TextStyle(color: Colors.black),),
                        ],
                      ));
                }).toList(),
                onChanged: (newValue) {
                  setState(() => gender = newValue!);
                },
                decoration: InputDecoration(
                  labelText: "Gender",
                ),
              ),
              TextFormField(
                controller: driversLicenseNumberTextEditingController,
                decoration: InputDecoration(labelText: 'Driver\'s License Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your driver\'s license number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: driversLicenseExpiryTextEditingController,
                decoration: InputDecoration(labelText: 'Driver\'s License Expiry Date'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your driver\'s license expiry date';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime date = DateTime(1900);
                  FocusScope.of(context).requestFocus(FocusNode());

                  date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      ) ??
                      DateTime.now();

                  driversLicenseExpiryTextEditingController.text = dateFormat.format(date);
                },
              ),
              TextFormField(
                controller: socialSecurityNumberTextEditingController,
                decoration: InputDecoration(labelText: 'Social Security Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your social security number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: vehicleModelTextEditingController,
                decoration: InputDecoration(labelText: 'Vehicle Model'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your vehicle model';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: vehicleNumberTextEditingController,
                decoration: InputDecoration(labelText: 'Vehicle Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your vehicle number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: vehicleColorTextEditingController,
                decoration: InputDecoration(labelText: 'Vehicle Color'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your vehicle color';
                  }
                  return null;
                },
              ),
              // Image pickers for documents
              const SizedBox(height: 20),
              Text('Upload Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                title: Text('Driver\'s License Photo'),
                trailing: IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () => pickImage(ImageSource.gallery, 'driversLicense'),
                ),
              ),
              driversLicensePhoto == null
                  ? Text('No image selected.')
                  : Image.file(File(driversLicensePhoto!.path), height: 100),
              const SizedBox(height: 10),
              ListTile(
                title: Text('Vehicle Insurance Photo'),
                trailing: IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () => pickImage(ImageSource.gallery, 'vehicleInsurance'),
                ),
              ),
              vehicleInsurancePhoto == null
                  ? Text('No image selected.')
                  : Image.file(File(vehicleInsurancePhoto!.path), height: 100),
              const SizedBox(height: 10),
              ListTile(
                title: Text('Vehicle Registration Photo'),
                trailing: IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () => pickImage(ImageSource.gallery, 'vehicleRegistration'),
                ),
              ),
              vehicleRegistrationPhoto == null
                  ? Text('No image selected.')
                  : Image.file(File(vehicleRegistrationPhoto!.path), height: 100),
              const SizedBox(height: 20),
              // More form fields for other details as needed
              CheckboxListTile(
                title: Text("Agree to Terms of Service"),
                value: termsOfServiceAgreement,
                onChanged: (bool? value) {
                  setState(() {
                    termsOfServiceAgreement = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Agree to Privacy Policy"),
                value: privacyPolicyAgreement,
                onChanged: (bool? value) {
                  setState(() {
                    privacyPolicyAgreement = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Consent to Data Collection and Sharing"),
                value: dataCollectionConsent,
                onChanged: (bool? value) {
                  setState(() {
                    dataCollectionConsent = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Consent to have all Mobility Aids"),
                value: backgroundCheckConsent,
                onChanged: (bool? value) {
                  setState(() {
                    backgroundCheckConsent = value ?? false;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && driverPhoto != null) {
                    _formKey.currentState!.save();
                    await saveProfileCompletionDetails();
                  } else {
                    if (driverPhoto == null) {
                      cmethods.displaySnackbar('Please select a driver photo', context);
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveProfileCompletionDetails() async {
    String driverPhotoUrl = await uploadImage(driverPhoto, 'driver_photo');
    String driversLicenseUrl = await uploadImage(driversLicensePhoto, 'drivers_license');
    String vehicleInsuranceUrl = await uploadImage(vehicleInsurancePhoto, 'vehicle_insurance');
    String vehicleRegistrationUrl = await uploadImage(vehicleRegistrationPhoto, 'vehicle_registration');

    try {
      final User? driverFirebase = (await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          )
          .catchError((errorMsg) {
        cmethods.displaySnackbar(errorMsg.toString(), context);
      }))
          .user;

      if (driverFirebase != null) {
        DatabaseReference driversRef = FirebaseDatabase.instance.ref().child('drivers').child(driverFirebase.uid);

          Map carDataInfo = {
      'car-model' : vehicleModelTextEditingController.text.trim(),
      'car-number' : vehicleNumberTextEditingController.text.trim(),
      'car-color': vehicleColorTextEditingController.text.trim()
    };


        Map<String, dynamic> profileCompletionData = {
          'name': widget.driverfirstname + widget.driverlastname,
          'email': widget.email,
          'phone': widget.phone,
          'date_of_birth': dateOfBirthTextEditingController.text,
          'gender': gender,
          'drivers_license_number': driversLicenseNumberTextEditingController.text,
          'drivers_license_expiry': driversLicenseExpiryTextEditingController.text,
          'social_security_number': socialSecurityNumberTextEditingController.text,
          'car details' : carDataInfo,
          'terms_of_service_agreement': termsOfServiceAgreement,
          'privacy_policy_agreement': privacyPolicyAgreement,
          'data_collection_consent': dataCollectionConsent,
          'background_check_consent': backgroundCheckConsent,
          'photo': driverPhotoUrl,
          'drivers_license_photo': driversLicenseUrl,
          'vehicle_insurance_photo': vehicleInsuranceUrl,
          'vehicle_registration_photo': vehicleRegistrationUrl,
          'uid': driverFirebase.uid,
          'blockStatus': "no",
        };

        driversRef.set(profileCompletionData).then((_) {
          cmethods.displaySnackbar('Profile updated successfully!', context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Dashboard()));
        }).catchError((error) {
          cmethods.displaySnackbar('Failed to update profile: $error', context);
        });
      }
    } catch (error) {
      cmethods.displaySnackbar('Failed to create account: $error', context);
    }
  }
}
