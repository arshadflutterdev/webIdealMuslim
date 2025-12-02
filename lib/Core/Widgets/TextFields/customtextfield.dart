import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    this.fieldheight,
    this.fieldwidth,
    required this.hinttext,
    this.controller,
    this.icon,
    this.onChanged,
  });
  double? fieldheight;
  double? fieldwidth;
  String hinttext;
  TextEditingController? controller;
  Widget? icon;
  final Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fieldheight,
      width: fieldwidth,
      child: TextField(
        onChanged: onChanged,
        controller: controller,

        decoration: InputDecoration(
          suffixIcon: icon,
          hint: Text(hinttext, style: TextStyle(fontSize: 15)),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(13),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
    );
  }
}
