import 'package:flutter/material.dart';

class IconButton0 extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget bicon;

  const IconButton0({super.key, required this.onPressed, required this.bicon});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: bicon);
  }
}



// If we say “La ilaha ill-Allah wahdahu la sharika lah, lahu`l-mulk wa lahu`l-hamd wa huwa `ala kulli shay`in qadir
// لاَ إِلَهَ إِلاَّ اللَّهُ، وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهْوَ عَلَى كُلِّ شَىْءٍ قَدِيرٌ 