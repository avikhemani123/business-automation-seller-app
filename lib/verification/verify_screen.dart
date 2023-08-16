import 'package:flutter/material.dart';
import 'package:seller_app/verification/login.dart';
import 'package:seller_app/verification/register.dart';

class verifyscreen extends StatefulWidget {
  const verifyscreen({Key? key}) : super(key: key);

  @override
  State<verifyscreen> createState() => _verifyscreenState();
}

class _verifyscreenState extends State<verifyscreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(

      length: 2,
      child:  Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration (
              gradient: LinearGradient(
                colors: [
                  Colors.green,
                  Colors.amber,
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const   FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
              )
            ),
          ),
          automaticallyImplyLeading: false,
          title:  const  Text(
            "Seller's App",
                style: TextStyle(
              fontSize: 60,
            color: Colors.white,
            fontFamily: "Lobster",

          ),
          ),
        centerTitle:  true,
        bottom: const TabBar(
           tabs: [
             Tab(
               icon: Icon(Icons.lock, color: Colors.white,),
               text: "Login",
             ),
             Tab(
               icon: Icon(Icons.person, color: Colors.white,),
               text: "Register",
             ),
           ],
            indicatorColor: Colors.white,
          indicatorWeight: 6,
        ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors:[
                Colors.amber,
                Colors.green,

              ],
            )
          ),
       child: const TabBarView(
         children: [
           signinscreen(),
           Registerscreen(),
         ],
       ),
        ),
      ),
    );

  }
}
