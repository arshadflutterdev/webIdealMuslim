import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:muslim/Core/Screens/MainScreens/BottomNavBar/bottomnav.dart';
import 'package:muslim/Core/Services/ad_controller.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await MobileAds.instance.initialize();

  if (!kIsWeb) {
    AdController().initialize();
  }
  runApp(MyApp());
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
      title: 'Ideal Muslim - Quran Hadees&Tasbeeh counter All in one App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Bottomnav(),
    );
  }
}
