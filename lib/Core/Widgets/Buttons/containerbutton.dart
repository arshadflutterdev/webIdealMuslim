import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContainerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget bchild;
  final double height;
  final double width;
  const ContainerButton({
    super.key,
    required this.onPressed,
    required this.bchild,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 01,
              color: Colors.black26,
              offset: Offset(0, 02),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: bchild,
      ),
    );
  }
}
