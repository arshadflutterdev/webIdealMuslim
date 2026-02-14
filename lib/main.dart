import 'package:audioplayers/audioplayers.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:muslim/Core/Const/app_audio.dart';
import 'package:muslim/Core/Screens/MainScreens/BottomNavBar/bottomnav.dart';
import 'package:muslim/Core/Screens/MainScreens/Quran/Quran_e_Majeed.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:muslim/splashscreen.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await MobileAds.instance.initialize();

  if (!kIsWeb) {
    AdController().initialize();
  }
  runApp(DevicePreview(builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Ideal Muslim - Quran,Hadees & Tasbeeh Counter All in one App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Bottomnav(),
    );
  }
}
