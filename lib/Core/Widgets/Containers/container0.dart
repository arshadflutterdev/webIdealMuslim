import 'package:flutter/material.dart';

class CustomContainer0 extends StatelessWidget {
  const CustomContainer0({
    super.key,
    this.height,
    this.child,
    required this.fillcolour,
    this.widht,
    this.bcolor,
  });

  final double? height;
  final Widget? child;
  final Color fillcolour;
  final double? widht;
  final Color? bcolor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: widht ?? double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: bcolor ?? Colors.transparent),
        color: fillcolour,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
