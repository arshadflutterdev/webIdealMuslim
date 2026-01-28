import 'dart:async';

import 'package:flutter/material.dart';
import 'package:muslim/Core/Const/app_images.dart';
import 'package:muslim/Core/Screens/MainScreens/BottomNavBar/bottomnav.dart';
import 'package:gap/gap.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Bottomnav()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Colors.white,
                height: height * 0.25,

                child: Image(image: AssetImage(AppImages.applogo)),
              ),
              Gap(20),

              LinearProgressIndicator(
                backgroundColor: Colors.black26,
                color: Colors.green.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
