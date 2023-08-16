import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seller_app/mainScreens/home_screen.dart';
import 'package:seller_app/widgets/error_dialog.dart';
import 'package:seller_app/widgets/input_file.dart';
import 'package:seller_app/widgets/loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global.dart';
class Registerscreen extends StatefulWidget {
  const Registerscreen({Key? key}) : super(key: key);

  @override
  _RegisterscreenState createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();


  XFile? imageXfile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  String completeAddress = "";
  List<Placemark>? placeMarks ;
  String sellerImageUrl = "";



  Future<void> _getImage() async
  {
    imageXfile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageXfile;
    });
  }
  getCurrentLocation() async
  {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

       position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks![0];

    // String completeAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';
     completeAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }




  Future<void> formValidation() async
  {
    if (imageXfile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please select an image.",
            );
          }
      );
    }
    else
      {
        if(passwordController.text == confirmPasswordController.text)
          {

            if(confirmPasswordController.text.isNotEmpty && emailController.text.isNotEmpty && nameController.text.isNotEmpty && phoneController.text.isNotEmpty && locationController.text.isNotEmpty )
              {
                //start uploading photo
                showDialog(
                  context: context,
                  builder: (c)
                    {
                      return LoadingDialog(
                      message: "Registering your account",
                      );
                    }
                );
                String fileName = DateTime.now().millisecondsSinceEpoch.toString();
                fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref().child("sellers").child(fileName);
                fStorage.UploadTask uploadTask = reference.putFile(File(imageXfile!.path));
                fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
                await taskSnapshot.ref.getDownloadURL().then((url) {
                  sellerImageUrl = url;
                  //save information to firestore
                  authenticateSellerAndSignUp();
                });
              }
            else
              {
                showDialog(
                    context: context,
                    builder: (c) {
                      return ErrorDialog(
                        message: "Please fill all required information for registertation",
                      );
                    }
                );
              }
          }
        else{
          showDialog(
              context: context,
              builder: (c) {
                return ErrorDialog(
                  message: "Your password does not match.",
                );
              }
          );
        }

      }
  }

  void authenticateSellerAndSignUp() async
  {
    User? currentUser;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });

    if(currentUser != null)
    {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to homePage
        Route newRoute = MaterialPageRoute(builder: (c) => HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }


  Future saveDataToFirestore(User currentUser) async
  {

    print(completeAddress);

    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set({
      "sellerUID": currentUser.uid,
      "sellerEmail": currentUser.email,
      "sellerName": nameController.text.trim(),
      "sellerAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "address": completeAddress,
      "status": "approved",
      "earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });
    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);


  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10,),
            InkWell(
              onTap: (){
                _getImage();
              },
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.white,
                backgroundImage: imageXfile==null ? null : FileImage(File(imageXfile!.path)),
                child: imageXfile == null
                    ?
                Icon(Icons.add_photo_alternate_rounded,
                  size: MediaQuery.of(context).size.width * 0.20,
                  color: Colors.grey,
                ) : null,
              ) ,
            ),
            const SizedBox(height: 10,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Input(
                    data: Icons.person,
                    controller: nameController,
                    hintText: "Name",
                    isObsecre: false,

                  ),
                  Input(
                    data: Icons.email,
                    controller: emailController,
                    hintText: "Email",
                    isObsecre: false,

                  ),
                  Input(
                    data: Icons.lock,
                    controller: passwordController,
                    hintText: "Password",
                    isObsecre: true,

                  ),
                  Input(
                    data: Icons.lock,
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    isObsecre: true,

                  ),
                  Input(
                    data: Icons.phone,
                    controller: phoneController,
                    hintText: "Phone",
                    isObsecre: false,

                  ),
                  Input(
                    data: Icons.my_location,
                    controller: locationController,
                    hintText: "Your Shop Address",
                    isObsecre: false,
                    enabled: true,

                  ),
                  Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      label: const Text(
                        "Get my Current Location",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.location_on,
                        color: Colors.blue,
                      ),
                      onPressed: ()
                      {
                        getCurrentLocation();
                      },
                      style: ElevatedButton.styleFrom(
                      primary: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30),
                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
              child: const Text(
                "SIGN UP",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold  ),
              ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                ),
              onPressed: (){
                   formValidation();
              },
            ),
            const SizedBox(height: 30,),
          ],
        ),
      ),

    );
  }
}

