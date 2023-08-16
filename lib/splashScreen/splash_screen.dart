import 'dart:async';
import 'package:flutter/material.dart ';
import 'package:seller_app/global/global.dart';
import 'package:seller_app/mainScreens/home_screen.dart';
import 'package:seller_app/verification//verify_screen.dart';
import 'package:flutter/material.dart';



class
MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}



class _MySplashScreenState extends State<MySplashScreen>
{

  startTimer()
  {
  //if seller is login in already
    Timer(const Duration(seconds: 1), () async {
      if(firebaseAuth.currentUser != null){

        Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));
      } //if seller is not loged in already
      else
        {
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const verifyscreen()));
        }



    });
  }

   @override
   void initState() {
     super.initState();

     startTimer();
   }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.amber,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset("images/start.png"),
              ),

              const SizedBox(height: 10,),

              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "Khemani Iron & Building Material Supplier",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontFamily: "Signatra",
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}