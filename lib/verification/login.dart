import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seller_app/global/global.dart';
import 'package:seller_app/mainScreens/home_screen.dart';
import 'package:seller_app/widgets/error_dialog.dart';
import 'package:seller_app/widgets/input_file.dart';
import 'package:seller_app/widgets/loading_dialog.dart';


class signinscreen extends StatefulWidget {
  const signinscreen({Key? key}) : super(key: key);

  @override
  State<signinscreen> createState() => _signinscreenState();
}

class _signinscreenState extends State<signinscreen> {

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  formValidation()
  {
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty)
    {
      //login
      loginNow();
    }
    else
    {
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: "Please write email/password.",
            );
          }
      );
    }
  }


  loginNow() async
  {
    showDialog(
        context: context,
        builder: (c)
        {
          return LoadingDialog(
            message: "Checking Credentials",
          );
        }
    );

    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth){
      currentUser = auth.user!;
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
      readDataAndSetDataLocally(currentUser!).then((value){
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));
      });
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async
  {
    await FirebaseFirestore.instance.collection("sellers")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      await sharedPreferences!.setString("uid", currentUser.uid);
      await sharedPreferences!.setString("email", snapshot.data()!["sellerEmail"]);
      await sharedPreferences!.setString("name", snapshot.data()!["sellerName"]);
      await sharedPreferences!.setString("photoUrl", snapshot.data()!["sellerAvatarUrl"]);
    });
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize:  MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(15),
              // child: Image.asset("images/seller.png"),
              child: Image.asset("images/start.png",
              height: 270,
              ),

            ),
          ),
          Form(
            key: _formkey,
            child: Column(
              children: [
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
              ],
            ),
          ),
          ElevatedButton(
            child: const Text(
              "LOGIN",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold  ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
            ),
            onPressed: (){
              formValidation ();
            },
          ),
          const SizedBox(height: 30,),

        ],
      ),
    );
  }
}
