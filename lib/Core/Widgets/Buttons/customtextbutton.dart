import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget bchild;
  final Widget? style;
  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.bchild,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: bchild);
  }
}
